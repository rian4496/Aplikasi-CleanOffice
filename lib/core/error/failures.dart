/// Failures untuk presentation layer
/// Digunakan untuk menampilkan error ke user dengan format yang user-friendly
library;

import 'package:equatable/equatable.dart';
import 'exceptions.dart';

/// Base failure class
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => message;
}

// ==================== SPECIFIC FAILURES ====================

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});

  factory AuthFailure.fromException(AuthException e) {
    return AuthFailure(message: e.message, code: e.code);
  }
}

class FirestoreFailure extends Failure {
  const FirestoreFailure({required super.message, super.code});

  factory FirestoreFailure.fromException(FirestoreException e) {
    return FirestoreFailure(message: e.message, code: e.code);
  }
}

class StorageFailure extends Failure {
  const StorageFailure({required super.message, super.code});

  factory StorageFailure.fromException(StorageException e) {
    return StorageFailure(message: e.message, code: e.code);
  }
}

class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    this.fieldErrors,
    super.code,
  });

  bool hasFieldError(String field) => fieldErrors?.containsKey(field) ?? false;
  String? getFieldError(String field) => fieldErrors?[field];

  @override
  List<Object?> get props => [message, code, fieldErrors];

  factory ValidationFailure.fromException(ValidationException e) {
    return ValidationFailure(
      message: e.message,
      fieldErrors: e.fieldErrors,
      code: e.code,
    );
  }
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message, super.code});

  factory NotFoundFailure.fromException(NotFoundException e) {
    return NotFoundFailure(message: e.message, code: e.code);
  }
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({required super.message, super.code});

  factory UnauthorizedFailure.fromException(UnauthorizedException e) {
    return UnauthorizedFailure(message: e.message, code: e.code);
  }
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});

  factory NetworkFailure.fromException(NetworkException e) {
    return NetworkFailure(message: e.message, code: e.code);
  }

  factory NetworkFailure.noConnection() {
    return const NetworkFailure(
      message: 'Tidak ada koneksi internet',
      code: 'no-connection',
    );
  }
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    this.statusCode,
    super.code,
  });

  @override
  List<Object?> get props => [message, code, statusCode];

  factory ServerFailure.fromException(ServerException e) {
    return ServerFailure(
      message: e.message,
      statusCode: e.statusCode,
      code: e.code,
    );
  }
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});

  factory CacheFailure.fromException(CacheException e) {
    return CacheFailure(message: e.message, code: e.code);
  }
}

class FormatFailure extends Failure {
  const FormatFailure({required super.message, super.code});

  factory FormatFailure.fromException(FormatException e) {
    return FormatFailure(message: e.message, code: e.code);
  }
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message, super.code});

  factory UnexpectedFailure.generic() {
    return const UnexpectedFailure(
      message: 'Terjadi kesalahan yang tidak terduga',
      code: 'unexpected',
    );
  }
}

// ==================== CONVERSION ====================

/// Convert Exception to Failure
Failure exceptionToFailure(AppException exception) {
  if (exception is AuthException) {
    return AuthFailure.fromException(exception);
  } else if (exception is FirestoreException) {
    return FirestoreFailure.fromException(exception);
  } else if (exception is StorageException) {
    return StorageFailure.fromException(exception);
  } else if (exception is ValidationException) {
    return ValidationFailure.fromException(exception);
  } else if (exception is NotFoundException) {
    return NotFoundFailure.fromException(exception);
  } else if (exception is UnauthorizedException) {
    return UnauthorizedFailure.fromException(exception);
  } else if (exception is NetworkException) {
    return NetworkFailure.fromException(exception);
  } else if (exception is ServerException) {
    return ServerFailure.fromException(exception);
  } else if (exception is CacheException) {
    return CacheFailure.fromException(exception);
  } else if (exception is FormatException) {
    return FormatFailure.fromException(exception);
  }

  return UnexpectedFailure(message: exception.message, code: exception.code);
}