import { fail, handleOptions, ok, readJson } from "../_shared/http.ts";
import { createServiceClient, requireAuth } from "../_shared/supabase.ts";
import { assertOwnedProfile, getEntitlement } from "../_shared/domain.ts";

type UnlockPayload = {
  profile_id: string;
  unlock_date?: string;
  ad_proof?: {
    network?: string;
    ad_unit_id?: string;
    reward_id?: string;
    status?: string;
    metadata?: Record<string, unknown>;
  };
};

function todayDateISO(): string {
  return new Date().toISOString().slice(0, 10);
}

Deno.serve(async (req) => {
  const optionsResponse = handleOptions(req);
  if (optionsResponse) return optionsResponse;

  if (req.method !== "POST") {
    return fail("Method not allowed", 405);
  }

  try {
    const { userId } = await requireAuth(req);
    const payload = await readJson<UnlockPayload>(req);
    const serviceClient = createServiceClient();

    if (!payload.profile_id) {
      return fail("profile_id is required.");
    }

    await assertOwnedProfile(serviceClient, userId, payload.profile_id);
    const entitlement = await getEntitlement(serviceClient, userId);
    const unlockDate = payload.unlock_date ?? todayDateISO();

    const { data: existingUnlock, error: unlockQueryError } = await serviceClient
      .from("daily_biorhythm_unlocks")
      .select("id,unlock_method")
      .eq("user_id", userId)
      .eq("profile_id", payload.profile_id)
      .eq("unlock_date", unlockDate)
      .maybeSingle();
    if (unlockQueryError) {
      throw new Error(`Failed to query unlock state: ${unlockQueryError.message}`);
    }

    if (existingUnlock) {
      return ok({
        unlocked: true,
        unlock_method: existingUnlock.unlock_method,
        unlock_date: unlockDate,
      });
    }

    const isVip = entitlement?.is_vip_pro === true;
    if (isVip) {
      const { error: vipUnlockError } = await serviceClient
        .from("daily_biorhythm_unlocks")
        .insert({
          user_id: userId,
          profile_id: payload.profile_id,
          unlock_date: unlockDate,
          unlock_method: "vip",
        });
      if (vipUnlockError) {
        throw new Error(`Failed to create VIP unlock: ${vipUnlockError.message}`);
      }

      return ok({
        unlocked: true,
        unlock_method: "vip",
        unlock_date: unlockDate,
      });
    }

    const adProof = payload.ad_proof;
    if (!adProof || adProof.status !== "completed" || !adProof.network) {
      return fail("Rewarded ad completion proof is required for free users.", 402);
    }

    const { data: adEvent, error: adEventError } = await serviceClient
      .from("rewarded_ad_events")
      .insert({
        user_id: userId,
        profile_id: payload.profile_id,
        placement: "daily_cycle_unlock",
        ad_network: adProof.network,
        ad_unit_id: adProof.ad_unit_id ?? null,
        status: "completed",
        provider_reward_id: adProof.reward_id ?? null,
        metadata: adProof.metadata ?? {},
      })
      .select("id")
      .single();
    if (adEventError) {
      throw new Error(`Failed to store rewarded ad event: ${adEventError.message}`);
    }

    const { error: unlockInsertError } = await serviceClient
      .from("daily_biorhythm_unlocks")
      .insert({
        user_id: userId,
        profile_id: payload.profile_id,
        unlock_date: unlockDate,
        unlock_method: "rewarded_ad",
        ad_event_id: adEvent.id,
      });
    if (unlockInsertError) {
      throw new Error(`Failed to create daily unlock record: ${unlockInsertError.message}`);
    }

    return ok({
      unlocked: true,
      unlock_method: "rewarded_ad",
      unlock_date: unlockDate,
      ad_event_id: adEvent.id,
    });
  } catch (error) {
    return fail(error instanceof Error ? error.message : "Internal error", 500);
  }
});

