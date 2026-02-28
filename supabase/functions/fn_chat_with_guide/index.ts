import { fail, handleOptions, ok, readJson } from "../_shared/http.ts";
import { createServiceClient, requireAuth } from "../_shared/supabase.ts";
import { assertOwnedProfile, getEntitlement } from "../_shared/domain.ts";
import { getActivePrompt } from "../_shared/prompt.ts";
import { loadActiveMemory, parseMemoryFactsFromOutput, upsertMemoryFacts } from "../_shared/memory.ts";
import { callGemini } from "../_shared/gemini.ts";
import { sha256Hex } from "../_shared/hash.ts";

type ChatPayload = {
  profile_id: string;
  session_id?: string | null;
  message: string;
};

function monthStartISO(date = new Date()): string {
  return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), 1)).toISOString().slice(0, 10);
}

Deno.serve(async (req) => {
  const optionsResponse = handleOptions(req);
  if (optionsResponse) return optionsResponse;

  if (req.method !== "POST") {
    return fail("Method not allowed", 405);
  }

  try {
    const { userId } = await requireAuth(req);
    const payload = await readJson<ChatPayload>(req);
    const serviceClient = createServiceClient();

    if (!payload.profile_id || !payload.message?.trim()) {
      return fail("profile_id and message are required.");
    }

    await assertOwnedProfile(serviceClient, userId, payload.profile_id);
    const entitlement = await getEntitlement(serviceClient, userId);

    if (!entitlement || entitlement.is_vip_pro !== true) {
      return fail("VIP Pro required for AI chatbot.", 403);
    }

    const quotaLimit = Number(entitlement.chatbot_monthly_limit ?? 0);
    if (quotaLimit <= 0) {
      return ok({
        session_id: payload.session_id ?? null,
        reply: null,
        remaining_quota: 0,
        quota_limit: 0,
        quota_exhausted: true,
      });
    }

    const usageMonth = monthStartISO();
    const { error: usageSeedError } = await serviceClient
      .from("ai_usage_ledger")
      .upsert(
        {
          user_id: userId,
          usage_month: usageMonth,
          usage_type: "chat_turn",
          quota_limit: quotaLimit,
          used_count: 0,
          blocked_count: 0,
          estimated_cost_usd: 0,
        },
        { onConflict: "user_id,usage_month,usage_type", ignoreDuplicates: true },
      );
    if (usageSeedError) {
      throw new Error(`Failed to initialize usage ledger: ${usageSeedError.message}`);
    }

    let sessionId = payload.session_id ?? null;
    if (sessionId) {
      const { data: session, error: sessionError } = await serviceClient
        .from("ai_chat_sessions")
        .select("id")
        .eq("id", sessionId)
        .eq("user_id", userId)
        .eq("profile_id", payload.profile_id)
        .maybeSingle();
      if (sessionError) {
        throw new Error(`Failed to load chat session: ${sessionError.message}`);
      }
      if (!session) {
        return fail("Invalid session_id.", 404);
      }
    } else {
      const { data: created, error: createError } = await serviceClient
        .from("ai_chat_sessions")
        .insert({
          user_id: userId,
          profile_id: payload.profile_id,
          status: "active",
        })
        .select("id")
        .single();
      if (createError) {
        throw new Error(`Failed to create session: ${createError.message}`);
      }
      sessionId = created.id;
    }

    const { error: userMessageError } = await serviceClient
      .from("ai_chat_messages")
      .insert({
        session_id: sessionId,
        user_id: userId,
        role: "user",
        content: payload.message.trim(),
      });
    if (userMessageError) {
      throw new Error(`Failed to store user message: ${userMessageError.message}`);
    }

    const [{ data: recentMessages, error: recentMessagesError }, memory, { data: recentReadings, error: readingsError }] =
      await Promise.all([
        serviceClient
          .from("ai_chat_messages")
          .select("role,content,created_at")
          .eq("session_id", sessionId)
          .order("created_at", { ascending: false })
          .limit(20),
        loadActiveMemory(serviceClient, userId, payload.profile_id, 20),
        serviceClient
          .from("user_readings")
          .select("feature_key,period_key,target_date,result_snapshot,created_at")
          .eq("user_id", userId)
          .eq("profile_id", payload.profile_id)
          .order("created_at", { ascending: false })
          .limit(8),
      ]);

    if (recentMessagesError) {
      throw new Error(`Failed to load recent messages: ${recentMessagesError.message}`);
    }
    if (readingsError) {
      throw new Error(`Failed to load recent readings: ${readingsError.message}`);
    }

    const prompt = await getActivePrompt(serviceClient, "chat_assistant");

    const geminiInput = {
      profile_id: payload.profile_id,
      session_id: sessionId,
      user_message: payload.message.trim(),
      memory,
      recent_readings: recentReadings ?? [],
      recent_messages: [...(recentMessages ?? [])].reverse(),
    };

    const geminiResult = await callGemini({
      model: prompt.model_name,
      systemInstruction: prompt.prompt_template,
      userPayload: geminiInput,
    });

    const { data: quotaResult, error: quotaError } = await serviceClient.rpc(
      "increment_ai_usage_if_available",
      {
        p_user_id: userId,
        p_usage_month: usageMonth,
        p_usage_type: "chat_turn",
        p_quota_limit: quotaLimit,
      },
    );

    if (quotaError) {
      throw new Error(`Failed to update quota: ${quotaError.message}`);
    }

    const usageRow = Array.isArray(quotaResult) ? quotaResult[0] : quotaResult;
    if (!usageRow?.allowed) {
      return ok({
        session_id: sessionId,
        reply: null,
        remaining_quota: 0,
        quota_limit: quotaLimit,
        quota_exhausted: true,
      });
    }

    const contentHash = await sha256Hex({
      session_id: sessionId,
      message: payload.message.trim(),
      prompt_id: prompt.id,
      created_at: new Date().toISOString(),
    });

    const { data: generated, error: generatedError } = await serviceClient
      .from("ai_generated_contents")
      .insert({
        user_id: userId,
        profile_id: payload.profile_id,
        feature_key: "chat_assistant",
        prompt_version_id: prompt.id,
        input_hash: contentHash,
        output_text: geminiResult.rawText,
        output_json: geminiResult.json,
        token_input: geminiResult.usage.promptTokenCount,
        token_output: geminiResult.usage.candidatesTokenCount,
      })
      .select("id,output_json")
      .single();

    if (generatedError) {
      throw new Error(`Failed to store AI response: ${generatedError.message}`);
    }

    const assistantText = typeof generated.output_json.reply === "string"
      ? generated.output_json.reply
      : geminiResult.rawText;

    const { error: assistantMessageError } = await serviceClient
      .from("ai_chat_messages")
      .insert({
        session_id: sessionId,
        user_id: userId,
        role: "assistant",
        content: assistantText,
        ai_content_id: generated.id,
        token_input: geminiResult.usage.promptTokenCount,
        token_output: geminiResult.usage.candidatesTokenCount,
      });

    if (assistantMessageError) {
      throw new Error(`Failed to store assistant message: ${assistantMessageError.message}`);
    }

    const memoryFacts = parseMemoryFactsFromOutput(generated.output_json as Record<string, unknown>);
    await upsertMemoryFacts(serviceClient, {
      userId,
      profileId: payload.profile_id,
      sourceContentId: generated.id,
      facts: memoryFacts,
    });

    const usedCount = Number(usageRow.used_count ?? 0);
    const remaining = Math.max(0, quotaLimit - usedCount);

    return ok({
      session_id: sessionId,
      reply: assistantText,
      remaining_quota: remaining,
      quota_limit: quotaLimit,
      quota_exhausted: remaining <= 0,
    });
  } catch (error) {
    return fail(error instanceof Error ? error.message : "Internal error", 500);
  }
});

