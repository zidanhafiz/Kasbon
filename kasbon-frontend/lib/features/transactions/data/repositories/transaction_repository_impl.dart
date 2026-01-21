import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_item.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../models/transaction_item_model.dart';
import '../models/transaction_model.dart';

/// Implementation of TransactionRepository
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource _localDataSource;

  TransactionRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, Transaction>> createTransaction(
    Transaction transaction,
    List<TransactionItem> items,
  ) async {
    try {
      final transactionModel = TransactionModel.fromEntity(transaction);
      final itemModels =
          items.map((item) => TransactionItemModel.fromEntity(item)).toList();

      final result = await _localDataSource.createTransaction(
        transactionModel,
        itemModels,
      );

      // Return the transaction with items
      return Right(result.toEntity(items: items));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions({
    int? limit,
    int? offset,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final models = await _localDataSource.getTransactions(
        limit: limit,
        offset: offset,
        startDate: startDate,
        endDate: endDate,
      );

      // Convert models to entities (without items for list view)
      return Right(models.map((m) => m.toEntity()).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Transaction>> getTransactionById(String id) async {
    try {
      // Get transaction
      final transactionModel = await _localDataSource.getTransactionById(id);

      // Get transaction items
      final itemModels = await _localDataSource.getTransactionItems(id);
      final items = itemModels.map((m) => m.toEntity()).toList();

      // Return transaction with items
      return Right(transactionModel.toEntity(items: items));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, int>> getTodayTransactionCount() async {
    try {
      final count = await _localDataSource.getTodayTransactionCount();
      return Right(count);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsByPaymentStatus(
    String status,
  ) async {
    try {
      final models =
          await _localDataSource.getTransactionsByPaymentStatus(status);
      return Right(models.map((m) => m.toEntity()).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Transaction>> updateTransaction(
    String id, {
    String? paymentStatus,
    DateTime? debtPaidAt,
  }) async {
    try {
      final model = await _localDataSource.updateTransaction(
        id,
        paymentStatus: paymentStatus,
        debtPaidAt: debtPaidAt?.millisecondsSinceEpoch,
      );

      // Get items to return complete transaction
      final itemModels = await _localDataSource.getTransactionItems(id);
      final items = itemModels.map((m) => m.toEntity()).toList();

      return Right(model.toEntity(items: items));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }
}
