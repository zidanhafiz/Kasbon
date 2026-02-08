import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/app_user.dart';

/// Abstract repository interface for authentication operations
abstract class AuthRepository {
  /// Sign in with email and password
  ///
  /// Returns [AppUser] on success, [AuthFailure] on failure.
  Future<Either<Failure, AppUser>> signIn({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  ///
  /// Returns [AppUser] on success, [AuthFailure] on failure.
  /// Note: Depending on Supabase config, email confirmation may be required.
  Future<Either<Failure, AppUser>> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  });

  /// Sign out the current user
  ///
  /// Returns [Unit] on success, [AuthFailure] on failure.
  Future<Either<Failure, Unit>> signOut();

  /// Get the currently authenticated user
  ///
  /// Returns [AppUser] if authenticated, null if not authenticated.
  /// Returns [AuthFailure] on error (e.g., network issues).
  Future<Either<Failure, AppUser?>> getCurrentUser();

  /// Send password reset email
  ///
  /// Returns [Unit] on success, [AuthFailure] on failure.
  Future<Either<Failure, Unit>> resetPassword({required String email});

  /// Check if user is currently authenticated
  ///
  /// Returns true if authenticated, false otherwise.
  /// This is a quick local check, doesn't verify with server.
  Future<bool> isAuthenticated();

  /// Stream of auth state changes
  ///
  /// Emits [AppUser] when authenticated, null when signed out.
  Stream<AppUser?> get authStateChanges;
}
