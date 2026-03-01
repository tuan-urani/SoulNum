import 'package:equatable/equatable.dart';
import 'package:soulnum/src/core/model/entitlement_model.dart';
import 'package:soulnum/src/core/model/feature_tile_model.dart';
import 'package:soulnum/src/core/model/user_profile_model.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';

class HomeState extends Equatable {
  static const Object _activeProfileSentinel = Object();

  const HomeState({
    required this.pageState,
    required this.tiles,
    this.profiles = const <UserProfileModel>[],
    this.activeProfile,
    this.entitlement,
    this.errorMessage,
  });

  final PageState pageState;
  final List<FeatureTileModel> tiles;
  final List<UserProfileModel> profiles;
  final UserProfileModel? activeProfile;
  final EntitlementModel? entitlement;
  final String? errorMessage;

  HomeState copyWith({
    PageState? pageState,
    List<FeatureTileModel>? tiles,
    List<UserProfileModel>? profiles,
    Object? activeProfile = _activeProfileSentinel,
    EntitlementModel? entitlement,
    String? errorMessage,
  }) {
    return HomeState(
      pageState: pageState ?? this.pageState,
      tiles: tiles ?? this.tiles,
      profiles: profiles ?? this.profiles,
      activeProfile: identical(activeProfile, _activeProfileSentinel)
          ? this.activeProfile
          : activeProfile as UserProfileModel?,
      entitlement: entitlement ?? this.entitlement,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    pageState,
    tiles,
    profiles,
    activeProfile,
    entitlement,
    errorMessage,
  ];
}
