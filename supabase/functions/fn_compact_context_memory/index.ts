import { fail, handleOptions, ok, readJson } from "../_shared/http.ts";
import { createServiceClient, requireCronSecret } from "../_shared/supabase.ts";

type CompactPayload = {
  batch_size?: number;
};

function toIsoDaysAgo(days: number): string {
  const d = new Date();
  d.setUTCDate(d.getUTCDate() - days);
  return d.toISOString();
}

Deno.serve(async (req) => {
  const optionsResponse = handleOptions(req);
  if (optionsResponse) return optionsResponse;

  if (req.method !== "POST") {
    return fail("Method not allowed", 405);
  }

  try {
    await requireCronSecret(req);
    const payload = await readJson<CompactPayload>(req).catch(() => ({ batch_size: 500 }));
    const serviceClient = createServiceClient();
    const batchSize = Math.min(2000, Math.max(1, payload.batch_size ?? 500));

    const staleThreshold = toIsoDaysAgo(90);
    const oldUnusedThreshold = toIsoDaysAgo(180);

    const { data: staleRows, error: staleError } = await serviceClient
      .from("ai_context_memory")
      .select("id,user_id,profile_id,memory_type,memory_key,memory_value")
      .eq("is_active", true)
      .or(`last_used_at.lt.${staleThreshold},and(last_used_at.is.null,created_at.lt.${oldUnusedThreshold})`)
      .order("updated_at", { ascending: true })
      .limit(batchSize);

    if (staleError) {
      throw new Error(`Failed to load stale memories: ${staleError.message}`);
    }

    const candidates = staleRows ?? [];
    if (!candidates.length) {
      return ok({
        processed_users: 0,
        memories_archived: 0,
      });
    }

    const ids = candidates.map((item) => item.id);
    const userSet = new Set(candidates.map((item) => item.user_id));

    const { error: deactivateError } = await serviceClient
      .from("ai_context_memory")
      .update({
        is_active: false,
      })
      .in("id", ids);

    if (deactivateError) {
      throw new Error(`Failed to deactivate memories: ${deactivateError.message}`);
    }

    return ok({
      processed_users: userSet.size,
      memories_archived: ids.length,
    });
  } catch (error) {
    return fail(error instanceof Error ? error.message : "Internal error", 500);
  }
});

