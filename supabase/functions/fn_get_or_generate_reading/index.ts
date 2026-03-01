import { fail, handleOptions, ok, readJson } from "../_shared/http.ts";
import { createServiceClient, requireAuth } from "../_shared/supabase.ts";
import { assertOwnedProfile } from "../_shared/domain.ts";
import { ensurePromptSchema, getActivePrompt } from "../_shared/prompt.ts";
import { loadActiveMemory, parseMemoryFactsFromOutput, touchMemory, upsertMemoryFacts } from "../_shared/memory.ts";
import { AiGatewayError, callGemini, isAiGatewayError } from "../_shared/gemini.ts";
import { sha256Hex } from "../_shared/hash.ts";
import { buildContextVersion, loadGlobalContextBlocks } from "../_shared/context.ts";
import { getOrCreateProfileBaseline } from "../_shared/baseline.ts";

type ReadingPayload = {
  profile_id: string;
  feature_key: string;
  target_period?: string | null;
  target_date?: string | null;
  secondary_profile_id?: string | null;
  force_refresh?: boolean;
};

const ALLOWED_FEATURES = new Set([
  "core_numbers",
  "psych_matrix",
  "birth_chart",
  "energy_boost",
  "four_peaks",
  "four_challenges",
  "biorhythm_daily",
  "forecast_day",
  "forecast_month",
  "forecast_year",
  "compatibility",
]);

function failAi(error: AiGatewayError): Response {
  return fail(error.message, error.status, {
    code: error.code,
    details: error.details ?? null,
  });
}

