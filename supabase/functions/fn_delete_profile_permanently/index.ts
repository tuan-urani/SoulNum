import { fail, handleOptions, ok, readJson } from "../_shared/http.ts";
import { createServiceClient, requireAuth } from "../_shared/supabase.ts";

type DeleteProfilePayload = {
  profile_id: string;
  confirm: boolean;
};

Deno.serve(async (req) => {
  const optionsResponse = handleOptions(req);
  if (optionsResponse) return optionsResponse;

  if (req.method !== "POST") {
    return fail("Method not allowed", 405);
  }

  try {
    const { userId } = await requireAuth(req);
    const payload = await readJson<DeleteProfilePayload>(req);
    const serviceClient = createServiceClient();

    if (!payload.profile_id || payload.confirm !== true) {
      return fail("profile_id and confirm=true are required.");
    }

    const { data: profile, error: profileError } = await serviceClient
      .from("user_profiles")
      .select("id,is_active")
      .eq("id", payload.profile_id)
      .eq("owner_user_id", userId)
      .is("deleted_at", null)
      .maybeSingle();

    if (profileError) {
      throw new Error(`Failed to fetch profile: ${profileError.message}`);
    }
    if (!profile) {
      return fail("Profile not found.", 404);
    }

    const { error: deleteSessionsError } = await serviceClient
      .from("ai_chat_sessions")
      .delete()
      .eq("user_id", userId)
      .eq("profile_id", payload.profile_id);
    if (deleteSessionsError) {
      throw new Error(`Failed to delete chat sessions: ${deleteSessionsError.message}`);
    }

    const { error: deleteUnlockError } = await serviceClient
      .from("daily_biorhythm_unlocks")
      .delete()
      .eq("user_id", userId)
      .eq("profile_id", payload.profile_id);
    if (deleteUnlockError) {
      throw new Error(`Failed to delete daily unlocks: ${deleteUnlockError.message}`);
    }

    const { error: deleteAdEventError } = await serviceClient
      .from("rewarded_ad_events")
      .delete()
      .eq("user_id", userId)
      .eq("profile_id", payload.profile_id);
    if (deleteAdEventError) {
      throw new Error(`Failed to delete rewarded ad events: ${deleteAdEventError.message}`);
    }

    const { error: deleteMemoryError } = await serviceClient
      .from("ai_context_memory")
      .delete()
      .eq("user_id", userId)
      .eq("profile_id", payload.profile_id);
    if (deleteMemoryError) {
      throw new Error(`Failed to delete AI memory: ${deleteMemoryError.message}`);
    }

    const { error: deleteReadingsError } = await serviceClient
      .from("user_readings")
      .delete()
      .eq("user_id", userId)
      .or(`profile_id.eq.${payload.profile_id},secondary_profile_id.eq.${payload.profile_id}`);
    if (deleteReadingsError) {
      throw new Error(`Failed to delete user readings: ${deleteReadingsError.message}`);
    }

    const { error: deleteGeneratedError } = await serviceClient
      .from("ai_generated_contents")
      .delete()
      .eq("user_id", userId)
      .eq("profile_id", payload.profile_id);
    if (deleteGeneratedError) {
      throw new Error(`Failed to delete generated content: ${deleteGeneratedError.message}`);
    }

    const { error: deleteProfileError } = await serviceClient
      .from("user_profiles")
      .delete()
      .eq("id", payload.profile_id)
      .eq("owner_user_id", userId);
    if (deleteProfileError) {
      throw new Error(`Failed to delete profile: ${deleteProfileError.message}`);
    }

    const { error: auditError } = await serviceClient
      .from("profile_deletion_audits")
      .insert({
        user_id: userId,
        deleted_profile_id: payload.profile_id,
        reason: "user_requested",
      });
    if (auditError) {
      throw new Error(`Failed to insert deletion audit: ${auditError.message}`);
    }

    const { data: remainingProfiles, error: remainingError } = await serviceClient
      .from("user_profiles")
      .select("id,is_active")
      .eq("owner_user_id", userId)
      .is("deleted_at", null)
      .order("created_at", { ascending: false });
    if (remainingError) {
      throw new Error(`Failed to fetch remaining profiles: ${remainingError.message}`);
    }

    if (profile.is_active && remainingProfiles && remainingProfiles.length > 0) {
      const fallbackProfileId = remainingProfiles[0].id;
      await serviceClient
        .from("user_profiles")
        .update({ is_active: false })
        .eq("owner_user_id", userId);
      await serviceClient
        .from("user_profiles")
        .update({ is_active: true })
        .eq("id", fallbackProfileId)
        .eq("owner_user_id", userId);
    }

    return ok({
      deleted: true,
      deleted_profile_id: payload.profile_id,
      remaining_profiles: remainingProfiles?.length ?? 0,
    });
  } catch (error) {
    return fail(error instanceof Error ? error.message : "Internal error", 500);
  }
});

