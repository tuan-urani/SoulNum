import { fail, handleOptions, ok, readJson } from "../_shared/http.ts";
import { createServiceClient, requireAuth } from "../_shared/supabase.ts";
import { sha256Hex } from "../_shared/hash.ts";

type SyncSubscriptionPayload = {
  provider: "apple" | "google";
  receipt_or_purchase_token: string;
  plan_code: "vip_pro_monthly" | "vip_pro_yearly";
};

type VerificationResult = {
  providerOriginalTxId: string;
  status: "active" | "grace_period" | "canceled" | "expired" | "pending";
  currentPeriodStart: string;
  currentPeriodEnd: string;
  autoRenew: boolean;
  rawPayload: Record<string, unknown>;
};

function addDays(start: Date, days: number): Date {
  const end = new Date(start);
  end.setUTCDate(end.getUTCDate() + days);
  return end;
}

async function verifyPurchase(payload: SyncSubscriptionPayload): Promise<VerificationResult> {
  const verifyUrl = Deno.env.get("BILLING_VERIFY_URL");

  if (verifyUrl) {
    const response = await fetch(verifyUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      const body = await response.text();
      throw new Error(`Billing verification failed (${response.status}): ${body}`);
    }

    const data = (await response.json()) as Record<string, unknown>;
    return {
      providerOriginalTxId: String(data.provider_original_tx_id),
      status: (data.status as VerificationResult["status"]) ?? "pending",
      currentPeriodStart: String(data.current_period_start),
      currentPeriodEnd: String(data.current_period_end),
      autoRenew: Boolean(data.auto_renew),
      rawPayload: data,
    };
  }

  const now = new Date();
  const periodDays = payload.plan_code === "vip_pro_yearly" ? 365 : 30;
  const txHash = await sha256Hex({
    provider: payload.provider,
    token: payload.receipt_or_purchase_token,
    plan: payload.plan_code,
  });

  return {
    providerOriginalTxId: `${payload.provider}_${txHash.slice(0, 24)}`,
    status: "active",
    currentPeriodStart: now.toISOString(),
    currentPeriodEnd: addDays(now, periodDays).toISOString(),
    autoRenew: true,
    rawPayload: {
      mode: "mock_verification",
      warning: "BILLING_VERIFY_URL not configured. Using deterministic mock verification.",
    },
  };
}

Deno.serve(async (req) => {
  const optionsResponse = handleOptions(req);
  if (optionsResponse) return optionsResponse;

  if (req.method !== "POST") {
    return fail("Method not allowed", 405);
  }

  try {
    const { userId } = await requireAuth(req);
    const payload = await readJson<SyncSubscriptionPayload>(req);
    const serviceClient = createServiceClient();

    if (!payload.provider || !payload.plan_code || !payload.receipt_or_purchase_token) {
      return fail("provider, plan_code, and receipt_or_purchase_token are required.");
    }

    if (!["apple", "google"].includes(payload.provider)) {
      return fail("Invalid provider.");
    }
    if (!["vip_pro_monthly", "vip_pro_yearly"].includes(payload.plan_code)) {
      return fail("Invalid plan_code.");
    }

    const verification = await verifyPurchase(payload);

    const { data: subscription, error: subscriptionError } = await serviceClient
      .from("subscriptions")
      .upsert(
        {
          user_id: userId,
          provider: payload.provider,
          provider_original_tx_id: verification.providerOriginalTxId,
          plan_code: payload.plan_code,
          status: verification.status,
          current_period_start: verification.currentPeriodStart,
          current_period_end: verification.currentPeriodEnd,
          auto_renew: verification.autoRenew,
          last_verified_at: new Date().toISOString(),
        },
        {
          onConflict: "provider,provider_original_tx_id",
        },
      )
      .select("id,status,plan_code,current_period_end")
      .single();

    if (subscriptionError) {
      throw new Error(`Failed to upsert subscription: ${subscriptionError.message}`);
    }

    const { error: eventError } = await serviceClient
      .from("subscription_events")
      .insert({
        subscription_id: subscription.id,
        user_id: userId,
        provider: payload.provider,
        event_type: verification.status,
        event_time: new Date().toISOString(),
        raw_payload: verification.rawPayload,
      });

    if (eventError) {
      throw new Error(`Failed to insert subscription event: ${eventError.message}`);
    }

    const activeStatuses = new Set(["active", "grace_period"]);
    const isVipPro = activeStatuses.has(subscription.status);
    const defaultChatLimit = Number(Deno.env.get("VIP_CHATBOT_MONTHLY_LIMIT") ?? 200);

    const { data: entitlement, error: entitlementError } = await serviceClient
      .from("subscription_entitlements")
      .upsert({
        user_id: userId,
        is_vip_pro: isVipPro,
        plan_code: isVipPro ? subscription.plan_code : null,
        entitle_start_at: isVipPro ? verification.currentPeriodStart : null,
        entitle_end_at: isVipPro ? subscription.current_period_end : null,
        profile_limit: isVipPro ? null : 2,
        chatbot_monthly_limit: isVipPro ? defaultChatLimit : 0,
        ad_free_daily_cycle: isVipPro,
      })
      .select(
        "is_vip_pro,plan_code,entitle_start_at,entitle_end_at,profile_limit,chatbot_monthly_limit,ad_free_daily_cycle",
      )
      .single();

    if (entitlementError) {
      throw new Error(`Failed to upsert entitlement: ${entitlementError.message}`);
    }

    return ok({
      is_vip_pro: entitlement.is_vip_pro,
      plan_code: entitlement.plan_code,
      entitle_start_at: entitlement.entitle_start_at,
      entitle_end_at: entitlement.entitle_end_at,
      profile_limit: entitlement.profile_limit,
      chatbot_monthly_limit: entitlement.chatbot_monthly_limit,
      ad_free_daily_cycle: entitlement.ad_free_daily_cycle,
      verification_mode: Deno.env.get("BILLING_VERIFY_URL") ? "server_verification" : "mock_verification",
    });
  } catch (error) {
    return fail(error instanceof Error ? error.message : "Internal error", 500);
  }
});

