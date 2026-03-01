import 'package:equatable/equatable.dart';
import 'package:soulnum/src/core/model/history_item_model.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';

class HistoryState extends Equatable {
  const HistoryState({
    required this.pageState,
    this.items = const <HistoryItemModel>[],
    this.nextCursor,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final PageState pageState;
  final List<HistoryItemModel> items;
  final DateTime? nextCursor;
  final bool isLoadingMore;
  final String? errorMessage;

  HistoryState copyWith({
    PageState? pageState,
    List<HistoryItemModel>? items,
    DateTime? nextCursor,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return HistoryState(
      pageState: pageState ?? this.pageState,
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        pageState,
        items,
        nextCursor,
        isLoadingMore,
        errorMessage,
      ];
}

