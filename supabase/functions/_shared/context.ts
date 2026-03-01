import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

export type GlobalContextBlock = {
  context_key: string;
  scope: string;
  feature_key: string | null;
  locale: string;
  context_version: string;
  priority: number;
  content: Record<string, unknown>;
};

export async function loadGlobalContextBlocks(
  serviceClient: SupabaseClient,
  params: {
    featureKey: string;
    locale?: string;
  },
): Promise<{
  blocks: GlobalContextBlock[];
  contextVersion: string;
}> {
  const locale = params.locale ?? "vi-VN";

  const { data, error } = await serviceClient
    .from("global_context_blocks")
    .select("context_key,scope,feature_key,locale,context_version,priority,content")
    .eq("is_active", true)
    .eq("locale", locale)
    .order("priority", { ascending: true })
    .order("id", { ascending: true });

  if (error) {
    throw new Error(`Unable to fetch global context blocks: ${error.message}`);
  }

  const rows = (data ?? []) as Array<Record<string, unknown>>;
  const blocks = rows
    .filter((row) => {
      const scope = String(row.scope ?? "");
      if (scope === "global") return true;
      return scope === "feature" && String(row.feature_key ?? "") === params.featureKey;
    })
    .map((row) => ({
      context_key: String(row.context_key ?? ""),
      scope: String(row.scope ?? ""),
      feature_key: row.feature_key ? String(row.feature_key) : null,
      locale: String(row.locale ?? locale),
      context_version: String(row.context_version ?? "ctx:none"),
      priority: Number(row.priority ?? 100),
      content: (row.content ?? {}) as Record<string, unknown>,
    }));

  const uniqueVersions = [...new Set(blocks.map((b) => b.context_version).filter(Boolean))].sort();
  const contextVersion = uniqueVersions.length > 0 ? uniqueVersions.join("|") : "ctx:none";

  return { blocks, contextVersion };
}

export function buildContextVersion(params: {
  globalContextVersion: string;
  baselineVersions: Array<string | null | undefined>;
}): string {
  const versions: string[] = [params.globalContextVersion];
  for (const baselineVersion of params.baselineVersions) {
    if (baselineVersion && baselineVersion.trim().length > 0) {
      versions.push(baselineVersion.trim());
    }
  }
  return [...new Set(versions)].join("|");
}
