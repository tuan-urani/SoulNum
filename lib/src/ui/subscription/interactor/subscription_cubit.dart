import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soulnum/src/core/model/request/sync_subscription_request.dart';
import 'package:soulnum/src/core/repository/subscription_repository.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';
import 'package:soulnum/src/ui/subscription/interactor/subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit(this._subscriptionRepository)
      : super(const SubscriptionState(pageState: PageState.success));

  final SubscriptionRepository _subscriptionRepository;

  Future<void> activatePlan({
    required String provider,
    required String planCode,
  }) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      final result = await _subscriptionRepository.syncSubscription(
        SyncSubscriptionRequest(
          provider: provider,
          receiptOrPurchaseToken: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
          planCode: planCode,
        ),
      );
      emit(
        state.copyWith(
          isSubmitting: false,
          syncResult: result,
          pageState: PageState.success,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          pageState: PageState.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}

