import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../core/services/backup_service.dart';
import '../../features/backup/data/repositories/backup_repository_impl.dart';
import '../../features/backup/domain/repositories/backup_repository.dart';
import '../../features/backup/domain/usecases/create_backup.dart';
import '../../features/backup/domain/usecases/get_backup_info.dart';
import '../../features/backup/domain/usecases/get_data_counts.dart';
import '../../features/backup/domain/usecases/get_last_backup.dart';
import '../../features/backup/domain/usecases/clear_all_data.dart';
import '../../features/backup/domain/usecases/restore_backup.dart';
import '../../features/categories/data/datasources/category_local_datasource.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/categories/domain/usecases/get_all_categories.dart';
import '../../features/products/data/datasources/product_local_datasource.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/create_product.dart';
import '../../features/products/domain/usecases/delete_product.dart';
import '../../features/products/domain/usecases/get_all_products.dart';
import '../../features/products/domain/usecases/get_paginated_products.dart';
import '../../features/products/domain/usecases/get_product.dart';
import '../../features/products/domain/usecases/search_products.dart';
import '../../features/products/domain/usecases/update_product.dart';
import '../../features/dashboard/data/datasources/dashboard_local_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_summary.dart';
import '../../features/receipt/data/datasources/shop_settings_local_datasource.dart';
import '../../features/receipt/data/repositories/shop_settings_repository_impl.dart';
import '../../features/receipt/domain/repositories/shop_settings_repository.dart';
import '../../features/receipt/domain/usecases/get_shop_settings.dart';
import '../../features/settings/domain/usecases/update_shop_settings.dart';
import '../../features/reports/data/datasources/profit_local_datasource.dart';
import '../../features/reports/data/datasources/report_local_datasource.dart';
import '../../features/reports/data/repositories/profit_report_repository_impl.dart';
import '../../features/reports/data/repositories/report_repository_impl.dart';
import '../../features/reports/domain/repositories/profit_report_repository.dart';
import '../../features/reports/domain/repositories/report_repository.dart';
import '../../features/debt/domain/usecases/get_unpaid_debts.dart';
import '../../features/debt/domain/usecases/mark_debt_paid.dart';
import '../../features/reports/domain/usecases/get_daily_sales.dart';
import '../../features/reports/domain/usecases/get_product_profitability.dart';
import '../../features/reports/domain/usecases/get_profit_summary.dart';
import '../../features/reports/domain/usecases/get_sales_summary.dart';
import '../../features/reports/domain/usecases/get_top_products.dart';
import '../../features/reports/domain/usecases/get_top_profitable_products.dart';
import '../../features/transactions/data/datasources/transaction_local_datasource.dart';
import '../../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/domain/usecases/create_transaction.dart';
import '../../features/transactions/domain/usecases/get_transaction.dart';
import '../../features/transactions/domain/usecases/get_transactions.dart';
import '../database/database_helper.dart';

/// Global service locator instance
final GetIt getIt = GetIt.instance;

/// Logger instance for debugging
final Logger logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

