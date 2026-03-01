import 'package:equatable/equatable.dart';
import 'package:soulnum/src/core/model/response/subscription_sync_response.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';

class SubscriptionState extends Equatable {
  const SubscriptionState({
    required this.pageState,
    this.isSubmitting = false,
    this.syncResult,
    this.errorMessage,
  });

  final PageState pageState;
  final bool isSubmitting;
  final SubscriptionSyncResponse? syncResult;
  final String? errorMessage;

  SubscriptionState copyWith({
    PageState? pageState,
    bool? isSubmitting,
    SubscriptionSyncResponse? syncResult,
    String? errorMessage,
  }) {
    return SubscriptionState(
      pageState: pageState ?? this.pageState,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      syncResult: syncResult ?? this.syncResult,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[pageState, isSubmitting, syncResult, errorMessage];
}

