class DailyUnlockResponse {
  const DailyUnlockResponse({
    required this.unlocked,
    required this.unlockMethod,
    required this.unlockDate,
    this.adEventId,
  });

  final bool unlocked;
  final String unlockMethod;
  final DateTime unlockDate;
  final String? adEventId;

  factory DailyUnlockResponse.fromJson(Map<String, dynamic> json) {
    return DailyUnlockResponse(
      unlocked: json['unlocked'] as bool? ?? false,
      unlockMethod: json['unlock_method'] as String? ?? '',
      unlockDate: DateTime.tryParse(json['unlock_date'] as String? ?? '') ?? DateTime.now(),
      adEventId: json['ad_event_id'] as String?,
    );
  }
}

