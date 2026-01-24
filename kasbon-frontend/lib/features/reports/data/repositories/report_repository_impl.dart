import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/daily_sales.dart';
import '../../domain/entities/product_report.dart';
import '../../domain/entities/sales_summary.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_local_datasource.dart';

/// Implementation of ReportRepository
class ReportRepositoryImpl implements ReportRepository {
  final ReportLocalDataSource _localDataSource;

  ReportRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, SalesSummary>> getSalesSummary({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final result = await _localDataSource.getSalesSummary(
        from: from,
        to: to,
      );
      return Right(result.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return const Left(
          DatabaseFailure(message: 'Gagal mengambil ringkasan penjualan'));
    }
  }

  @override
  Future<Either<Failure, List<ProductReport>>> getTopProducts({
    required DateTime from,
    required DateTime to,
    required ProductReportSortType sortBy,
    required int limit,
  }) async {
    try {
      final result = await _localDataSource.getTopProducts(
        from: from,
        to: to,
        sortBy: sortBy,
        limit: limit,
      );
      return Right(result.map((m) => m.toEntity()).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return const Left(
          DatabaseFailure(message: 'Gagal mengambil data produk terlaris'));
    }
  }

  @override
  Future<Either<Failure, List<DailySales>>> getDailySales({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final result = await _localDataSource.getDailySales(
        from: from,
        to: to,
      );
      return Right(result.map((m) => m.toEntity()).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return const Left(
          DatabaseFailure(message: 'Gagal mengambil data penjualan harian'));
    }
  }
}
