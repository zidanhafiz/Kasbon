import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Failure for database operations
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required super.message,
    super.code,
  });
}

/// Failure for cache operations
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
  });
}

/// Failure for validation errors
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Failure for unexpected errors
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'Terjadi kesalahan yang tidak terduga',
    super.code,
  });
}

/// Failure for not found errors
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.code,
  });
}

/// Failure for backup/restore operations
class BackupFailure extends Failure {
  const BackupFailure({
    required super.message,
    super.code,
  });
}

/// Failure for file system operations
class FileFailure extends Failure {
  const FileFailure({
    required super.message,
    super.code,
  });
}

/// Failure for authentication operations
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });

  /// Factory for invalid credentials error
  factory AuthFailure.invalidCredentials() => const AuthFailure(
        message: 'Email atau password salah',
        code: 'invalid_credentials',
      );

  /// Factory for email not confirmed error
  factory AuthFailure.emailNotConfirmed() => const AuthFailure(
        message: 'Email belum dikonfirmasi. Cek inbox Anda',
        code: 'email_not_confirmed',
      );

  /// Factory for user already exists error
  factory AuthFailure.userAlreadyExists() => const AuthFailure(
        message: 'Email sudah terdaftar',
        code: 'user_already_exists',
      );

  /// Factory for weak password error
  factory AuthFailure.weakPassword() => const AuthFailure(
        message: 'Password terlalu lemah. Minimal 8 karakter',
        code: 'weak_password',
      );

  /// Factory for invalid email format error
  factory AuthFailure.invalidEmail() => const AuthFailure(
        message: 'Format email tidak valid',
        code: 'invalid_email',
      );

  /// Factory for network error
  factory AuthFailure.networkError() => const AuthFailure(
        message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda',
        code: 'network_error',
      );

  /// Factory for session expired error
  factory AuthFailure.sessionExpired() => const AuthFailure(
        message: 'Sesi Anda telah berakhir. Silakan login kembali',
        code: 'session_expired',
      );

  /// Factory for generic server error
  factory AuthFailure.serverError() => const AuthFailure(
        message: 'Terjadi kesalahan di server. Coba lagi nanti',
        code: 'server_error',
      );

  /// Factory for generic/unknown error
  factory AuthFailure.unknown([String? details]) => AuthFailure(
        message: details ?? 'Terjadi kesalahan. Coba lagi nanti',
        code: 'unknown',
      );
}
