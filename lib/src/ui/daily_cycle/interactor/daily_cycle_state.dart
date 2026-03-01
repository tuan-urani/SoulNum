import 'package:equatable/equatable.dart';
import 'package:soulnum/src/core/model/reading_model.dart';
import 'package:soulnum/src/core/model/user_profile_model.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';

class DailyCycleState extends Equatable {
  const DailyCycleState({
    required this.pageState,
    this.activeProfile,
    this.isLocked = true,
    this.unlockMethod,
    this.reading,
    this.errorMessage,
    this.isSubmitting = false,
  });

  final PageState pageState;
  final UserProfileModel? activeProfile;
  final bool isLocked;
  final String? unlockMethod;
  final ReadingModel? reading;
  final String? errorMessage;
  final bool isSubmitting;

  DailyCycleState copyWith({
    PageState? pageState,
    UserProfileModel? activeProfile,
    bool? isLocked,
    String? unlockMethod,
    ReadingModel? reading,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return DailyCycleState(
      pageState: pageState ?? this.pageState,
      activeProfile: activeProfile ?? this.activeProfile,
      isLocked: isLocked ?? this.isLocked,
      unlockMethod: unlockMethod ?? this.unlockMethod,
      reading: reading ?? this.reading,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        pageState,
        activeProfile,
        isLocked,
        unlockMethod,
        reading,
        errorMessage,
        isSubmitting,
      ];
}

