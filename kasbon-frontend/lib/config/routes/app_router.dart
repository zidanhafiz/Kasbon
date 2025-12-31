import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/dev_tools/presentation/screens/design_system_showcase_screen.dart';
import '../../features/pos/presentation/screens/pos_screen.dart';
import '../../features/pos/presentation/screens/transaction_success_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/products/presentation/screens/product_form_screen.dart';
import '../../features/products/presentation/screens/product_list_screen.dart';
import '../../shared/modern/modern.dart';

/// Route names for the application
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String dashboard = '/dashboard';
  static const String pos = '/pos';
  static const String posSuccess = '/pos/success/:transactionId';
  static const String products = '/products';
  static const String productDetail = '/products/:id';
  static const String productAdd = '/products/add';
  static const String productEdit = '/products/:id/edit';
  static const String transactions = '/transactions';
  static const String transactionDetail = '/transactions/:id';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String designSystem = '/dev/design-system';
}

/// Application router configuration using GoRouter
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.dashboard,
    debugLogDiagnostics: true,
    routes: [
      // Main navigation shell (bottom nav on mobile, sidebar on tablet)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ModernAppShell(
            currentPath: state.uri.path,
            child: child,
          );
        },
        routes: [
          // Dashboard (Main screen)
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            pageBuilder: (context, state) => _buildPage(
              state: state,
              child: const DashboardScreen(),
            ),
          ),

          // POS Screen
          GoRoute(
            path: AppRoutes.pos,
            name: 'pos',
            pageBuilder: (context, state) => _buildPage(
              state: state,
              child: const PosScreen(),
            ),
          ),

          // Products with nested routes (list, detail, add, edit)
          GoRoute(
            path: AppRoutes.products,
            name: 'products',
            pageBuilder: (context, state) => _buildPage(
              state: state,
              child: const ProductListScreen(),
            ),
            routes: [
              // Product Add - /products/add
              GoRoute(
                path: 'add',
                name: 'product-add',
                pageBuilder: (context, state) => _buildPage(
                  state: state,
                  child: const ProductFormScreen(),
                ),
              ),
              // Product Detail - /products/:id
              GoRoute(
                path: ':id',
                name: 'product-detail',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return _buildPage(
                    state: state,
                    child: ProductDetailScreen(productId: id),
                  );
                },
                routes: [
                  // Product Edit - /products/:id/edit
                  GoRoute(
                    path: 'edit',
                    name: 'product-edit',
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return _buildPage(
                        state: state,
                        child: ProductFormScreen(productId: id),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // Transactions (list only in shell)
          GoRoute(
            path: AppRoutes.transactions,
            name: 'transactions',
            pageBuilder: (context, state) => _buildPage(
              state: state,
              child: const _PlaceholderScreen(title: 'Riwayat Transaksi'),
            ),
          ),

          // Reports
          GoRoute(
            path: AppRoutes.reports,
            name: 'reports',
            pageBuilder: (context, state) => _buildPage(
              state: state,
              child: const _PlaceholderScreen(title: 'Laporan'),
            ),
          ),

          // Settings
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            pageBuilder: (context, state) => _buildPage(
              state: state,
              child: const _PlaceholderScreen(title: 'Pengaturan'),
            ),
          ),
        ],
      ),

      // Full-screen routes (outside shell)
      // POS Success Screen
      GoRoute(
        path: AppRoutes.posSuccess,
        name: 'pos-success',
        pageBuilder: (context, state) {
          final transactionId = state.pathParameters['transactionId']!;
          return _buildPage(
            state: state,
            child: TransactionSuccessScreen(transactionId: transactionId),
          );
        },
      ),

      // Transaction Detail
      GoRoute(
        path: AppRoutes.transactionDetail,
        name: 'transaction-detail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'];
          return _buildPage(
            state: state,
            child: _PlaceholderScreen(title: 'Detail Transaksi: $id'),
          );
        },
      ),

      // Dev Tools - Design System Showcase
      GoRoute(
        path: AppRoutes.designSystem,
        name: 'design-system',
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const DesignSystemShowcaseScreen(),
        ),
      ),
    ],

    // Error handling
    errorPageBuilder: (context, state) => _buildPage(
      state: state,
      child: _ErrorScreen(error: state.error.toString()),
    ),
  );

  /// Build a custom page with fade transition
  static CustomTransitionPage<void> _buildPage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}

/// Placeholder screen for routes that are not yet implemented
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar.withActions(
        title: title,
        onNotificationTap: () {
          // TODO: Navigate to notifications
        },
        onProfileTap: () {
          // TODO: Navigate to profile
        },
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Halaman ini sedang dalam pengembangan',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error screen for handling navigation errors
class _ErrorScreen extends StatelessWidget {
  final String error;

  const _ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Halaman tidak ditemukan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.dashboard),
              child: const Text('Kembali ke Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
