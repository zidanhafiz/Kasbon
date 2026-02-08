# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

KASBON POS Flutter frontend - offline-first POS app for Indonesian UMKM with dual-mode architecture (local SQLite default, optional Supabase cloud sync). See `../CLAUDE.md` for full project context including database schema, feature priorities, and development phases.

## Development Commands

```bash
# Local mode (default)
flutter pub get              # Install dependencies
flutter run                  # Run app (local mode)
flutter analyze              # Analyze code for issues
flutter test                 # Run all tests
flutter test test/path/      # Run specific test
dart run build_runner build  # Generate code (freezed, riverpod, json)
dart format lib/             # Format code
flutter build apk            # Build Android APK (local mode)
flutter build appbundle      # Build Android App Bundle (local mode)

# Supabase mode (opt-in)
flutter run --dart-define=APP_MODE=supabase --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
flutter build apk --dart-define=APP_MODE=supabase --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

## Architecture

**Clean Architecture** with feature-based modules:

```
lib/
├── main.dart                     # App entry, DI init, ProviderScope
├── core/                         # Shared infrastructure
│   ├── constants/                # App & database constants
│   ├── errors/                   # Failure classes (DatabaseFailure, etc.)
│   ├── usecase/                  # Base UseCase<T, Params> class
│   └── utils/                    # Currency/date formatters, validators
├── config/
│   ├── app_config.dart           # Dual-mode config (local/supabase)
│   ├── database/                 # DatabaseHelper, migrations, schema
│   ├── di/injection.dart         # GetIt service locator setup
│   ├── routes/app_router.dart    # GoRouter with ShellRoute navigation
│   └── theme/                    # AppColors, AppTextStyles, AppTheme
├── features/<feature>/           # Feature modules
│   ├── data/
│   │   ├── datasources/          # LocalDataSource implementations
│   │   ├── models/               # DTOs (toMap/fromMap for SQLite)
│   │   └── repositories/         # Repository implementations
│   ├── domain/
│   │   ├── entities/             # Business objects (extend Equatable)
│   │   ├── repositories/         # Abstract repository interfaces
│   │   └── usecases/             # Single-purpose use case classes
│   └── presentation/
│       ├── providers/            # Riverpod providers & state notifiers
│       ├── screens/              # Page widgets
│       └── widgets/              # Feature-specific components
└── shared/
    ├── modern/                   # REQUIRED: Modern Widget Library
    │   ├── modern.dart           # Main export (use this import)
    │   ├── components/           # Buttons, cards, inputs, layout, feedback
    │   └── utils/                # Variants (ModernSize, etc.)
    └── widgets/                  # DEPRECATED: Legacy widgets (do not use)
```

## App Modes & Conditional Features (CRITICAL)

The app uses `AppConfig` (`lib/config/app_config.dart`) for compile-time mode switching:
- **Local mode** (default): SQLite only, no Supabase dependency
- **Supabase mode**: `--dart-define=APP_MODE=supabase` enables cloud sync + auth

**Rules:**
1. All features MUST work in local mode without Supabase
2. Guard Supabase-only code behind `AppConfig.isSupabaseMode`
3. Never add `supabase_flutter` as unconditional dependency

**Pattern — Conditional DI (in `injection.dart`):**
```dart
// Supabase services registered only in supabase mode
if (AppConfig.isSupabaseMode) {
  getIt.registerLazySingleton<AuthRemoteDataSource>(...);
  getIt.registerLazySingleton<SyncService>(...);
}
```

**Pattern — Conditional UI:**
```dart
// Show account section only in supabase mode
if (AppConfig.isSupabaseMode) ...[
  ModernSectionHeader(title: 'Akun'),
  ModernListTile(title: 'Login', onTap: onLogin),
],
```

**Pattern — Conditional Routes:**
```dart
if (AppConfig.isSupabaseMode) ...[
  GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
  GoRoute(path: '/account', builder: (_, __) => const AccountScreen()),
],
```

## Key Patterns

**Repository Pattern:**
- Repositories return `Either<Failure, T>` from dartz
- DataSources throw custom exceptions, repos catch and return Failures

**UseCase Pattern:**
```dart
class GetProduct extends UseCase<Product, GetProductParams> {
  final ProductRepository repository;
  GetProduct(this.repository);

