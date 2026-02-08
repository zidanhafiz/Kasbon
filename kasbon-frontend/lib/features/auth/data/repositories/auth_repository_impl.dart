import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await _remoteDataSource.signIn(
        email: email,
        password: password,
      );

      // Cache user locally
      await _localDataSource.cacheUser(userModel);

      return Right(userModel.toEntity());
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    try {
      final userModel = await _remoteDataSource.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

      // Cache user locally
      await _localDataSource.cacheUser(userModel);

      return Right(userModel.toEntity());
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _remoteDataSource.signOut();

      // Clear cached user
      await _localDataSource.clearCachedUser();

      return const Right(unit);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser?>> getCurrentUser() async {
    try {
      // First try remote
      final userModel = await _remoteDataSource.getCurrentUser();

      if (userModel != null) {
        // Update cache
        await _localDataSource.cacheUser(userModel);
        return Right(userModel.toEntity());
      }

      // If no remote user, check cache (for offline support)
      final cachedUser = await _localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser.toEntity());
      }

      return const Right(null);
    } on AuthFailure catch (e) {
      // On network error, try cache
      final cachedUser = await _localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser.toEntity());
      }
      return Left(e);
    } catch (e) {
      // On any error, try cache
      final cachedUser = await _localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser.toEntity());
      }
      return Left(AuthFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({required String email}) async {
    try {
      await _remoteDataSource.resetPassword(email: email);
      return const Right(unit);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure.unknown(e.toString()));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    // Quick local check first
    if (_remoteDataSource.isAuthenticated) {
      return true;
    }

    // Fallback to cache check
    return await _localDataSource.hasCache();
  }

  @override
  Stream<AppUser?> get authStateChanges {
    return _remoteDataSource.authStateChanges.map((userModel) {
      if (userModel == null) {
        // Clear cache when signed out
        _localDataSource.clearCachedUser();
        return null;
      }

      // Update cache when auth state changes
      _localDataSource.cacheUser(userModel);
      return userModel.toEntity();
    });
  }
}
