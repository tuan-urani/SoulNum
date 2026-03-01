import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soulnum/src/core/constants/feature_keys.dart';
import 'package:soulnum/src/core/model/feature_tile_model.dart';
import 'package:soulnum/src/core/model/user_profile_model.dart';
import 'package:soulnum/src/core/repository/profile_repository.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';
import 'package:soulnum/src/ui/home/interactor/home_state.dart';
import 'package:soulnum/src/locale/locale_key.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._profileRepository)
    : super(HomeState(pageState: PageState.initial, tiles: _buildTiles()));

  final ProfileRepository _profileRepository;

  static List<FeatureTileModel> _buildTiles() => const <FeatureTileModel>[
    FeatureTileModel(
      titleKey: LocaleKey.homeProfileSummary,
      featureKey: 'profile_summary',
    ),
    FeatureTileModel(
      titleKey: LocaleKey.homeCoreNumbers,
      featureKey: FeatureKeys.coreNumbers,
    ),
    FeatureTileModel(
      titleKey: LocaleKey.homePsychMatrix,
      featureKey: FeatureKeys.psychMatrix,
    ),
    FeatureTileModel(
      titleKey: LocaleKey.homeBirthChart,
      featureKey: FeatureKeys.birthChart,
    ),
    FeatureTileModel(
      titleKey: LocaleKey.homeEnergyBoost,
      featureKey: FeatureKeys.energyBoost,
    ),
    FeatureTileModel(
      titleKey: LocaleKey.homeCompatibility,
      featureKey: FeatureKeys.compatibility,
    ),
    FeatureTileModel(
      titleKey: LocaleKey.homeFourPeaks,
      featureKey: FeatureKeys.fourPeaks,
    ),
    FeatureTileModel(
      titleKey: LocaleKey.homeFourChallenges,
      featureKey: FeatureKeys.fourChallenges,
    ),
    FeatureTileModel(
      titleKey: LocaleKey.homeDailyBiorhythm,
      featureKey: FeatureKeys.biorhythmDaily,
      requiresAdGate: true,
    ),
    FeatureTileModel(
      titleKey: LocaleKey.homeForecastDay,
      featureKey: FeatureKeys.forecastDay,
    ),
    FeatureTileModel(
      titleKey: LocaleKey.homeForecastMonth,
      featureKey: FeatureKeys.forecastMonth,
    ),
    FeatureTileModel(
      titleKey: LocaleKey.homeForecastYear,
      featureKey: FeatureKeys.forecastYear,
    ),
    FeatureTileModel(
      titleKey: LocaleKey.homeVipChat,
      featureKey: FeatureKeys.chatAssistant,
      requiresVip: true,
    ),
  ];

  Future<void> load() async {
    emit(state.copyWith(pageState: PageState.loading, errorMessage: null));
    try {
      final List<UserProfileModel> profiles = await _profileRepository
          .getProfiles();
      final UserProfileModel? active = profiles
          .cast<UserProfileModel?>()
          .firstWhere(
            (UserProfileModel? p) => p?.isActive ?? false,
            orElse: () => null,
          );
      final entitlement = await _profileRepository.getEntitlement();
      emit(
        state.copyWith(
          pageState: PageState.success,
          profiles: profiles,
          activeProfile: active,
          entitlement: entitlement,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          pageState: PageState.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
