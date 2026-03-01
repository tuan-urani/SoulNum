import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soulnum/src/core/constants/feature_keys.dart';
import 'package:soulnum/src/core/model/entitlement_model.dart';
import 'package:soulnum/src/core/model/request/get_reading_request.dart';
import 'package:soulnum/src/core/model/request/unlock_daily_biorhythm_request.dart';
import 'package:soulnum/src/core/model/user_profile_model.dart';
import 'package:soulnum/src/core/repository/profile_repository.dart';
import 'package:soulnum/src/core/repository/reading_repository.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';
import 'package:soulnum/src/ui/daily_cycle/interactor/daily_cycle_state.dart';

class DailyCycleCubit extends Cubit<DailyCycleState> {
  DailyCycleCubit(this._profileRepository, this._readingRepository)
      : super(const DailyCycleState(pageState: PageState.initial));

  final ProfileRepository _profileRepository;
  final ReadingRepository _readingRepository;

  Future<void> load() async {
    emit(state.copyWith(pageState: PageState.loading, errorMessage: null));
    try {
      final List<UserProfileModel> profiles = await _profileRepository.getProfiles();
      final EntitlementModel? entitlement = await _profileRepository.getEntitlement();
      final UserProfileModel? active = profiles.cast<UserProfileModel?>().firstWhere(
            (UserProfileModel? p) => p?.isActive ?? false,
            orElse: () => profiles.isNotEmpty ? profiles.first : null,
          );
      if (active == null) {
        emit(state.copyWith(pageState: PageState.empty));
        return;
      }
      final bool isVip = entitlement?.isVipPro ?? false;
      if (isVip) {
        await _unlockAndLoad(activeProfile: active, adProof: null);
      } else {
        emit(
          state.copyWith(
            pageState: PageState.success,
            activeProfile: active,
            isLocked: true,
          ),
        );
      }
    } catch (error) {
      emit(state.copyWith(pageState: PageState.failure, errorMessage: error.toString()));
    }
  }

  Future<void> unlockWithRewardedAd() async {
    if (state.activeProfile == null) return;
    await _unlockAndLoad(
      activeProfile: state.activeProfile!,
      adProof: <String, dynamic>{
        'network': 'admob',
        'status': 'completed',
      },
    );
  }

  Future<void> _unlockAndLoad({
    required UserProfileModel activeProfile,
    required Map<String, dynamic>? adProof,
  }) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      final unlockResponse = await _readingRepository.unlockDailyBiorhythm(
        UnlockDailyBiorhythmRequest(
          profileId: activeProfile.id,
          unlockDate: DateTime.now(),
          adProof: adProof,
        ),
      );
      final reading = await _readingRepository.getOrGenerateReading(
        GetReadingRequest(
          profileId: activeProfile.id,
          featureKey: FeatureKeys.biorhythmDaily,
          targetDate: DateTime.now(),
        ),
      );
      emit(
        state.copyWith(
          pageState: PageState.success,
          activeProfile: activeProfile,
          isLocked: false,
          unlockMethod: unlockResponse.unlockMethod,
          reading: reading,
          isSubmitting: false,
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

