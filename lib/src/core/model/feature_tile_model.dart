import 'package:equatable/equatable.dart';

class FeatureTileModel extends Equatable {
  const FeatureTileModel({
    required this.titleKey,
    required this.featureKey,
    this.requiresVip = false,
    this.requiresAdGate = false,
  });

  final String titleKey;
  final String featureKey;
  final bool requiresVip;
  final bool requiresAdGate;

  @override
  List<Object?> get props => <Object?>[
        titleKey,
        featureKey,
        requiresVip,
        requiresAdGate,
      ];
}

