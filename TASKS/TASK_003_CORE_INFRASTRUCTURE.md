# TASK_003: Core Infrastructure

**Priority:** P0 (Critical)
**Complexity:** MEDIUM
**Phase:** MVP - Setup
**Status:** Completed

---

## Objective

Create core utilities, error handling, base widgets, and theme configuration that will be used throughout the application.

---

## Prerequisites

- [x] TASK_001: Project Setup & Architecture
- [x] TASK_002: Database Setup

---

## Subtasks

### 1. Error Handling
- [x] Create `lib/core/errors/failures.dart` - Failure classes
- [x] Create `lib/core/errors/exceptions.dart` - Exception classes

### 2. Utilities
- [x] Create `lib/core/utils/currency_formatter.dart` - Format Rp currency
- [x] Create `lib/core/utils/date_formatter.dart` - Indonesian date format
- [x] Create `lib/core/utils/validators.dart` - Input validation helpers
- [x] Create `lib/core/utils/sku_generator.dart` - Auto-generate SKU

### 3. Base Classes
- [x] Create `lib/core/usecase/usecase.dart` - Base UseCase class
- [x] Create `lib/core/utils/type_defs.dart` - Common type definitions

### 4. Theme Configuration
- [x] Create `lib/config/theme/app_colors.dart` - Color palette
- [x] Create `lib/config/theme/app_text_styles.dart` - Typography
- [x] Update `lib/config/theme/app_theme.dart` - Complete theme

### 5. Shared Widgets
- [x] Create `lib/shared/widgets/app_text_field.dart` - Custom text input
- [x] Create `lib/shared/widgets/app_button.dart` - Primary/secondary buttons
- [x] Create `lib/shared/widgets/loading_widget.dart` - Loading indicator
- [x] Create `lib/shared/widgets/empty_state_widget.dart` - Empty list state
- [x] Create `lib/shared/widgets/error_widget.dart` - Error display

### 6. Navigation Setup
- [x] Update `lib/config/routes/app_router.dart` with placeholder routes
- [x] Create `lib/config/routes/route_names.dart` - Route constants (in app_router.dart as AppRoutes)

---

## Files to Create

### Error Handling

**lib/core/errors/failures.dart**
```dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Database error occurred']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Item not found']);
}
```

**lib/core/errors/exceptions.dart**
```dart
class DatabaseException implements Exception {
  final String message;
  const DatabaseException([this.message = 'Database error']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error']);
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Not found']);
}
```

### Utilities

**lib/core/utils/currency_formatter.dart**
```dart
import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String format(double amount) {
    return _formatter.format(amount);
  }

  static String formatCompact(double amount) {
    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return format(amount);
  }

  static double parse(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(cleaned) ?? 0;
  }
}
```

**lib/core/utils/date_formatter.dart**
```dart
import 'package:intl/intl.dart';

class DateFormatter {
  static final _fullFormat = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');
  static final _dateOnly = DateFormat('dd MMMM yyyy', 'id_ID');
  static final _shortDate = DateFormat('dd/MM/yyyy', 'id_ID');
  static final _timeOnly = DateFormat('HH:mm', 'id_ID');
  static final _dayMonth = DateFormat('dd MMM', 'id_ID');

  static String full(DateTime date) => _fullFormat.format(date);
  static String dateOnly(DateTime date) => _dateOnly.format(date);
  static String shortDate(DateTime date) => _shortDate.format(date);
  static String timeOnly(DateTime date) => _timeOnly.format(date);
  static String dayMonth(DateTime date) => _dayMonth.format(date);

  static String relative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hari ini, ${timeOnly(date)}';
    } else if (diff.inDays == 1) {
      return 'Kemarin, ${timeOnly(date)}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else {
      return dateOnly(date);
    }
  }
}
```

**lib/core/utils/sku_generator.dart**
```dart
class SkuGenerator {
  static String generate(String productName) {
    final prefix = productName
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]'), '')
        .substring(0, productName.length > 3 ? 3 : productName.length);

    final timestamp = DateTime.now().millisecondsSinceEpoch % 100000;
    return '$prefix-$timestamp';
  }
}
```

### Theme

**lib/config/theme/app_colors.dart**
```dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const primary = Color(0xFFFF6B35);      // Orange
  static const primaryDark = Color(0xFFE55A2B);
  static const primaryLight = Color(0xFFFF8F66);

  // Secondary
  static const secondary = Color(0xFF1E3A8A);    // Navy Blue
  static const secondaryDark = Color(0xFF152A61);

  // Status
  static const success = Color(0xFF10B981);      // Green
  static const warning = Color(0xFFF59E0B);      // Yellow
  static const error = Color(0xFFEF4444);        // Red
  static const info = Color(0xFF3B82F6);         // Blue

  // Neutral
  static const background = Color(0xFFF5F5F5);
  static const surface = Color(0xFFFFFFFF);
  static const card = Color(0xFFFFFFFF);
  static const divider = Color(0xFFE5E5E5);

  // Text
  static const text = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);
  static const textLight = Color(0xFF9CA3AF);
  static const textOnPrimary = Color(0xFFFFFFFF);
}
```

**lib/config/theme/app_text_styles.dart**
```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headings
  static const h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static const h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static const h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  // Body
  static const body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.text,
  );

  static const body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Caption
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
  );

  // Button
  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // Numbers (prices, totals)
  static const number = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const numberLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
```

---

## Acceptance Criteria

- [x] All utility functions work correctly with Indonesian locale
- [x] `CurrencyFormatter.format(10000)` returns "Rp 10.000"
- [x] `DateFormatter.full(DateTime.now())` returns Indonesian formatted date
- [x] Theme is applied throughout the app
- [x] Shared widgets are reusable and follow design system
- [x] Error handling is consistent
- [x] No hardcoded strings for colors or styles

---

## Notes

### Indonesian Locale
Make sure to initialize `intl` package for Indonesian locale in main.dart:
```dart
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}
```

### Font Setup (Optional for MVP)
Consider adding custom fonts later:
- Primary: Inter
- Numbers: JetBrains Mono

For MVP, use system fonts (Roboto on Android).

---

## Estimated Time

**3-4 hours** for complete setup

---

## Next Task

After completing this task, proceed to:
- [TASK_004_PRODUCT_MANAGEMENT.md](./TASK_004_PRODUCT_MANAGEMENT.md)
