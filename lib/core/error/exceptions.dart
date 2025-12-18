/// Custom exceptions untuk aplikasi Clean Office
/// Digunakan di data layer (services, repositories)
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

/// Exception untuk Authentication errors (Supabase)
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  /// Factory untuk Supabase auth error
  factory AuthException.fromSupabase(dynamic error) {
    final code = error.statusCode?.toString() ?? error.code?.toString();
    String message;

    switch (code) {
      case '400':
        message = 'Email atau password tidak valid';
        break;
      case '401':
        message = 'Email atau password salah';
        break;
      case '404':
        message = 'Email belum terdaftar';
        break;
      case '422':
        message = 'Email sudah terdaftar';
        break;
      case '429':
        message = 'Terlalu banyak percobaan. Coba lagi nanti';
        break;
      case '500':
        message = 'Terjadi kesalahan server';
        break;
      default:
        message = error.message?.toString() ?? 'Terjadi kesalahan autentikasi';
    }

    return AuthException(message: message, code: code, originalError: error);
  }
}

/// Exception untuk Database errors (Supabase PostgreSQL)
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  /// Factory untuk Supabase/PostgreSQL error codes
  factory DatabaseException.fromSupabase(dynamic error) {
    final code = error.code?.toString();
    String message;

    switch (code) {
      case '23505': // unique_violation
        message = 'Data sudah ada';
        break;
      case '23503': // foreign_key_violation
        message = 'Data terkait tidak ditemukan';
        break;
      case '42501': // insufficient_privilege
        message = 'Anda tidak memiliki akses';
        break;
      case 'PGRST116': // not found
        message = 'Data tidak ditemukan';
        break;
      case '42P01': // undefined_table
        message = 'Tabel tidak ditemukan';
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

/// Exception untuk Storage errors (Supabase Storage)
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  /// Factory untuk Supabase storage error
  factory StorageException.fromSupabase(dynamic error) {
    final code = error.statusCode?.toString() ?? error.code?.toString();
    String message;

    switch (code) {
      case '404':
        message = 'File tidak ditemukan';
        break;
      case '401':
      case '403':
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

  // Check if it's a Supabase error
  final errorString = error.runtimeType.toString().toLowerCase();
  final errorMsg = error.toString().toLowerCase();

  if (errorString.contains('postgrest') || errorString.contains('supabase')) {
    // Try to determine error type based on context
    if (errorMsg.contains('auth') || errorMsg.contains('user') || errorMsg.contains('session')) {
      return AuthException.fromSupabase(error);
    }

    if (errorMsg.contains('storage') || errorMsg.contains('file') || errorMsg.contains('bucket')) {
      return StorageException.fromSupabase(error);
    }

    return DatabaseException.fromSupabase(error);
  }

  // Default to server exception
  return ServerException(message: error.toString(), stackTrace: stackTrace);
}
