import 'package:equatable/equatable.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';

class RegisterState extends Equatable {
  const RegisterState({required this.pageState, this.errorMessage});

  final PageState pageState;
  final String? errorMessage;

  RegisterState copyWith({PageState? pageState, String? errorMessage}) {
    return RegisterState(
      pageState: pageState ?? this.pageState,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[pageState, errorMessage];
}
