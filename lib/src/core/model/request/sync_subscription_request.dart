class SyncSubscriptionRequest {
  const SyncSubscriptionRequest({
    required this.provider,
    required this.receiptOrPurchaseToken,
    required this.planCode,
  });

  final String provider;
  final String receiptOrPurchaseToken;
  final String planCode;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'provider': provider,
        'receipt_or_purchase_token': receiptOrPurchaseToken,
        'plan_code': planCode,
      };
}

