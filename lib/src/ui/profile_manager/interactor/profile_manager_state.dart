import 'package:equatable/equatable.dart';
import 'package:soulnum/src/core/model/user_profile_model.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';

class ProfileManagerState extends Equatable {
  const ProfileManagerState({
    required this.pageState,
    this.profiles = const <UserProfileModel>[],
    this.isSubmitting = false,
    this.errorMessage,
  });

  final PageState pageState;
  final List<UserProfileModel> profiles;
  final bool isSubmitting;
  final String? errorMessage;

  UserProfileModel? get activeProfile {
    for (final UserProfileModel profile in profiles) {
      if (profile.isActive) return profile;
    }
    return null;
  }

  ProfileManagerState copyWith({
    PageState? pageState,
    List<UserProfileModel>? profiles,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return ProfileManagerState(
      pageState: pageState ?? this.pageState,
      profiles: profiles ?? this.profiles,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        pageState,
        profiles,
        isSubmitting,
        errorMessage,
      ];
}

