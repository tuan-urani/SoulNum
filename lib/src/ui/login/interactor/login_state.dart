import 'package:equatable/equatable.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';

class LoginState extends Equatable {
  const LoginState({
    required this.pageState,
    this.errorMessage,
  });

  final PageState pageState;
  final String? errorMessage;

  LoginState copyWith({
    PageState? pageState,
    String? errorMessage,
  }) {
    return LoginState(
      pageState: pageState ?? this.pageState,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[pageState, errorMessage];
}

