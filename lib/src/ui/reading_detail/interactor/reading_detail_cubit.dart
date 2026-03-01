import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soulnum/src/core/model/request/get_reading_request.dart';
import 'package:soulnum/src/core/model/user_profile_model.dart';
import 'package:soulnum/src/core/repository/profile_repository.dart';
import 'package:soulnum/src/core/repository/reading_repository.dart';
import 'package:soulnum/src/core/repository/session_repository.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';
import 'package:soulnum/src/ui/reading_detail/interactor/reading_detail_state.dart';

class ReadingDetailCubit extends Cubit<ReadingDetailState> {
  ReadingDetailCubit(
    this._readingRepository,
    this._profileRepository,
    this._sessionRepository,
  ) : super(const ReadingDetailState(pageState: PageState.initial));

  final ReadingRepository _readingRepository;
  final ProfileRepository _profileRepository;
  final SessionRepository _sessionRepository;

  Future<void> load({
    required String featureKey,
    required String titleKey,
    String? secondaryProfileId,
  }) async {
    emit(
      state.copyWith(
        pageState: PageState.loading,
        featureKey: featureKey,
        titleKey: titleKey,
        errorMessage: null,
      ),
    );
    try {
      final List<UserProfileModel> profiles = await _profileRepository
          .getProfiles();
      final UserProfileModel? active = profiles
          .cast<UserProfileModel?>()
          .firstWhere(
            (UserProfileModel? p) => p?.isActive ?? false,
            orElse: () => profiles.isNotEmpty ? profiles.first : null,
          );
      if (active == null) {
        if (_sessionRepository.currentSession == null) {
          emit(
            state.copyWith(
              pageState: PageState.unauthorized,
              errorMessage: 'Unauthorized',
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            pageState: PageState.empty,
            errorMessage: 'No active profile',
          ),
        );
        return;
      }
      final reading = await _readingRepository.getOrGenerateReading(
        GetReadingRequest(
          profileId: active.id,
          featureKey: featureKey,
          secondaryProfileId: secondaryProfileId,
        ),
      );
      emit(
        state.copyWith(
          pageState: PageState.success,
          reading: reading,
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
