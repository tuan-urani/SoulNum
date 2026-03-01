class ProfileRowResponse {
  const ProfileRowResponse({
    required this.id,
    required this.ownerUserId,
    required this.fullName,
    required this.birthDate,
    required this.isActive,
    this.gender,
    this.relationLabel,
  });

  final String id;
  final String ownerUserId;
  final String fullName;
  final DateTime birthDate;
  final bool isActive;
  final String? gender;
  final String? relationLabel;

  factory ProfileRowResponse.fromJson(Map<String, dynamic> json) {
    return ProfileRowResponse(
      id: json['id'] as String? ?? '',
      ownerUserId: json['owner_user_id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      birthDate: DateTime.tryParse(json['birth_date'] as String? ?? '') ?? DateTime.now(),
      isActive: json['is_active'] as bool? ?? false,
      gender: json['gender'] as String?,
      relationLabel: json['relation_label'] as String?,
    );
  }
}

