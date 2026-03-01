import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import { sha256Hex } from "./hash.ts";
import { buildNumerologyBaseline, type NumerologyBaseline } from "./numerology.ts";

type ProfileRow = Record<string, unknown>;

export type ProfileBaselineResult = {
  baseline: NumerologyBaseline;
  calcVersion: string;
  contextVersion: string;
  source: "cache" | "recomputed";
};

const DEFAULT_CALC_VERSION = "calc_v1.0.0";

function normalizeBirthDate(raw: unknown): string {
  if (typeof raw !== "string") {
    throw new Error("birth_date is required.");
  }
  const normalized = raw.trim().slice(0, 10);
  const dt = new Date(`${normalized}T00:00:00Z`);
  if (Number.isNaN(dt.getTime())) {
    throw new Error("birth_date must be in YYYY-MM-DD format.");
  }
  return normalized;
}

function normalizeFullName(raw: unknown): string {
  if (typeof raw !== "string") {
    throw new Error("full_name is required.");
  }
  const normalized = raw.trim();
  if (!normalized) {
    throw new Error("full_name is required.");
  }
  return normalized;
}

export async function getOrCreateProfileBaseline(
  serviceClient: SupabaseClient,
  params: {
    userId: string;
    profile: ProfileRow;
    calcVersion?: string;
  },
): Promise<ProfileBaselineResult> {
  const calcVersion = params.calcVersion ?? DEFAULT_CALC_VERSION;
  const profileId = String(params.profile.id ?? "");
  if (!profileId) {
    throw new Error("profile.id is required for baseline generation.");
  }

  const fullName = normalizeFullName(params.profile.full_name);
  const birthDate = normalizeBirthDate(params.profile.birth_date);

  const inputHash = await sha256Hex({
    calc_version: calcVersion,
    full_name: fullName,
    birth_date: birthDate,
  });

  const { data: existing, error: existingError } = await serviceClient
    .from("profile_numerology_baselines")
    .select("id,input_hash,context_version,baseline_json")
    .eq("user_id", params.userId)
    .eq("profile_id", profileId)
    .eq("calc_version", calcVersion)
    .maybeSingle();

  if (existingError) {
    throw new Error(`Unable to load profile baseline: ${existingError.message}`);
  }

  if (existing && existing.input_hash === inputHash) {
    return {
      baseline: existing.baseline_json as NumerologyBaseline,
      calcVersion,
      contextVersion: String(existing.context_version ?? calcVersion),
      source: "cache",
    };
  }

  const baseline = buildNumerologyBaseline({
    fullName,
    birthDate,
    calcVersion,
  });

  const contextVersion = calcVersion;

  const { error: upsertError } = await serviceClient
    .from("profile_numerology_baselines")
    .upsert(
      {
        user_id: params.userId,
        profile_id: profileId,
        calc_version: calcVersion,
        context_version: contextVersion,
        input_hash: inputHash,
        baseline_json: baseline,
        generated_at: new Date().toISOString(),
      },
      { onConflict: "user_id,profile_id,calc_version" },
    );

  if (upsertError) {
    throw new Error(`Unable to upsert profile baseline: ${upsertError.message}`);
  }

  return {
    baseline,
    calcVersion,
    contextVersion,
    source: "recomputed",
  };
}
