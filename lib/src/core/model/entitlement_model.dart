import 'package:equatable/equatable.dart';

class EntitlementModel extends Equatable {
  const EntitlementModel({
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

  @override
  List<Object?> get props => <Object?>[
        isVipPro,
        planCode,
        profileLimit,
        chatbotMonthlyLimit,
        adFreeDailyCycle,
        entitleStartAt,
        entitleEndAt,
      ];
}

