class AppFailure implements Exception {
  const AppFailure(this.message, {this.code});

  final String message;
  final int? code;

  @override
  String toString() => 'AppFailure(code: $code, message: $message)';
}

class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure(super.message) : super(code: 401);
}

class ForbiddenFailure extends AppFailure {
  const ForbiddenFailure(super.message) : super(code: 403);
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure(super.message) : super(code: 404);
}

class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message) : super(code: 400);
}

class QuotaExceededFailure extends AppFailure {
  const QuotaExceededFailure(super.message) : super(code: 429);
}

class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message);
}

