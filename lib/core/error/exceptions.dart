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

// ==================== FIREBASE EXCEPTIONS ====================

/// Exception untuk Firebase Authentication errors
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory AuthException.fromFirebaseAuth(dynamic error) {
    final code = error.code as String?;
    String message;

    switch (code) {
      case 'user-not-found':
        message = 'Email belum terdaftar';
        break;
      case 'wrong-password':
        message = 'Password salah';
        break;
      case 'invalid-email':
        message = 'Format email tidak valid';
        break;
      case 'user-disabled':
        message = 'Akun telah dinonaktifkan';
        break;
      case 'too-many-requests':
        message = 'Terlalu banyak percobaan. Coba lagi nanti';
        break;
      case 'email-already-in-use':
        message = 'Email sudah terdaftar';
        break;
      case 'weak-password':
        message = 'Password terlalu lemah';
        break;
      case 'requires-recent-login':
        message = 'Silakan login ulang untuk melanjutkan';
        break;
      case 'network-request-failed':
        message = 'Koneksi internet bermasalah';
        break;
      default:
        message = error.message ?? 'Terjadi kesalahan autentikasi';
    }

    return AuthException(message: message, code: code, originalError: error);
  }
}

/// Exception untuk Firestore errors
class FirestoreException extends AppException {
  const FirestoreException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory FirestoreException.fromFirebase(dynamic error) {
    final code = error.code as String?;
    String message;

    switch (code) {
      case 'permission-denied':
        message = 'Anda tidak memiliki akses';
        break;
      case 'not-found':
        message = 'Data tidak ditemukan';
        break;
      case 'already-exists':
        message = 'Data sudah ada';
        break;
      case 'cancelled':
        message = 'Operasi dibatalkan';
        break;
      case 'unavailable':
        message = 'Service tidak tersedia. Coba lagi';
        break;
      case 'deadline-exceeded':
        message = 'Operasi timeout';
        break;
      default:
        message = error.message ?? 'Terjadi kesalahan database';
    }

    return FirestoreException(
      message: message,
      code: code,
      originalError: error,
    );
  }
}

/// Exception untuk Firebase Storage errors
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory StorageException.fromFirebase(dynamic error) {
    final code = error.code as String?;
    String message;

    switch (code) {
      case 'object-not-found':
        message = 'File tidak ditemukan';
        break;
      case 'unauthorized':
        message = 'Tidak ada akses untuk upload/download file';
        break;
      case 'canceled':
        message = 'Upload dibatalkan';
        break;
      case 'unknown':
        message = 'Terjadi kesalahan saat memproses file';
        break;
      case 'quota-exceeded':
        message = 'Kuota storage penuh';
        break;
      default:
        message = error.message ?? 'Terjadi kesalahan storage';
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

  // Check if it's a Firebase error
  if (error.runtimeType.toString().contains('FirebaseAuth')) {
    return AuthException.fromFirebaseAuth(error);
  }

  if (error.runtimeType.toString().contains('FirebaseFirestore')) {
    return FirestoreException.fromFirebase(error);
  }

  if (error.runtimeType.toString().contains('FirebaseStorage')) {
    return StorageException.fromFirebase(error);
  }

  // Default to server exception
  return ServerException(message: error.toString(), stackTrace: stackTrace);
}
