import 'package:equatable/equatable.dart';
import 'package:soulnum/src/core/model/reading_model.dart';
import 'package:soulnum/src/core/model/user_profile_model.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';

class CompatibilityState extends Equatable {
  const CompatibilityState({
    required this.pageState,
    this.profiles = const <UserProfileModel>[],
    this.firstProfileId,
    this.secondProfileId,
    this.result,
    this.errorMessage,
    this.isSubmitting = false,
  });

  final PageState pageState;
  final List<UserProfileModel> profiles;
  final String? firstProfileId;
  final String? secondProfileId;
  final ReadingModel? result;
  final String? errorMessage;
  final bool isSubmitting;

  CompatibilityState copyWith({
    PageState? pageState,
    List<UserProfileModel>? profiles,
    String? firstProfileId,
    String? secondProfileId,
    ReadingModel? result,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return CompatibilityState(
      pageState: pageState ?? this.pageState,
      profiles: profiles ?? this.profiles,
      firstProfileId: firstProfileId ?? this.firstProfileId,
      secondProfileId: secondProfileId ?? this.secondProfileId,
      result: result ?? this.result,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        pageState,
        profiles,
        firstProfileId,
        secondProfileId,
        result,
        errorMessage,
        isSubmitting,
      ];
}

