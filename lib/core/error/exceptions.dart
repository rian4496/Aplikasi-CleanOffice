/// Custom exceptions untuk aplikasi Clean Office
/// Digunakan di data layer (services, repositories)
/// ✅ MIGRATED TO APPWRITE - No Firebase dependencies
library;

/// Base exception class
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

// ==================== AUTH EXCEPTIONS ====================

/// Exception untuk Authentication errors (Appwrite)
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  /// Factory untuk Appwrite error codes
  factory AuthException.fromAppwrite(dynamic error) {
    final code = error.code?.toString();
    String message;

    switch (code) {
      case '401':
        message = 'Email atau password salah';
        break;
      case '404':
        message = 'Email belum terdaftar';
        break;
      case '409':
        message = 'Email sudah terdaftar';
        break;
      case '429':
        message = 'Terlalu banyak percobaan. Coba lagi nanti';
        break;
      case '400':
        message = 'Format data tidak valid';
        break;
      case '503':
        message = 'Service tidak tersedia';
        break;
      default:
        message = error.message?.toString() ?? 'Terjadi kesalahan autentikasi';
    }

    return AuthException(message: message, code: code, originalError: error);
  }
}

/// Exception untuk Database errors (Appwrite)
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  /// Factory untuk Appwrite database error codes
  factory DatabaseException.fromAppwrite(dynamic error) {
    final code = error.code?.toString();
    String message;

    switch (code) {
      case '401':
        message = 'Anda tidak memiliki akses';
        break;
      case '404':
        message = 'Data tidak ditemukan';
        break;
      case '409':
        message = 'Data sudah ada';
        break;
      case '500':
        message = 'Terjadi kesalahan server';
        break;
      case '503':
        message = 'Service tidak tersedia. Coba lagi';
        break;
      default:
        message = error.message?.toString() ?? 'Terjadi kesalahan database';
    }

    return DatabaseException(
      message: message,
      code: code,
      originalError: error,
    );
  }
}

/// Exception untuk Storage errors (Appwrite)
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  /// Factory untuk Appwrite storage error codes
  factory StorageException.fromAppwrite(dynamic error) {
    final code = error.code?.toString();
    String message;

    switch (code) {
      case '404':
        message = 'File tidak ditemukan';
        break;
      case '401':
        message = 'Tidak ada akses untuk upload/download file';
        break;
      case '413':
        message = 'Ukuran file terlalu besar';
        break;
      case '500':
        message = 'Terjadi kesalahan saat memproses file';
        break;
      default:
        message = error.message?.toString() ?? 'Terjadi kesalahan storage';
    }

    return StorageException(message: message, code: code, originalError: error);
  }
}

// ==================== APPLICATION EXCEPTIONS ====================

/// Exception untuk validation errors
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    this.fieldErrors,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  bool hasFieldError(String field) => fieldErrors?.containsKey(field) ?? false;
  String? getFieldError(String field) => fieldErrors?[field];
}

/// Exception untuk not found errors
class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception untuk permission/authorization errors
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception untuk network/connectivity errors
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception untuk server errors
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required super.message,
    this.statusCode,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception untuk cache errors
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception untuk parsing/format errors
class FormatException extends AppException {
  const FormatException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

// ==================== HELPER FUNCTIONS ====================

/// Convert any error to appropriate AppException
AppException toAppException(dynamic error, {StackTrace? stackTrace}) {
  if (error is AppException) return error;

  // Check if it's an Appwrite error (has code property)
  final errorString = error.runtimeType.toString().toLowerCase();

  if (errorString.contains('appwrite') || error.toString().contains('AppwriteException')) {
    // Try to determine error type based on context
    final errorMsg = error.toString().toLowerCase();

    if (errorMsg.contains('auth') || errorMsg.contains('user') || errorMsg.contains('session')) {
      return AuthException.fromAppwrite(error);
    }

    if (errorMsg.contains('storage') || errorMsg.contains('file') || errorMsg.contains('bucket')) {
      return StorageException.fromAppwrite(error);
    }

    if (errorMsg.contains('database') || errorMsg.contains('document') || errorMsg.contains('collection')) {
      return DatabaseException.fromAppwrite(error);
    }
  }

  // Default to server exception
  return ServerException(message: error.toString(), stackTrace: stackTrace);
}
