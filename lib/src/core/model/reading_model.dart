import 'package:equatable/equatable.dart';

class ReadingModel extends Equatable {
  const ReadingModel({
    required this.readingId,
    required this.featureKey,
    required this.result,
    required this.generatedAt,
    required this.fromCache,
    this.targetDate,
    this.targetPeriod,
  });

  final String readingId;
  final String featureKey;
  final Map<String, dynamic> result;
  final DateTime generatedAt;
  final bool fromCache;
  final DateTime? targetDate;
  final String? targetPeriod;

  @override
  List<Object?> get props => <Object?>[
    readingId,
    featureKey,
    result,
    generatedAt,
    fromCache,
    targetDate,
    targetPeriod,
  ];
}
