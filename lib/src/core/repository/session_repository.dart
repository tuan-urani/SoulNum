import 'package:soulnum/src/core/model/request/auth_sign_in_request.dart';
import 'package:soulnum/src/core/model/request/auth_sign_up_request.dart';
import 'package:soulnum/src/api/supabase/supabase_auth_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionRepository {
  const SessionRepository(this._authDataSource);

  final SupabaseAuthDataSource _authDataSource;

  Future<Session> ensureSession() => _authDataSource.ensureSession();
  Future<Session> signInWithEmailPassword(AuthSignInRequest request) =>
      _authDataSource.signInWithEmailPassword(request);
  Future<Session> signUpWithEmailPassword(AuthSignUpRequest request) =>
      _authDataSource.signUpWithEmailPassword(request);

  Session? get currentSession => _authDataSource.currentSession;

  Stream<AuthState> authChanges() => _authDataSource.authStateChanges();

  Future<void> signOut() => _authDataSource.signOut();
}
