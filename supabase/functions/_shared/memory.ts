import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

export type MemoryFact = {
  type: string;
  key: string;
  value: Record<string, unknown>;
  confidence?: number;
};

const ALLOWED_MEMORY_TYPES = new Set<string>([
  "trait",
  "goal",
  "pattern",
  "preference",
  "risk_note",
  "compatibility",
  "energy_state",
  "decision_hint",
]);

function normalizeMemoryType(rawType: unknown): string | null {
  if (typeof rawType !== "string") return null;
  const normalized = rawType.trim().toLowerCase();
  if (!normalized) return null;
  if (!ALLOWED_MEMORY_TYPES.has(normalized)) {
    return "pattern";
  }
  return normalized;
}

function normalizeMemoryKey(rawKey: unknown): string | null {
  if (typeof rawKey !== "string") return null;
  const normalized = rawKey
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9_\-\s]/g, "")
    .replace(/\s+/g, "_")
    .replace(/_+/g, "_")
    .slice(0, 120);

  return normalized.length > 0 ? normalized : null;
}

function normalizeConfidence(raw: unknown): number {
  if (typeof raw !== "number" || Number.isNaN(raw)) return 0.6;
  return Math.min(1, Math.max(0, raw));
}

export async function loadActiveMemory(
  serviceClient: SupabaseClient,
  userId: string,
  profileId: string,
  limit = 20,
): Promise<Array<Record<string, unknown>>> {
  const { data, error } = await serviceClient
    .from("ai_context_memory")
    .select("memory_type,memory_key,memory_value,confidence_score,last_used_at")
    .eq("user_id", userId)
    .eq("profile_id", profileId)
    .eq("is_active", true)
    .order("confidence_score", { ascending: false })
    .order("last_used_at", { ascending: false, nullsFirst: false })
    .limit(limit);

  if (error) {
    throw new Error(`Unable to fetch memory: ${error.message}`);
  }

  return data ?? [];
}

export async function touchMemory(
  serviceClient: SupabaseClient,
  userId: string,
  profileId: string,
): Promise<void> {
  const { error } = await serviceClient
    .from("ai_context_memory")
    .update({ last_used_at: new Date().toISOString() })
    .eq("user_id", userId)
    .eq("profile_id", profileId)
    .eq("is_active", true);

  if (error) {
    throw new Error(`Unable to touch memory: ${error.message}`);
  }
}

export async function upsertMemoryFacts(
  serviceClient: SupabaseClient,
  params: {
    userId: string;
    profileId: string | null;
    sourceContentId?: string | null;
    sourceReadingId?: string | null;
    facts: MemoryFact[];
  },
): Promise<void> {
  if (!params.facts.length) {
    return;
  }

  const rows = params.facts.map((fact) => ({
    user_id: params.userId,
    profile_id: params.profileId,
    memory_type: fact.type,
    memory_key: fact.key,
    memory_value: fact.value,
    confidence_score: fact.confidence ?? 0.6,
    source_content_id: params.sourceContentId ?? null,
    source_reading_id: params.sourceReadingId ?? null,
    is_active: true,
    last_used_at: new Date().toISOString(),
  }));

  const { error } = await serviceClient
    .from("ai_context_memory")
    .upsert(rows, { onConflict: "user_id,profile_id,memory_type,memory_key" });

  if (error) {
    throw new Error(`Unable to upsert memory: ${error.message}`);
  }
}

export function parseMemoryFactsFromOutput(output: Record<string, unknown>): MemoryFact[] {
  const raw = output.memory_facts;
  if (!Array.isArray(raw)) {
    return [];
  }

  const facts: MemoryFact[] = [];
  for (const item of raw) {
    if (!item || typeof item !== "object") continue;
    const maybe = item as Record<string, unknown>;
    const type = normalizeMemoryType(maybe.type);
    const key = normalizeMemoryKey(maybe.key);
    const value = typeof maybe.value === "object" && maybe.value !== null
      ? (maybe.value as Record<string, unknown>)
      : null;
    const confidence = normalizeConfidence(maybe.confidence);
    if (type && key && value) {
      facts.push({ type, key, value, confidence });
    }
  }
  return facts;
}
