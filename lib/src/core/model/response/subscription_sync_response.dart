class SubscriptionSyncResponse {
  const SubscriptionSyncResponse({
    required this.isVipPro,
    required this.chatbotMonthlyLimit,
    required this.adFreeDailyCycle,
    this.planCode,
    this.profileLimit,
    this.entitleStartAt,
    this.entitleEndAt,
  });

  final bool isVipPro;
  final String? planCode;
  final int? profileLimit;
  final int chatbotMonthlyLimit;
  final bool adFreeDailyCycle;
  final DateTime? entitleStartAt;
  final DateTime? entitleEndAt;

  factory SubscriptionSyncResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionSyncResponse(
      isVipPro: json['is_vip_pro'] as bool? ?? false,
      planCode: json['plan_code'] as String?,
      profileLimit: (json['profile_limit'] as num?)?.toInt(),
      chatbotMonthlyLimit: (json['chatbot_monthly_limit'] as num?)?.toInt() ?? 0,
      adFreeDailyCycle: json['ad_free_daily_cycle'] as bool? ?? false,
      entitleStartAt: DateTime.tryParse(json['entitle_start_at'] as String? ?? ''),
      entitleEndAt: DateTime.tryParse(json['entitle_end_at'] as String? ?? ''),
    );
  }
}

