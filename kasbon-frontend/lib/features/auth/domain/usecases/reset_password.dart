import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case for sending password reset email
class ResetPassword implements UseCase<Unit, ResetPasswordParams> {
  final AuthRepository _repository;

  ResetPassword(this._repository);

  @override
  Future<Either<Failure, Unit>> call(ResetPasswordParams params) {
    return _repository.resetPassword(email: params.email);
  }
}

/// Parameters for ResetPassword use case
class ResetPasswordParams extends Equatable {
  final String email;

  const ResetPasswordParams({required this.email});

  @override
  List<Object?> get props => [email];
}