  @override
  Future<Either<Failure, Product>> call(GetProductParams params) async {
    return await repository.getProduct(params.id);
  }
}
```

**Riverpod Providers:**
- Use `FutureProvider.autoDispose` for data fetching
- Use `StateNotifier` for complex state with mutations
- Access use cases via GetIt: `getIt<GetAllProducts>()`

**SQLite Data:**
- Store timestamps as `int` (milliseconds since epoch)
- Use parameterized queries via DatabaseHelper methods
- Models have `toMap()` and `fromMap(Map<String, dynamic>)`

## Modern Widget Library (REQUIRED)

**CRITICAL:** All UI development MUST use the Modern Widget Library. DO NOT use raw Flutter widgets when a Modern equivalent exists.

**Import:**
```dart
import 'package:kasbon_frontend/shared/modern/modern.dart';
```

### Buttons
```dart
// Primary actions
ModernButton.primary(child: Text('Bayar'), onPressed: onPay)
ModernButton.label(label: 'Simpan', onPressed: onSave) // Convenience factory

// Other variants
ModernButton.secondary(child: Text('Draft'))
ModernButton.outline(child: Text('Batal'))
ModernButton.text(child: Text('Lihat Semua'))
ModernButton.destructive(child: Text('Hapus'))

// With icons and states
ModernButton.primary(
  child: Text('Checkout'),
  size: ModernSize.large,
  leadingIcon: Icons.shopping_cart,
  isLoading: isProcessing,
  fullWidth: true,
  onPressed: onCheckout,
)

// Icon buttons
ModernIconButton(icon: Icons.add, onPressed: onAdd)
ModernIconButton.filled(icon: Icons.delete, onPressed: onDelete)
```

### Cards
```dart
ModernCard.elevated(
  padding: EdgeInsets.all(AppDimensions.spacing16),
  onTap: onCardTap,
  child: Column(...),
)
ModernCard.outlined(child: content)
ModernCard.filled(child: content)

// Gradient cards for dashboard stats
ModernGradientCard.primary(child: revenueStats)
ModernGradientCard.success(child: profitStats)
ModernGradientCard.warning(child: alertStats)
```

### Inputs
```dart
ModernTextField(
  label: 'Nama Produk',
  hint: 'Masukkan nama',
  controller: nameController,
  errorText: errors['name'],
  prefixIcon: Icons.inventory,
)

ModernCurrencyField(
  label: 'Harga Jual',
  controller: priceController,
  onChanged: (value) {},
)

ModernSearchField(
  hint: 'Cari produk...',
  onChanged: onSearch,
  onClear: onClearSearch,
)

ModernQuantityStepper(
  value: quantity,
  onIncrement: () => updateQty(quantity + 1),
  onDecrement: () => updateQty(quantity - 1),
  min: 1,
  max: 99,
)

ModernDropdown<String>(
  label: 'Kategori',
  value: selectedCategory,
  items: categories,
  onChanged: (value) => selectCategory(value),
)
```

### Layout
```dart
// App shell with responsive navigation
ModernAppShell(
  child: child,
  currentPath: currentPath,
  showFab: true,
  onFabPressed: () => context.go('/pos'),
)

// App bar factories
ModernAppBar.simple(title: 'Produk')
ModernAppBar.withBack(title: 'Detail', context: context)
ModernAppBar.withSearch(title: 'Produk', onSearch: onSearch)
ModernAppBar.withActions(title: 'Dashboard', actions: [...])

ModernDivider()
ModernSectionHeader(
  title: 'Produk Terlaris',
  actionLabel: 'Lihat Semua',
  onAction: onViewAll,
)
```

### Feedback
```dart
// Loading states
ModernLoading()
ModernLoading.small(color: Colors.white)

// Empty state
ModernEmptyState(
  icon: Icons.inventory_2_outlined,
  title: 'Belum Ada Produk',
  message: 'Tambahkan produk pertama Anda',
  actionLabel: 'Tambah Produk',
  onAction: onAddProduct,
)

// Error state
ModernErrorState(
  message: 'Gagal memuat data',
  onRetry: onRetry,
)

// Dialogs
ModernDialog.confirm(
  context: context,
  title: 'Hapus Produk?',
  message: 'Produk akan dihapus permanen',
  confirmLabel: 'Hapus',
  onConfirm: onDelete,
)

// Toasts
ModernToast.success(context: context, message: 'Berhasil disimpan')
ModernToast.error(context: context, message: 'Gagal menyimpan')
```

### Data Display
```dart
ModernBadge.success(label: 'Lunas')
ModernBadge.warning(label: 'Hutang')
ModernBadge.error(label: 'Gagal')

ModernChip(label: 'Makanan', isSelected: true, onTap: onSelect)

