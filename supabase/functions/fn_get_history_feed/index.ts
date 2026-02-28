import { fail, handleOptions, ok, readJson } from "../_shared/http.ts";
import { createServiceClient, requireAuth } from "../_shared/supabase.ts";

type HistoryPayload = {
  profile_id?: string | null;
  cursor?: string | null;
  limit?: number;
};

function normalizeLimit(raw?: number): number {
  if (!raw || Number.isNaN(raw)) return 20;
  return Math.min(100, Math.max(1, raw));
}

Deno.serve(async (req) => {
  const optionsResponse = handleOptions(req);
  if (optionsResponse) return optionsResponse;

  if (req.method !== "POST") {
    return fail("Method not allowed", 405);
  }

  try {
    const { userId } = await requireAuth(req);
    const payload = await readJson<HistoryPayload>(req);
    const serviceClient = createServiceClient();
    const pageSize = normalizeLimit(payload.limit);

    let query = serviceClient
      .from("user_readings")
      .select(
        "id,user_id,profile_id,secondary_profile_id,feature_key,period_key,target_date,result_snapshot,ai_content_id,created_at",
      )
      .eq("user_id", userId)
      .order("created_at", { ascending: false })
      .limit(pageSize + 1);

    if (payload.profile_id) {
      query = query.eq("profile_id", payload.profile_id);
    }
    if (payload.cursor) {
      query = query.lt("created_at", payload.cursor);
    }

    const { data: rows, error } = await query;
    if (error) {
      throw new Error(`Failed to fetch history: ${error.message}`);
    }

    const results = rows ?? [];
    const hasNext = results.length > pageSize;
    const pageRows = hasNext ? results.slice(0, pageSize) : results;
    const nextCursor = hasNext ? pageRows[pageRows.length - 1]?.created_at ?? null : null;

    const aiIds = pageRows.map((r) => r.ai_content_id).filter(Boolean);
    const aiMap = new Map<string, Record<string, unknown>>();
    if (aiIds.length > 0) {
      const { data: aiRows, error: aiError } = await serviceClient
        .from("ai_generated_contents")
        .select("id,feature_key,generated_at,output_json")
        .in("id", aiIds);
      if (aiError) {
        throw new Error(`Failed to fetch AI content details: ${aiError.message}`);
      }
      for (const row of aiRows ?? []) {
        aiMap.set(row.id, row as Record<string, unknown>);
      }
    }

    return ok({
      items: pageRows.map((row) => ({
        id: row.id,
        profile_id: row.profile_id,
        secondary_profile_id: row.secondary_profile_id,
        feature_key: row.feature_key,
        period_key: row.period_key,
        target_date: row.target_date,
        result_snapshot: row.result_snapshot,
        created_at: row.created_at,
        ai_content: row.ai_content_id ? aiMap.get(row.ai_content_id) ?? null : null,
      })),
      next_cursor: nextCursor,
    });
  } catch (error) {
    return fail(error instanceof Error ? error.message : "Internal error", 500);
  }
});

