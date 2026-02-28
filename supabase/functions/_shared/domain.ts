import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

export async function assertOwnedProfile(
  serviceClient: SupabaseClient,
  userId: string,
  profileId: string,
): Promise<Record<string, unknown>> {
  const { data, error } = await serviceClient
    .from("user_profiles")
    .select("*")
    .eq("id", profileId)
    .eq("owner_user_id", userId)
    .is("deleted_at", null)
    .maybeSingle();

  if (error) {
    throw new Error(`Unable to load profile: ${error.message}`);
  }
  if (!data) {
    throw new Error("Profile not found or access denied.");
  }
  return data;
}

export async function getEntitlement(
  serviceClient: SupabaseClient,
  userId: string,
): Promise<Record<string, unknown> | null> {
  const { data, error } = await serviceClient
    .from("subscription_entitlements")
    .select("*")
    .eq("user_id", userId)
    .maybeSingle();

  if (error) {
    throw new Error(`Unable to load entitlements: ${error.message}`);
  }

  return data;
}

