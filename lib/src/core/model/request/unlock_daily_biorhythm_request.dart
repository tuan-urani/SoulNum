class UnlockDailyBiorhythmRequest {
  const UnlockDailyBiorhythmRequest({
    required this.profileId,
    this.unlockDate,
    this.adProof,
  });

  final String profileId;
  final DateTime? unlockDate;
  final Map<String, dynamic>? adProof;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'profile_id': profileId,
        'unlock_date': unlockDate?.toIso8601String().split('T').first,
        'ad_proof': adProof,
      };
}

