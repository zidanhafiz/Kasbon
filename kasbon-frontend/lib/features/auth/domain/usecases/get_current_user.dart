import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Use case for getting the currently authenticated user
class GetCurrentUser implements UseCaseNoParams<AppUser?> {
  final AuthRepository _repository;

  GetCurrentUser(this._repository);

  @override
  Future<Either<Failure, AppUser?>> call() {
    return _repository.getCurrentUser();
  }
}
