import 'package:soulnum/src/core/model/request/auth_sign_in_request.dart';
import 'package:soulnum/src/core/model/request/auth_sign_up_request.dart';
import 'package:soulnum/src/helper/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthDataSource {
  const SupabaseAuthDataSource(this._client);

  final SupabaseClient _client;

  Session? get currentSession => _client.auth.currentSession;

  Future<Session> ensureSession() async {
    final Session? session = _client.auth.currentSession;
    if (session == null) {
      throw AuthException('No active session.', code: 'session_not_found');
    }

    try {
      await AppLogger.trace<void>(
        action: 'SupabaseAuth.ensureSession.validate',
        request: <String, dynamic>{'has_session': true},
        run: () async {
          final UserResponse response = await _client.auth.getUser();
          if (response.user == null) {
            throw AuthException('Invalid session.', code: 'session_not_found');
          }
        },
        responseMapper: (_) => <String, dynamic>{'validated': true},
      );
      return session;
    } on AuthException catch (error) {
      if (_isJwtInvalid(error)) {
        await _client.auth.signOut();
        throw AuthException(
          'Session is invalid. Please sign in again.',
          code: 'session_not_found',
        );
      }
      rethrow;
    }
  }

  Future<Session> signInWithEmailPassword(AuthSignInRequest request) async {
    final String normalizedEmail = _normalizeEmail(request.email);
    return AppLogger.trace<Session>(
      action: 'SupabaseAuth.signInWithPassword',
      request: <String, dynamic>{
        'email': normalizedEmail,
        'password': request.password,
      },
      run: () async {
        final AuthResponse response = await _client.auth.signInWithPassword(
          email: normalizedEmail,
          password: request.password,
        );
        final Session? session = response.session;
        if (session == null) {
          throw AuthException(
            'Could not establish session after sign in.',
            code: 'session_not_found',
          );
        }
        _client.functions.setAuth(session.accessToken);
        return session;
      },
      responseMapper: (Session session) => <String, dynamic>{
        'user_id': session.user.id,
      },
    );
  }

  Future<Session> signUpWithEmailPassword(AuthSignUpRequest request) async {
    final String normalizedEmail = _normalizeEmail(request.email);
    return AppLogger.trace<Session>(
      action: 'SupabaseAuth.signUp',
      request: <String, dynamic>{
        'email': normalizedEmail,
        'password': request.password,
      },
      run: () async {
        final AuthResponse signUpResponse = await _client.auth.signUp(
          email: normalizedEmail,
          password: request.password,
        );
        final Session? signedUpSession = signUpResponse.session;
        if (signedUpSession != null) {
          _client.functions.setAuth(signedUpSession.accessToken);
          return signedUpSession;
        }

        final AuthResponse signInResponse = await _client.auth
            .signInWithPassword(
              email: normalizedEmail,
              password: request.password,
            );
        final Session? signedInSession = signInResponse.session;
        if (signedInSession != null) {
          _client.functions.setAuth(signedInSession.accessToken);
          return signedInSession;
        }

        throw AuthException(
          'Registration succeeded but session is pending confirmation.',
          code: 'signup_confirmation_required',
        );
      },
      responseMapper: (Session session) => <String, dynamic>{
        'user_id': session.user.id,
      },
    );
  }

  Stream<AuthState> authStateChanges() => _client.auth.onAuthStateChange;

  Future<void> signOut() async {
    await AppLogger.trace<void>(
      action: 'SupabaseAuth.signOut',
      run: () => _client.auth.signOut(),
      responseMapper: (_) => <String, dynamic>{'signed_out': true},
    );
  }

  String _normalizeEmail(String rawEmail) {
    final String normalized = rawEmail.trim().toLowerCase();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(normalized)) {
      throw AuthException('Invalid email format.', code: 'invalid_email');
    }
    return normalized;
  }

  bool _isJwtInvalid(AuthException error) {
    final String code = (error.code ?? '').toLowerCase();
    final String message = error.message.toLowerCase();
    return code.contains('jwt') ||
        code.contains('token') ||
        message.contains('invalid jwt') ||
        message.contains('jwt expired') ||
        message.contains('invalid token');
  }
}
