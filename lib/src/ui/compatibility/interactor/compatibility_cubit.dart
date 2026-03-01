import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soulnum/src/core/constants/feature_keys.dart';
import 'package:soulnum/src/core/model/request/get_reading_request.dart';
import 'package:soulnum/src/core/model/user_profile_model.dart';
import 'package:soulnum/src/core/repository/profile_repository.dart';
import 'package:soulnum/src/core/repository/reading_repository.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';
import 'package:soulnum/src/ui/compatibility/interactor/compatibility_state.dart';

class CompatibilityCubit extends Cubit<CompatibilityState> {
  CompatibilityCubit(this._profileRepository, this._readingRepository)
      : super(const CompatibilityState(pageState: PageState.initial));

  final ProfileRepository _profileRepository;
  final ReadingRepository _readingRepository;

  Future<void> loadProfiles() async {
    emit(state.copyWith(pageState: PageState.loading, errorMessage: null));
    try {
      final List<UserProfileModel> profiles = await _profileRepository.getProfiles();
      emit(
        state.copyWith(
          pageState: profiles.length < 2 ? PageState.empty : PageState.success,
          profiles: profiles,
          firstProfileId: profiles.isNotEmpty ? profiles.first.id : null,
          secondProfileId: profiles.length > 1 ? profiles[1].id : null,
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

  void selectFirst(String? profileId) {
    emit(state.copyWith(firstProfileId: profileId));
  }

  void selectSecond(String? profileId) {
    emit(state.copyWith(secondProfileId: profileId));
  }

  Future<void> runCompatibility() async {
    if (state.firstProfileId == null || state.secondProfileId == null) {
      return;
    }
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      final reading = await _readingRepository.getOrGenerateReading(
        GetReadingRequest(
          profileId: state.firstProfileId!,
          secondaryProfileId: state.secondProfileId!,
          featureKey: FeatureKeys.compatibility,
        ),
      );
      emit(
        state.copyWith(
          isSubmitting: false,
          result: reading,
          pageState: PageState.success,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: error.toString(),
          pageState: PageState.failure,
        ),
      );
    }
  }
}

