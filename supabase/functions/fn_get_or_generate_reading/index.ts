import { fail, handleOptions, ok, readJson } from "../_shared/http.ts";
import { createServiceClient, requireAuth } from "../_shared/supabase.ts";
import { assertOwnedProfile } from "../_shared/domain.ts";
import { ensurePromptSchema, getActivePrompt } from "../_shared/prompt.ts";
import { loadActiveMemory, parseMemoryFactsFromOutput, touchMemory, upsertMemoryFacts } from "../_shared/memory.ts";
import { AiGatewayError, callGemini, isAiGatewayError } from "../_shared/gemini.ts";
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

const FIXED_ONCE_FEATURES = new Set([
  "core_numbers",
  "psych_matrix",
  "birth_chart",
  "energy_boost",
  "four_peaks",
  "four_challenges",
  "compatibility",
]);

const DAILY_REFRESH_FEATURES = new Set([
  "forecast_day",
  "biorhythm_daily",
]);

const MONTHLY_REFRESH_FEATURES = new Set([
  "forecast_month",
]);

const YEARLY_REFRESH_FEATURES = new Set([
  "forecast_year",
]);

type ReadingScope = {
  scopeType: "fixed" | "daily" | "monthly" | "yearly";
  targetDate: string | null;
  periodKey: string | null;
  scopeIdentity: string;
};

