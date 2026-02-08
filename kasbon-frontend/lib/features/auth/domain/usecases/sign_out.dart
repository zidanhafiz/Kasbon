import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing out the current user
class SignOut implements UseCaseNoParams<Unit> {
  final AuthRepository _repository;

  SignOut(this._repository);

  @override
  Future<Either<Failure, Unit>> call() {
    return _repository.signOut();
  }
}
