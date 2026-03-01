import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soulnum/src/core/failure/auth_error_mapper.dart';
import 'package:soulnum/src/core/model/request/auth_sign_up_request.dart';
import 'package:soulnum/src/core/repository/session_repository.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';
import 'package:soulnum/src/ui/register/interactor/register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._sessionRepository)
    : super(const RegisterState(pageState: PageState.initial));

  final SessionRepository _sessionRepository;

  void reset() {
    emit(const RegisterState(pageState: PageState.initial));
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  Future<void> signUp({required String email, required String password}) async {
    emit(state.copyWith(pageState: PageState.loading, errorMessage: null));
    try {
      await _sessionRepository.signUpWithEmailPassword(
        AuthSignUpRequest(email: email, password: password),
      );
      emit(state.copyWith(pageState: PageState.success, errorMessage: null));
    } catch (error) {
      emit(
        state.copyWith(
          pageState: PageState.failure,
          errorMessage: AuthErrorMapper.toRegisterMessage(error),
        ),
      );
    }
  }
}