function formatInVietnamTime(date: Date): string {
  return new Intl.DateTimeFormat("sv-SE", {
    timeZone: "Asia/Ho_Chi_Minh",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(date);
}

function currentDateISO(): string {
  return formatInVietnamTime(new Date());
}

function currentMonthKey(): string {
  return currentDateISO().slice(0, 7);
}

function currentYearKey(): string {
  return currentDateISO().slice(0, 4);
}

function normalizeDateInput(raw: string | null | undefined): string | null {
  if (!raw || !raw.trim()) {
    return null;
  }
  const normalized = raw.trim().slice(0, 10);
  const date = new Date(`${normalized}T00:00:00Z`);
  if (Number.isNaN(date.getTime())) {
    throw new Error("target_date must be in YYYY-MM-DD format.");
  }
  return normalized;
}

function normalizeMonthKey(raw: string | null | undefined, fallbackDate: string | null): string {
  const normalized = raw?.trim() ?? "";
  if (/^\d{4}-\d{2}$/.test(normalized)) {
    return normalized;
  }
  if (fallbackDate) {
    return fallbackDate.slice(0, 7);
  }
  return currentMonthKey();
}

function normalizeYearKey(raw: string | null | undefined, fallbackDate: string | null): string {
  const normalized = raw?.trim() ?? "";
  if (/^\d{4}$/.test(normalized)) {
    return normalized;
  }
  if (fallbackDate) {
    return fallbackDate.slice(0, 4);
  }
  return currentYearKey();
}

function buildScopeIdentity(params: {
  featureKey: string;
  profileId: string;
  secondaryProfileId?: string | null;
  targetDate?: string | null;
  periodKey?: string | null;
}): string {
  return [
    `feature:${params.featureKey}`,
    `profile:${params.profileId}`,
    `secondary:${params.secondaryProfileId ?? "none"}`,
    `target_date:${params.targetDate ?? "none"}`,
    `period_key:${params.periodKey ?? "none"}`,
  ].join("|");
}

function resolveReadingScope(payload: ReadingPayload): ReadingScope {
  const normalizedTargetDate = normalizeDateInput(payload.target_date);

  if (FIXED_ONCE_FEATURES.has(payload.feature_key)) {
    return {
      scopeType: "fixed",
      targetDate: null,
      periodKey: null,
      scopeIdentity: buildScopeIdentity({
        featureKey: payload.feature_key,
        profileId: payload.profile_id,
        secondaryProfileId: payload.secondary_profile_id,
      }),
    };
  }

  if (DAILY_REFRESH_FEATURES.has(payload.feature_key)) {
    const targetDate = normalizedTargetDate ?? currentDateISO();
    return {
      scopeType: "daily",
      targetDate,
      periodKey: null,
      scopeIdentity: buildScopeIdentity({
        featureKey: payload.feature_key,
        profileId: payload.profile_id,
        secondaryProfileId: payload.secondary_profile_id,
        targetDate,
      }),
    };
  }

  if (MONTHLY_REFRESH_FEATURES.has(payload.feature_key)) {
    const periodKey = normalizeMonthKey(payload.target_period, normalizedTargetDate);
    return {
      scopeType: "monthly",
      targetDate: null,
      periodKey,
      scopeIdentity: buildScopeIdentity({
        featureKey: payload.feature_key,
        profileId: payload.profile_id,
        secondaryProfileId: payload.secondary_profile_id,
        periodKey,
      }),
    };
  }

  if (YEARLY_REFRESH_FEATURES.has(payload.feature_key)) {
    const periodKey = normalizeYearKey(payload.target_period, normalizedTargetDate);
    return {
      scopeType: "yearly",
      targetDate: null,
      periodKey,
      scopeIdentity: buildScopeIdentity({
        featureKey: payload.feature_key,
        profileId: payload.profile_id,
        secondaryProfileId: payload.secondary_profile_id,
        periodKey,
      }),
    };
  }

  throw new Error(`Unsupported scope resolution for feature "${payload.feature_key}".`);
}

function getProfileFreshnessCutoff(params: {
  primaryProfile: Record<string, unknown>;
  secondaryProfile?: Record<string, unknown> | null;
}): string | null {
  const timestamps = [
    params.primaryProfile.updated_at,
    params.secondaryProfile?.updated_at,
  ]
    .filter((value): value is string => typeof value === "string" && value.trim().length > 0)
    .map((value) => new Date(value))
    .filter((value) => !Number.isNaN(value.getTime()))
    .map((value) => value.toISOString());

  if (timestamps.length === 0) {
    return null;
  }

  return timestamps.sort().at(-1) ?? null;
}

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
    const scope = resolveReadingScope(payload);

    let secondaryProfile: Record<string, unknown> | null = null;
    if (payload.secondary_profile_id) {
      secondaryProfile = await assertOwnedProfile(serviceClient, userId, payload.secondary_profile_id);
      if (!secondaryProfile.full_name || !secondaryProfile.birth_date || !profile.full_name || !profile.birth_date) {
        return fail("Compatibility requires both profiles with full_name and birth_date.");
      }
    }

    const freshnessCutoff = getProfileFreshnessCutoff({
      primaryProfile: profile,
      secondaryProfile,
    });
    const forceRefresh = payload.force_refresh === true;

    if (!forceRefresh) {
      let existingQuery = serviceClient
        .from("user_readings")
        .select("id,feature_key,result_snapshot,created_at,ai_content_id")
        .eq("user_id", userId)
        .eq("profile_id", payload.profile_id)
        .eq("feature_key", payload.feature_key)
        .order("created_at", { ascending: false })
        .limit(1);

      if (payload.secondary_profile_id) {
        existingQuery = existingQuery.eq("secondary_profile_id", payload.secondary_profile_id);
      } else {
        existingQuery = existingQuery.is("secondary_profile_id", null);
      }

      if (scope.targetDate) {
        existingQuery = existingQuery.eq("target_date", scope.targetDate);
      } else {
        existingQuery = existingQuery.is("target_date", null);
      }

      if (scope.periodKey) {
        existingQuery = existingQuery.eq("period_key", scope.periodKey);
      } else {
        existingQuery = existingQuery.is("period_key", null);
      }

      if (freshnessCutoff) {
        existingQuery = existingQuery.gte("created_at", freshnessCutoff);
      }

      const { data: existingReading, error: existingReadingError } = await existingQuery.maybeSingle();

      if (existingReadingError) {
        throw new Error(`Failed to query existing reading: ${existingReadingError.message}`);
      }

      if (existingReading) {
        await touchMemory(serviceClient, userId, payload.profile_id);
        return ok({
          reading_id: existingReading.id,
          feature_key: payload.feature_key,
          from_cache: true,
          result: existingReading.result_snapshot,
          generated_at: existingReading.created_at,
          prompt_version: null,
          context_version: null,
        });
      }
    }

    const primaryBaseline = await getOrCreateProfileBaseline(serviceClient, {
      userId,
      profile,
    });
    let secondaryBaseline: Awaited<ReturnType<typeof getOrCreateProfileBaseline>> | null = null;
    if (secondaryProfile) {
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
      target_period: scope.periodKey,
      target_date: scope.targetDate,
      context: {
        version: contextVersion,
        global_blocks: globalContextBlocks,
        memory,
        recent_readings: recentReadings ?? [],
      },
      prompt_version_id: prompt.id,
    };

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
        input_hash: scope.scopeIdentity,
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
        period_key: scope.periodKey,
        target_date: scope.targetDate,
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
