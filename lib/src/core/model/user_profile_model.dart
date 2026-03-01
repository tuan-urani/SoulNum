import 'package:equatable/equatable.dart';

class UserProfileModel extends Equatable {
  const UserProfileModel({
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

  @override
  List<Object?> get props => <Object?>[
        id,
        ownerUserId,
        fullName,
        birthDate,
        isActive,
        gender,
        relationLabel,
      ];
}

