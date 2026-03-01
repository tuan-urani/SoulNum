import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static const String _name = 'SoulNum';
  static const int _maxLength = 1600;
  static const Set<String> _sensitiveKeys = <String>{
    'token',
    'receipt_or_purchase_token',
    'apikey',
    'api_key',
    'authorization',
    'password',
    'secret',
    'supabase_anon_key',
    'supabase_service_role_key',
  };

  static bool get _enabled => kDebugMode;

  static Future<T> trace<T>({
    required String action,
    Object? request,
    required Future<T> Function() run,
    Object? Function(T result)? responseMapper,
  }) async {
    if (!_enabled) {
      return run();
    }

    final Stopwatch stopwatch = Stopwatch()..start();
    _log(
      'REQ  $action',
      _safeEncode(_sanitize(request)),
    );
    try {
      final T result = await run();
      stopwatch.stop();
      final Object? mapped = responseMapper != null ? responseMapper(result) : result;
      _log(
        'RES  $action (${stopwatch.elapsedMilliseconds} ms)',
        _safeEncode(_sanitize(mapped)),
      );
      return result;
    } catch (error, stackTrace) {
      stopwatch.stop();
      _log(
        'ERR  $action (${stopwatch.elapsedMilliseconds} ms)',
        '${_safeEncode(error.toString())}\n${_safeEncode(stackTrace.toString())}',
        level: 1000,
      );
      rethrow;
    }
  }

  static void _log(String title, String message, {int level = 800}) {
    dev.log(
      _trim('$title | $message'),
      name: _name,
      level: level,
    );
  }

  static String _safeEncode(Object? value) {
    if (value == null) return 'null';
    try {
      if (value is String) return _trim(value);
      return _trim(jsonEncode(value));
    } catch (_) {
      return _trim(value.toString());
    }
  }

  static String _trim(String input) {
    if (input.length <= _maxLength) return input;
    return '${input.substring(0, _maxLength)}...<truncated>';
  }

  static Object? _sanitize(Object? value) {
    if (value == null) return null;
    if (value is Map) {
      return value.map(
        (Object? key, Object? mapValue) {
          final String keyString = (key ?? '').toString();
          final String lower = keyString.toLowerCase();
          if (_sensitiveKeys.contains(lower)) {
            return MapEntry<String, Object?>(keyString, '***');
          }
          return MapEntry<String, Object?>(keyString, _sanitize(mapValue));
        },
      );
    }
    if (value is List) {
      return value.map(_sanitize).toList(growable: false);
    }
    return value;
  }
}