/// Initialize all dependencies
///
/// This should be called at app startup before runApp()
Future<void> configureDependencies() async {
  // Register logger
  getIt.registerLazySingleton<Logger>(() => logger);

  // Register database helper (singleton)
  final databaseHelper = DatabaseHelper();
  await databaseHelper.database; // Initialize database on startup
  getIt.registerSingleton<DatabaseHelper>(databaseHelper);

  // ===========================================
  // PRODUCTS FEATURE
  // ===========================================

  // Data Sources
  getIt.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(getIt<DatabaseHelper>()),
  );

  // Repositories
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(getIt<ProductLocalDataSource>()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetAllProducts(getIt<ProductRepository>()));
  getIt.registerLazySingleton(() => GetProduct(getIt<ProductRepository>()));
  getIt.registerLazySingleton(() => SearchProducts(getIt<ProductRepository>()));
  getIt.registerLazySingleton(() => CreateProduct(getIt<ProductRepository>()));
  getIt.registerLazySingleton(() => UpdateProduct(getIt<ProductRepository>()));
  getIt.registerLazySingleton(() => DeleteProduct(getIt<ProductRepository>()));
  getIt.registerLazySingleton(
      () => GetPaginatedProducts(getIt<ProductRepository>()));

  // ===========================================
  // CATEGORIES FEATURE
  // ===========================================

  // Data Sources
  getIt.registerLazySingleton<CategoryLocalDataSource>(
    () => CategoryLocalDataSourceImpl(getIt<DatabaseHelper>()),
  );

  // Repositories
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(getIt<CategoryLocalDataSource>()),
  );

  // Use Cases
  getIt.registerLazySingleton(
      () => GetAllCategories(getIt<CategoryRepository>()));

  // ===========================================
  // TRANSACTIONS FEATURE
  // ===========================================

  // Data Sources
  getIt.registerLazySingleton<TransactionLocalDataSource>(
    () => TransactionLocalDataSourceImpl(getIt<DatabaseHelper>()),
  );

  // Repositories
  getIt.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(getIt<TransactionLocalDataSource>()),
  );

  // Use Cases
  getIt.registerLazySingleton(
      () => CreateTransaction(getIt<TransactionRepository>()));
  getIt.registerLazySingleton(
      () => GetTransactionById(getIt<TransactionRepository>()));
  getIt.registerLazySingleton(
      () => GetTransactions(getIt<TransactionRepository>()));

  // ===========================================
  // DEBT FEATURE
  // ===========================================

  // Use Cases (reuses TransactionRepository)
  getIt.registerLazySingleton(
      () => GetUnpaidDebts(getIt<TransactionRepository>()));
  getIt.registerLazySingleton(
      () => MarkDebtPaid(getIt<TransactionRepository>()));

  // ===========================================
  // DASHBOARD FEATURE
  // ===========================================

  // Data Sources
  getIt.registerLazySingleton<DashboardLocalDataSource>(
    () => DashboardLocalDataSourceImpl(getIt<DatabaseHelper>()),
  );

  // Repositories
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(getIt<DashboardLocalDataSource>()),
  );

  // Use Cases
  getIt.registerLazySingleton(
    () => GetDashboardSummary(getIt<DashboardRepository>()),
  );

  // ===========================================
  // RECEIPT / SHOP SETTINGS FEATURE
  // ===========================================

  // Data Sources
  getIt.registerLazySingleton<ShopSettingsLocalDataSource>(
    () => ShopSettingsLocalDataSourceImpl(getIt<DatabaseHelper>()),
  );

  // Repositories
  getIt.registerLazySingleton<ShopSettingsRepository>(
    () => ShopSettingsRepositoryImpl(getIt<ShopSettingsLocalDataSource>()),
  );

  // Use Cases
  getIt.registerLazySingleton(
    () => GetShopSettings(getIt<ShopSettingsRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdateShopSettings(getIt<ShopSettingsRepository>()),
  );

  // ===========================================
  // REPORTS / PROFIT FEATURE
  // ===========================================

  // Data Sources
  getIt.registerLazySingleton<ProfitLocalDataSource>(
    () => ProfitLocalDataSourceImpl(getIt<DatabaseHelper>()),
  );
  getIt.registerLazySingleton<ReportLocalDataSource>(
    () => ReportLocalDataSourceImpl(getIt<DatabaseHelper>()),
  );

  // Repositories
  getIt.registerLazySingleton<ProfitReportRepository>(
    () => ProfitReportRepositoryImpl(getIt<ProfitLocalDataSource>()),
  );
  getIt.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(getIt<ReportLocalDataSource>()),
  );

  // Use Cases - Profit
  getIt.registerLazySingleton(
    () => GetProfitSummary(getIt<ProfitReportRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetTopProfitableProducts(getIt<ProfitReportRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetProductProfitability(getIt<ProfitReportRepository>()),
  );

  // Use Cases - Basic Reports
  getIt.registerLazySingleton(
    () => GetSalesSummary(getIt<ReportRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetTopProducts(getIt<ReportRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetDailySales(getIt<ReportRepository>()),
  );

  // ===========================================
  // BACKUP FEATURE
  // ===========================================

  // Services
  getIt.registerLazySingleton<BackupService>(
    () => BackupService(getIt<DatabaseHelper>()),
  );

  // Repositories
  getIt.registerLazySingleton<BackupRepository>(
    () => BackupRepositoryImpl(getIt<BackupService>()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => CreateBackup(getIt<BackupRepository>()));
  getIt.registerLazySingleton(() => RestoreBackup(getIt<BackupRepository>()));
  getIt.registerLazySingleton(() => GetBackupInfo(getIt<BackupRepository>()));
  getIt.registerLazySingleton(() => GetLastBackup(getIt<BackupRepository>()));
  getIt.registerLazySingleton(() => GetDataCounts(getIt<BackupRepository>()));
  getIt.registerLazySingleton(() => ClearAllData(getIt<BackupRepository>()));

  logger.i('Dependencies configured successfully');
  logger.i('Database initialized: ${databaseHelper.isInitialized}');
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
}
