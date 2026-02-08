import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/di/injection.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/reset_password.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';

/// Authentication state
sealed class AuthState {
  const AuthState();
}

/// Initial state - checking auth status
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during auth operations
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state with user data
class AuthAuthenticated extends AuthState {
  final AppUser user;

  const AuthAuthenticated(this.user);
}

/// Unauthenticated state
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Error state with message
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);
}

/// Auth state notifier for managing authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final SignIn _signIn;
  final SignUp _signUp;
  final SignOut _signOut;
  final GetCurrentUser _getCurrentUser;
  final ResetPassword _resetPassword;
  final AuthRepository _repository;

  AuthNotifier({
    required SignIn signIn,
    required SignUp signUp,
    required SignOut signOut,
    required GetCurrentUser getCurrentUser,
    required ResetPassword resetPassword,
    required AuthRepository repository,
  })  : _signIn = signIn,
        _signUp = signUp,
        _signOut = signOut,
        _getCurrentUser = getCurrentUser,
        _resetPassword = resetPassword,
        _repository = repository,
        super(const AuthInitial()) {
    // Check auth status on init
    checkAuthStatus();

    // Listen to auth state changes
    _repository.authStateChanges.listen((user) {
      if (user != null) {
        state = AuthAuthenticated(user);
      } else if (state is AuthAuthenticated) {
        state = const AuthUnauthenticated();
      }
    });
  }

  /// Check current authentication status
  Future<void> checkAuthStatus() async {
    state = const AuthLoading();

    final result = await _getCurrentUser();

    result.fold(
      (failure) {
        state = const AuthUnauthenticated();
      },
      (user) {
        if (user != null) {
          state = AuthAuthenticated(user);
        } else {
          state = const AuthUnauthenticated();
        }
      },
    );
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();

    final result = await _signIn(SignInParams(
      email: email,
      password: password,
    ));

    return result.fold(
      (failure) {
        state = AuthError(failure.message);
        return false;
      },
      (user) {
        state = AuthAuthenticated(user);
        return true;
      },
    );
  }

  /// Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    state = const AuthLoading();

    final result = await _signUp(SignUpParams(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    ));

    return result.fold(
      (failure) {
        state = AuthError(failure.message);
        return false;
      },
      (user) {
        state = AuthAuthenticated(user);
        return true;
      },
    );
  }

  /// Sign out
  Future<bool> signOut() async {
    state = const AuthLoading();

    final result = await _signOut();

    return result.fold(
      (failure) {
        state = AuthError(failure.message);
        return false;
      },
      (_) {
        state = const AuthUnauthenticated();
        return true;
      },
    );
  }

  /// Send password reset email
  Future<bool> resetPassword({required String email}) async {
    final result = await _resetPassword(ResetPasswordParams(email: email));

    return result.fold(
      (failure) {
        state = AuthError(failure.message);
        return false;
      },
      (_) => true,
    );
  }

  /// Clear error state
  void clearError() {
    if (state is AuthError) {
      state = const AuthUnauthenticated();
    }
  }

  /// Get current user if authenticated
  AppUser? get currentUser {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      return currentState.user;
    }
    return null;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => state is AuthAuthenticated;
}

/// Provider for auth state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    signIn: getIt<SignIn>(),
    signUp: getIt<SignUp>(),
    signOut: getIt<SignOut>(),
    getCurrentUser: getIt<GetCurrentUser>(),
    resetPassword: getIt<ResetPassword>(),
    repository: getIt<AuthRepository>(),
  );
});

/// Provider for current user (convenience)
final currentUserProvider = Provider<AppUser?>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is AuthAuthenticated) {
    return authState.user;
  }
  return null;
});

/// Provider for auth loading state
final isAuthLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState is AuthLoading;
});

/// Provider for auth error message
final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is AuthError) {
    return authState.message;
  }
  return null;
});
