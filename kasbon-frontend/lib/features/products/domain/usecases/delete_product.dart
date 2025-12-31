import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/product_repository.dart';

/// Use case to soft delete a product (set is_active = false)
class DeleteProduct implements UseCase<Unit, DeleteProductParams> {
  final ProductRepository _repository;

  DeleteProduct(this._repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteProductParams params) {
    return _repository.deleteProduct(params.id);
  }
}

/// Parameters for DeleteProduct use case
class DeleteProductParams extends Equatable {
  final String id;

  const DeleteProductParams({required this.id});

  @override
  List<Object?> get props => [id];
}
