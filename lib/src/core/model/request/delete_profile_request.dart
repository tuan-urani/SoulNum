class DeleteProfileRequest {
  const DeleteProfileRequest({
    required this.profileId,
    this.confirm = true,
  });

  final String profileId;
  final bool confirm;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'profile_id': profileId,
        'confirm': confirm,
      };
}

