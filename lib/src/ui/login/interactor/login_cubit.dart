import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soulnum/src/core/model/request/auth_sign_in_request.dart';
import 'package:soulnum/src/core/failure/auth_error_mapper.dart';
import 'package:soulnum/src/core/repository/session_repository.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';
import 'package:soulnum/src/ui/login/interactor/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._sessionRepository)
    : super(const LoginState(pageState: PageState.initial));

  final SessionRepository _sessionRepository;

  void reset() {
    emit(const LoginState(pageState: PageState.initial));
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(state.copyWith(pageState: PageState.loading, errorMessage: null));
    try {
      await _sessionRepository.signInWithEmailPassword(
        AuthSignInRequest(email: email, password: password),
      );
      emit(state.copyWith(pageState: PageState.success, errorMessage: null));
    } catch (error) {
      emit(
        state.copyWith(
          pageState: PageState.failure,
          errorMessage: AuthErrorMapper.toLoginMessage(error),
        ),
      );
    }
  }
}
