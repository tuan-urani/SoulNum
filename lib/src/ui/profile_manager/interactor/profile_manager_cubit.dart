import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soulnum/src/core/model/request/delete_profile_request.dart';
import 'package:soulnum/src/core/model/request/profile_upsert_request.dart';
import 'package:soulnum/src/core/repository/profile_deletion_repository.dart';
import 'package:soulnum/src/core/repository/profile_repository.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';
import 'package:soulnum/src/ui/profile_manager/interactor/profile_manager_state.dart';

class ProfileManagerCubit extends Cubit<ProfileManagerState> {
  ProfileManagerCubit(
    this._profileRepository,
    this._profileDeletionRepository,
  ) : super(const ProfileManagerState(pageState: PageState.initial));

  final ProfileRepository _profileRepository;
  final ProfileDeletionRepository _profileDeletionRepository;

  Future<void> loadProfiles() async {
    emit(state.copyWith(pageState: PageState.loading, errorMessage: null));
    try {
      final profiles = await _profileRepository.getProfiles();
      emit(
        state.copyWith(
          pageState: profiles.isEmpty ? PageState.empty : PageState.success,
          profiles: profiles,
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

  Future<void> createProfile(ProfileUpsertRequest request) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _profileRepository.createProfile(request);
      await loadProfiles();
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
      rethrow;
    }
    emit(state.copyWith(isSubmitting: false));
  }

  Future<void> setActiveProfile(String profileId) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _profileRepository.setActiveProfile(profileId);
      await loadProfiles();
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
      rethrow;
    }
    emit(state.copyWith(isSubmitting: false));
  }

  Future<void> deleteProfile(String profileId) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _profileDeletionRepository.deleteProfilePermanently(
        DeleteProfileRequest(profileId: profileId),
      );
      await loadProfiles();
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
      rethrow;
    }
    emit(state.copyWith(isSubmitting: false));
  }
}

