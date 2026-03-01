/// Request model used to register a user with email + password.
class AuthSignUpRequest {
  const AuthSignUpRequest({required this.email, required this.password});

  final String email;
  final String password;
}