ModernAvatar(imageUrl: product.imageUrl, fallbackText: 'P')

ModernListTile(
  title: 'Nama Produk',
  subtitle: 'Rp 50.000',
  leading: ModernAvatar(...),
  trailing: ModernBadge.success(label: 'Tersedia'),
  onTap: onProductTap,
)

ModernSummaryRow(label: 'Subtotal', value: 'Rp 150.000')
ModernSummaryRow.total(label: 'TOTAL', value: 'Rp 150.000')
```

### Size Variants & Responsive Design
```dart
// All components support sizes
ModernSize.small   // Compact UI
ModernSize.medium  // Default
ModernSize.large   // Prominent actions

// Responsive design
if (context.isMobile) {
  // Mobile layout
} else {
  // Tablet layout
}
```

## Modern Widget Patterns

**Screen with Loading/Error/Empty States:**
```dart
class ProductListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: ModernAppBar.simple(title: 'Produk'),
      body: productsAsync.when(
        loading: () => const Center(child: ModernLoading()),
        error: (err, _) => ModernErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(productsProvider),
        ),
        data: (products) => products.isEmpty
            ? ModernEmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'Belum Ada Produk',
                actionLabel: 'Tambah',
                onAction: () => context.push('/products/add'),
              )
            : _buildProductList(products),
      ),
    );
  }
}
```

**Form with Modern Inputs:**
```dart
Column(
  children: [
    ModernTextField(
      label: 'Nama Produk',
      controller: nameController,
      errorText: errors['name'],
    ),
    const SizedBox(height: AppDimensions.spacing16),
    ModernCurrencyField(
      label: 'Harga Jual',
      controller: priceController,
    ),
    const SizedBox(height: AppDimensions.spacing16),
    ModernDropdown<String>(
      label: 'Kategori',
      value: selectedCategory,
      items: categories.map((c) => DropdownMenuItem(
        value: c.id, child: Text(c.name)
      )).toList(),
      onChanged: (v) => setState(() => selectedCategory = v),
    ),
    const SizedBox(height: AppDimensions.spacing24),
    ModernButton.primary(
      child: Text('Simpan'),
      fullWidth: true,
      isLoading: isSaving,
      onPressed: onSave,
    ),
  ],
)
```

## Dependency Injection

All dependencies registered in `lib/config/di/injection.dart`:
1. Core services (Logger, DatabaseHelper)
2. DataSources (feature-specific)
3. Repositories
4. UseCases
5. **Supabase services** — registered inside `if (AppConfig.isSupabaseMode)` block only

Access anywhere: `getIt<ProductRepository>()`

## Navigation

GoRouter with ShellRoute for bottom navigation:
- `AppRoutes` class defines route paths
- Full-screen routes (forms, details) outside shell
- Navigation: `context.go('/products')` or `context.push('/products/add')`

## Code Conventions

- All UI text in Bahasa Indonesia
- Currency: Use `CurrencyFormatter` for `Rp` prefix with Indonesian locale
- Transaction numbers: `TRX-YYYYMMDD-XXXX`
- SKU format: `SKU-XXXXX` (auto-generated)
- Always handle loading, error, and empty states in UI

## Adding a New Feature

1. **Check if feature is mode-specific:** If supabase-only (auth, sync), guard all code behind `AppConfig.isSupabaseMode`
2. Create feature folder structure under `lib/features/<name>/`
3. Define entity in `domain/entities/`
4. Define repository interface in `domain/repositories/`
5. Implement datasource in `data/datasources/`
6. Implement repository in `data/repositories/`
7. Create use cases in `domain/usecases/`
8. Register all in `injection.dart` (inside `if (AppConfig.isSupabaseMode)` block if supabase-only)
9. Add providers in `presentation/providers/`
10. Build screens using Modern widgets:
   - Import: `import 'package:kasbon_frontend/shared/modern/modern.dart';`
   - Use `ModernAppBar.*` for app bars
   - Use `ModernButton.*` for all buttons
   - Use `ModernTextField`, `ModernCurrencyField` for inputs
   - Use `ModernCard.*` for card layouts
   - Use `ModernLoading`, `ModernEmptyState`, `ModernErrorState` for states
   - Use `ModernDialog`, `ModernToast` for feedback

## Current Status

Track progress in `../TASKS/PROGRESS.md`. MVP P0 and P1 features complete. Auth feature was implemented then reverted (Feb 2026) — `supabase_flutter` removed from pubspec.yaml. `AppConfig` dual-mode system is in place for future Phase 2 (supabase-mode) features.
