import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soulnum/src/core/model/history_item_model.dart';
import 'package:soulnum/src/core/model/request/get_history_feed_request.dart';
import 'package:soulnum/src/core/repository/history_repository.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';
import 'package:soulnum/src/ui/history/interactor/history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit(this._historyRepository) : super(const HistoryState(pageState: PageState.initial));

  final HistoryRepository _historyRepository;

  Future<void> loadInitial() async {
    emit(state.copyWith(pageState: PageState.loading, errorMessage: null));
    try {
      final (items, nextCursor) = await _historyRepository.getHistory(const GetHistoryFeedRequest(limit: 20));
      emit(
        state.copyWith(
          pageState: items.isEmpty ? PageState.empty : PageState.success,
          items: items,
          nextCursor: nextCursor,
        ),
      );
    } catch (error) {
      emit(state.copyWith(pageState: PageState.failure, errorMessage: error.toString()));
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.nextCursor == null) return;
    emit(state.copyWith(isLoadingMore: true, errorMessage: null));
    try {
      final (items, nextCursor) = await _historyRepository.getHistory(
        GetHistoryFeedRequest(limit: 20, cursor: state.nextCursor),
      );
      emit(
        state.copyWith(
          pageState: PageState.success,
          items: <HistoryItemModel>[
            ...state.items,
            ...items,
          ],
          nextCursor: nextCursor,
          isLoadingMore: false,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isLoadingMore: false, errorMessage: error.toString()));
    }
  }
}
