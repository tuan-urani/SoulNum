class GetReadingRequest {
  const GetReadingRequest({
    required this.profileId,
    required this.featureKey,
    this.targetPeriod,
    this.targetDate,
    this.secondaryProfileId,
    this.forceRefresh = false,
  });

  final String profileId;
  final String featureKey;
  final String? targetPeriod;
  final DateTime? targetDate;
  final String? secondaryProfileId;
  final bool forceRefresh;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'profile_id': profileId,
        'feature_key': featureKey,
        'target_period': targetPeriod,
        'target_date': targetDate?.toIso8601String().split('T').first,
        'secondary_profile_id': secondaryProfileId,
        'force_refresh': forceRefresh,
      };
}

