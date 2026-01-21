import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/product_profitability.dart';
import '../../domain/entities/profit_summary.dart';
import '../../domain/repositories/profit_report_repository.dart';
import '../datasources/profit_local_datasource.dart';

/// Implementation of ProfitReportRepository
class ProfitReportRepositoryImpl implements ProfitReportRepository {
  final ProfitLocalDataSource _localDataSource;

  ProfitReportRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, ProfitSummary>> getProfitByDateRange({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final result = await _localDataSource.getProfitByDateRange(
        from: from,
        to: to,
      );
      return Right(result.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal mengambil ringkasan laba'));
    }
  }

  @override
  Future<Either<Failure, List<ProductProfitability>>> getTopProfitableProducts({
    required int limit,
  }) async {
    try {
      final result = await _localDataSource.getTopProfitableProducts(
        limit: limit,
      );
      return Right(result.map((m) => m.toEntity()).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal mengambil produk terlaris'));
    }
  }

  @override
  Future<Either<Failure, ProductProfitability>> getProductProfitability({
    required String productId,
  }) async {
    try {
      final result = await _localDataSource.getProductProfitability(
        productId: productId,
      );
      return Right(result.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal mengambil data keuntungan produk'));
    }
  }
}