Deno.serve(async (req) => {
  const optionsResponse = handleOptions(req);
  if (optionsResponse) return optionsResponse;

  if (req.method !== "POST") {
    return fail("Method not allowed", 405);
  }

  try {
    const { userId } = await requireAuth(req);
    const payload = await readJson<ReadingPayload>(req);
    const serviceClient = createServiceClient();

    if (!payload.profile_id || !payload.feature_key) {
      return fail("profile_id and feature_key are required.");
    }
    if (!ALLOWED_FEATURES.has(payload.feature_key)) {
      return fail("Unsupported feature_key.");
    }

    const profile = await assertOwnedProfile(serviceClient, userId, payload.profile_id);
    const primaryBaseline = await getOrCreateProfileBaseline(serviceClient, {
      userId,
      profile,
    });

    let secondaryProfile: Record<string, unknown> | null = null;
    let secondaryBaseline: Awaited<ReturnType<typeof getOrCreateProfileBaseline>> | null = null;

    if (payload.secondary_profile_id) {
      secondaryProfile = await assertOwnedProfile(serviceClient, userId, payload.secondary_profile_id);
      if (!secondaryProfile.full_name || !secondaryProfile.birth_date || !profile.full_name || !profile.birth_date) {
        return fail("Compatibility requires both profiles with full_name and birth_date.");
      }
      secondaryBaseline = await getOrCreateProfileBaseline(serviceClient, {
        userId,
        profile: secondaryProfile,
      });
    }

    const prompt = await getActivePrompt(serviceClient, payload.feature_key);
    const promptSchema = ensurePromptSchema(prompt);

    const [{ blocks: globalContextBlocks, contextVersion: globalContextVersion }, memory, { data: recentReadings, error: recentReadingsError }] =
      await Promise.all([
        loadGlobalContextBlocks(serviceClient, {
          featureKey: payload.feature_key,
          locale: "vi-VN",
        }),
        loadActiveMemory(serviceClient, userId, payload.profile_id, 20),
        serviceClient
          .from("user_readings")
          .select("feature_key,period_key,target_date,result_snapshot,created_at")
          .eq("user_id", userId)
          .eq("profile_id", payload.profile_id)
          .order("created_at", { ascending: false })
          .limit(6),
      ]);

    if (recentReadingsError) {
      throw new Error(`Failed to load recent readings: ${recentReadingsError.message}`);
    }

    const contextVersion = buildContextVersion({
      globalContextVersion,
      baselineVersions: [primaryBaseline.contextVersion, secondaryBaseline?.contextVersion],
    });

    const normalizedInput = {
      feature_key: payload.feature_key,
      profile: {
        id: profile.id,
        full_name: profile.full_name,
        birth_date: profile.birth_date,
        gender: profile.gender,
        baseline: primaryBaseline.baseline,
      },
      secondary_profile: secondaryProfile
        ? {
          id: secondaryProfile.id,
          full_name: secondaryProfile.full_name,
          birth_date: secondaryProfile.birth_date,
          gender: secondaryProfile.gender,
          baseline: secondaryBaseline?.baseline ?? null,
        }
        : null,
      target_period: payload.target_period ?? null,
      target_date: payload.target_date ?? null,
      context: {
        version: contextVersion,
        global_blocks: globalContextBlocks,
        memory,
        recent_readings: recentReadings ?? [],
      },
      prompt_version_id: prompt.id,
    };

    // Cache key must be stable across repeated reads. Do not include
    // volatile memory/recent history blocks used only for AI reasoning.
    const cacheIdentity = {
      feature_key: payload.feature_key,
      profile: {
        id: profile.id,
        full_name: profile.full_name,
        birth_date: profile.birth_date,
        gender: profile.gender ?? null,
      },
      secondary_profile: secondaryProfile
        ? {
          id: secondaryProfile.id,
          full_name: secondaryProfile.full_name,
          birth_date: secondaryProfile.birth_date,
          gender: secondaryProfile.gender ?? null,
        }
        : null,
      target_period: payload.target_period ?? null,
      target_date: payload.target_date ?? null,
      prompt_version_id: prompt.id,
      context_version: contextVersion,
    };

    const inputHash = await sha256Hex(cacheIdentity);
    const forceRefresh = payload.force_refresh === true;
    const nowIso = new Date().toISOString();

    if (!forceRefresh) {
      const { data: cached, error: cachedError } = await serviceClient
        .from("ai_generated_contents")
        .select("*")
        .eq("user_id", userId)
        .eq("profile_id", payload.profile_id)
        .eq("feature_key", payload.feature_key)
        .eq("prompt_version_id", prompt.id)
        .eq("input_hash", inputHash)
        .or(`expires_at.is.null,expires_at.gt.${nowIso}`)
        .order("generated_at", { ascending: false })
        .limit(1)
        .maybeSingle();

      if (cachedError) {
        throw new Error(`Failed to query cache: ${cachedError.message}`);
      }

      if (cached) {
        const { data: reading, error: readingError } = await serviceClient
          .from("user_readings")
          .insert({
            user_id: userId,
            profile_id: payload.profile_id,
            secondary_profile_id: payload.secondary_profile_id ?? null,
            feature_key: payload.feature_key,
            period_key: payload.target_period ?? null,
            target_date: payload.target_date ?? null,
            ai_content_id: cached.id,
            result_snapshot: cached.output_json,
            source_type: "cached",
          })
          .select("id,created_at")
          .single();

        if (readingError) {
          throw new Error(`Failed to insert cached reading: ${readingError.message}`);
        }

        await touchMemory(serviceClient, userId, payload.profile_id);
        return ok({
          reading_id: reading.id,
          feature_key: payload.feature_key,
          from_cache: true,
          result: cached.output_json,
          generated_at: cached.generated_at,
          prompt_version: prompt.version,
          context_version: contextVersion,
        });
      }
    }

    const geminiResult = await callGemini({
      model: prompt.model_name,
      systemInstruction: prompt.prompt_template,
      userPayload: normalizedInput,
      responseSchema: promptSchema,
    });

    const { data: generatedRow, error: generatedError } = await serviceClient
      .from("ai_generated_contents")
      .insert({
        user_id: userId,
        profile_id: payload.profile_id,
        feature_key: payload.feature_key,
        prompt_version_id: prompt.id,
        input_hash: inputHash,
        output_text: geminiResult.rawText,
        output_json: geminiResult.json,
        token_input: geminiResult.usage.promptTokenCount,
        token_output: geminiResult.usage.candidatesTokenCount,
      })
      .select("id,generated_at,output_json")
      .single();

    if (generatedError) {
      throw new Error(`Failed to store generated content: ${generatedError.message}`);
    }

    const { data: reading, error: readingError } = await serviceClient
      .from("user_readings")
      .insert({
        user_id: userId,
        profile_id: payload.profile_id,
        secondary_profile_id: payload.secondary_profile_id ?? null,
        feature_key: payload.feature_key,
        period_key: payload.target_period ?? null,
        target_date: payload.target_date ?? null,
        ai_content_id: generatedRow.id,
        result_snapshot: generatedRow.output_json,
        source_type: "ai_orchestrated",
      })
      .select("id")
      .single();

    if (readingError) {
      throw new Error(`Failed to insert reading history: ${readingError.message}`);
    }

    const memoryFacts = parseMemoryFactsFromOutput(generatedRow.output_json as Record<string, unknown>);
    await upsertMemoryFacts(serviceClient, {
      userId,
      profileId: payload.profile_id,
      sourceContentId: generatedRow.id,
      sourceReadingId: reading.id,
      facts: memoryFacts,
    });

    await touchMemory(serviceClient, userId, payload.profile_id);

    return ok({
      reading_id: reading.id,
      feature_key: payload.feature_key,
      from_cache: false,
      result: generatedRow.output_json,
      generated_at: generatedRow.generated_at,
      prompt_version: prompt.version,
      context_version: contextVersion,
    });
  } catch (error) {
    if (isAiGatewayError(error)) {
      return failAi(error);
    }
    return fail(error instanceof Error ? error.message : "Internal error", 500);
  }
});
