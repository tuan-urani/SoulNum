/// Request model used to authenticate a user with email + password.
class AuthSignInRequest {
  const AuthSignInRequest({required this.email, required this.password});

  final String email;
  final String password;
}
