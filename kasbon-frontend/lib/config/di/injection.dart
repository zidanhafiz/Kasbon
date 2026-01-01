import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

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
import '../../features/products/domain/usecases/get_product.dart';
import '../../features/products/domain/usecases/search_products.dart';
import '../../features/products/domain/usecases/update_product.dart';
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

  logger.i('Dependencies configured successfully');
  logger.i('Database initialized: ${databaseHelper.isInitialized}');
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
}
