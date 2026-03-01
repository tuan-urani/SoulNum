class ProfileUpsertRequest {
  const ProfileUpsertRequest({
    required this.fullName,
    required this.birthDate,
    this.gender,
    this.relationLabel,
  });

  final String fullName;
  final DateTime birthDate;
  final String? gender;
  final String? relationLabel;
}

