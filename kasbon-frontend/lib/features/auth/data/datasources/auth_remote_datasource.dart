import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../models/user_model.dart';

/// Exception thrown by auth remote data source
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException({required this.message, this.code});

  @override
  String toString() => message;
}

/// Remote data source for authentication using Supabase
abstract class AuthRemoteDataSource {
  /// Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  });

  /// Sign out current user
  Future<void> signOut();

  /// Get current user
  Future<UserModel?> getCurrentUser();

  /// Send password reset email
  Future<void> resetPassword({required String email});

  /// Check if user is authenticated
  bool get isAuthenticated;

  /// Stream of auth state changes
  Stream<UserModel?> get authStateChanges;
}

/// Implementation of AuthRemoteDataSource using Supabase
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;

  AuthRemoteDataSourceImpl(this._supabaseClient);

  GoTrueClient get _auth => _supabaseClient.auth;

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthFailure.invalidCredentials();
      }

      return UserModel.fromSupabaseUser(response.user!);
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } on AuthApiException catch (e) {
      throw _mapSupabaseAuthError(e);
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw AuthFailure.unknown(e.toString());
    }
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {
          if (fullName != null) 'full_name': fullName,
          if (phone != null) 'phone': phone,
          'tier': 'free',
        },
      );

      if (response.user == null) {
        throw AuthFailure.unknown('Registrasi gagal');
      }

      return UserModel.fromSupabaseUser(response.user!);
    } on AuthApiException catch (e) {
      throw _mapSupabaseAuthError(e);
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw AuthFailure.unknown(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on AuthApiException catch (e) {
      throw _mapSupabaseAuthError(e);
    } catch (e) {
      throw AuthFailure.unknown(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      return UserModel.fromSupabaseUser(user);
    } catch (e) {
      throw AuthFailure.unknown(e.toString());
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.resetPasswordForEmail(email);
    } on AuthApiException catch (e) {
      throw _mapSupabaseAuthError(e);
    } catch (e) {
      throw AuthFailure.unknown(e.toString());
    }
  }

  @override
  bool get isAuthenticated => _auth.currentUser != null;

  @override
  Stream<UserModel?> get authStateChanges {
    return _auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;
      return UserModel.fromSupabaseUser(user);
    });
  }

  /// Map Supabase AuthApiException to AuthFailure
  AuthFailure _mapSupabaseAuthError(AuthApiException error) {
    final message = error.message.toLowerCase();
    final code = error.code;

    // Check error code first
    if (code != null) {
      switch (code) {
        case 'invalid_credentials':
          return AuthFailure.invalidCredentials();
        case 'user_already_exists':
          return AuthFailure.userAlreadyExists();
        case 'email_not_confirmed':
          return AuthFailure.emailNotConfirmed();
        case 'weak_password':
          return AuthFailure.weakPassword();
      }
    }

    // Fallback to message parsing for edge cases
    if (message.contains('invalid login credentials') ||
        message.contains('invalid email or password')) {
      return AuthFailure.invalidCredentials();
    }

    if (message.contains('user already registered') ||
        message.contains('email already in use')) {
      return AuthFailure.userAlreadyExists();
    }

    if (message.contains('email not confirmed')) {
      return AuthFailure.emailNotConfirmed();
    }

    if (message.contains('password') &&
        (message.contains('weak') ||
            message.contains('short') ||
            message.contains('at least'))) {
      return AuthFailure.weakPassword();
    }

    if (message.contains('invalid email')) {
      return AuthFailure.invalidEmail();
    }

    if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout')) {
      return AuthFailure.networkError();
    }

    return AuthFailure.unknown(error.message);
  }

  /// Map internal AuthException to AuthFailure
  AuthFailure _mapAuthException(AuthException error) {
    switch (error.code) {
      case 'invalid_credentials':
        return AuthFailure.invalidCredentials();
      case 'user_already_exists':
        return AuthFailure.userAlreadyExists();
      case 'email_not_confirmed':
        return AuthFailure.emailNotConfirmed();
      case 'weak_password':
        return AuthFailure.weakPassword();
      default:
        return AuthFailure.unknown(error.message);
    }
  }
}
