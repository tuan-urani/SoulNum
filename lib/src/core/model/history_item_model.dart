import 'package:equatable/equatable.dart';

class HistoryItemModel extends Equatable {
  const HistoryItemModel({
    required this.id,
    required this.featureKey,
    required this.createdAt,
    required this.resultSnapshot,
    this.targetDate,
    this.periodKey,
  });

  final String id;
  final String featureKey;
  final DateTime createdAt;
  final Map<String, dynamic> resultSnapshot;
  final DateTime? targetDate;
  final String? periodKey;

  @override
  List<Object?> get props => <Object?>[
        id,
        featureKey,
        createdAt,
        resultSnapshot,
        targetDate,
        periodKey,
      ];
}

