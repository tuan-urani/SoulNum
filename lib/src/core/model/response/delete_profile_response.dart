class DeleteProfileResponse {
  const DeleteProfileResponse({
    required this.deleted,
    required this.deletedProfileId,
    required this.remainingProfiles,
  });

  final bool deleted;
  final String deletedProfileId;
  final int remainingProfiles;

  factory DeleteProfileResponse.fromJson(Map<String, dynamic> json) {
    return DeleteProfileResponse(
      deleted: json['deleted'] as bool? ?? false,
      deletedProfileId: json['deleted_profile_id'] as String? ?? '',
      remainingProfiles: (json['remaining_profiles'] as num?)?.toInt() ?? 0,
    );
  }
}

