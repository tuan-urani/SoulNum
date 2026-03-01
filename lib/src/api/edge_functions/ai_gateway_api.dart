import 'package:soulnum/src/helper/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AiGatewayApi {
  const AiGatewayApi(this._client);

  final SupabaseClient _client;

  bool _isInvalidJwt(FunctionException error) {
    final String details = '${error.details}'.toLowerCase();
    final String reason = '${error.reasonPhrase}'.toLowerCase();
    return error.status == 401 &&
        (details.contains('invalid jwt') ||
            details.contains('jwt') ||
            reason.contains('unauthorized'));
  }

  Future<Map<String, dynamic>> _invokeOnce({
    required String functionName,
    required Map<String, dynamic> body,
    required String attempt,
    String? explicitAccessToken,
  }) {
    final Session? session = _client.auth.currentSession;
    final String token = explicitAccessToken ?? session?.accessToken ?? '';
    if (token.isNotEmpty) {
      // Force Functions client to use the latest user JWT.
      _client.functions.setAuth(token);
    }

    return AppLogger.trace<Map<String, dynamic>>(
      action: 'SupabaseFunction.$functionName.$attempt',
      request: body,
      run: () async {
        final FunctionResponse response = await _client.functions.invoke(
          functionName,
          headers: token.isNotEmpty
              ? <String, String>{'Authorization': 'Bearer $token'}
              : null,
          body: body,
        );
        final dynamic data = response.data;
        if (data is Map<String, dynamic>) {
          return <String, dynamic>{'_status': response.status, ...data};
        }
        if (data is Map) {
          return <String, dynamic>{
            '_status': response.status,
            ...data.cast<String, dynamic>(),
          };
        }
        return <String, dynamic>{'_status': response.status, 'data': data};
      },
      responseMapper: (Map<String, dynamic> result) => result,
    );
  }

  Future<Map<String, dynamic>> invoke({
    required String functionName,
    required Map<String, dynamic> body,
  }) async {
    if (_client.auth.currentSession == null) {
      throw AuthException('No active session.', code: 'session_not_found');
    }

    try {
      return await _invokeOnce(
        functionName: functionName,
        body: body,
        attempt: 'primary',
      );
    } on FunctionException catch (primaryError) {
      if (_isInvalidJwt(primaryError)) {
        String? refreshedToken;
        try {
          await AppLogger.trace<void>(
            action: 'SupabaseAuth.refreshSession.onInvalidJwt',
            request: <String, dynamic>{'function': functionName},
            run: () async {
              final AuthResponse refreshed = await _client.auth
                  .refreshSession();
              refreshedToken = refreshed.session?.accessToken;
            },
            responseMapper: (_) => <String, dynamic>{
              'refreshed': true,
              'has_new_access_token': (refreshedToken ?? '').isNotEmpty,
            },
          );
        } catch (_) {
          // Swallow refresh errors; final decision is based on retry result.
        }

        try {
          return await _invokeOnce(
            functionName: functionName,
            body: body,
            attempt: 'retry_after_refresh',
            explicitAccessToken: refreshedToken,
          );
        } on FunctionException catch (retryError) {
          if (_isInvalidJwt(retryError)) {
            throw AuthException(
              'Session is invalid. Please sign in again.',
              code: 'session_not_found',
            );
          }
          rethrow;
        }
      }
      rethrow;
    }
  }
}
