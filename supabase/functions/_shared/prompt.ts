import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

export type PromptVersion = {
  id: number;
  feature_key: string;
  version: string;
  model_name: string;
  prompt_template: string;
  response_schema: Record<string, unknown> | null;
};

export async function getActivePrompt(
  serviceClient: SupabaseClient,
  featureKey: string,
): Promise<PromptVersion> {
  const { data, error } = await serviceClient
    .from("prompt_versions")
    .select("id,feature_key,version,model_name,prompt_template,response_schema")
    .eq("feature_key", featureKey)
    .eq("is_active", true)
    .order("id", { ascending: false })
    .limit(1)
    .maybeSingle();

  if (error) {
    throw new Error(`Unable to fetch prompt version: ${error.message}`);
  }
  if (!data) {
    throw new Error(`No active prompt found for feature "${featureKey}"`);
  }

  return data as PromptVersion;
}

