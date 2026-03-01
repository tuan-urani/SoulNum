import 'package:get/get.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthErrorMapper {
  const AuthErrorMapper._();

  static String toLoginMessage(Object error) {
    return _resolve(error, fallback: LocaleKey.loginAuthFailedDescription.tr);
  }

  static String toRegisterMessage(Object error) {
    return _resolve(
      error,
      fallback: LocaleKey.registerAuthFailedDescription.tr,
    );
  }

  static String _resolve(Object error, {required String fallback}) {
    if (error is AuthException) {
      switch (error.code) {
        case 'session_not_found':
          return LocaleKey.loginSessionRequiredDescription.tr;
        case 'invalid_jwt':
        case 'jwt_expired':
        case 'token_expired':
          return LocaleKey.loginSessionRequiredDescription.tr;
        case 'invalid_credentials':
          return LocaleKey.loginInvalidCredentialsDescription.tr;
        case 'invalid_email':
        case 'email_address_invalid':
          return LocaleKey.loginInvalidEmailDescription.tr;
        case 'email_provider_disabled':
          return LocaleKey.loginEmailProviderDisabledDescription.tr;
        case 'signup_disabled':
          return LocaleKey.loginSignUpDisabledDescription.tr;
        case 'user_already_exists':
        case 'email_exists':
          return LocaleKey.registerEmailAlreadyUsedDescription.tr;
        case 'weak_password':
          return LocaleKey.registerWeakPasswordDescription.tr;
        case 'signup_confirmation_required':
          return LocaleKey.registerConfirmationRequiredDescription.tr;
        default:
          return fallback;
      }
    }
    return fallback;
  }
}
