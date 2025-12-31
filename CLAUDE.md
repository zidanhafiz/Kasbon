# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

KASBON (Kasir Bisnis Online) is an offline-first POS application for Indonesian small businesses (UMKM) built with Flutter and Supabase. The app prioritizes simplicity, offline reliability, and profit tracking.

**Key Differentiators:**
- 100% offline-first (SQLite) - works without internet
- Profit tracking built-in (not just revenue)
- Debt tracking (hutang) - culture-specific for Indonesia
- Designed for low-end devices (2GB RAM, Android 5.0+)

## Project Structure

```
Kasbon/
├── kasbon-frontend/    # Flutter mobile app
├── supabase/           # Supabase local dev config
├── DOCS/               # Project documentation
│   ├── PROJECT_BRIEF.md           # Full business & technical spec
│   ├── TECHNICAL_REQUIREMENTS.md  # Database schema, API specs
│   └── FEATURE_PRIORITY_AND_PHASES.md  # Feature breakdown & priorities
└── TASKS/              # Development tasks (TASK_001-021)
    └── PROGRESS.md     # Current progress tracker
```

## Development Commands

### Flutter (run from kasbon-frontend/)
```bash
flutter pub get              # Install dependencies
flutter run                  # Run app
flutter build apk            # Build Android APK
flutter build appbundle      # Build Android App Bundle
flutter analyze              # Analyze code
flutter test                 # Run all tests
flutter test test/path/      # Run specific test directory
dart run build_runner build  # Generate code (freezed, riverpod, json)
dart format lib/             # Format code
```

### Supabase Local Development (run from project root)
```bash
supabase start               # Start local Supabase (API: 54321, DB: 54322)
supabase stop                # Stop local Supabase
supabase migration new <name>  # Create new migration
supabase db push             # Apply migrations to local
supabase db reset            # Reset local database
```

## Architecture

**Pattern:** Clean Architecture with feature-based modules

```
lib/
├── main.dart
├── core/                    # Shared utilities, constants, base classes
│   ├── constants/           # App-wide constants
│   ├── errors/              # Failures & Exceptions
│   ├── utils/               # Formatters (currency, date), validators
│   └── usecase/             # Base UseCase class
├── config/
│   ├── di/                  # Dependency injection (GetIt)
│   ├── routes/              # Navigation (GoRouter)
│   └── theme/               # Colors, typography, dimensions
├── features/                # Feature modules
│   └── <feature>/
│       ├── data/
│       │   ├── datasources/ # Local SQLite / Remote Supabase
│       │   ├── models/      # DTOs with JSON serialization
│       │   └── repositories/# Repository implementations
│       ├── domain/
│       │   ├── entities/    # Business models
│       │   ├── repositories/# Abstract interfaces
│       │   └── usecases/    # Business logic
│       └── presentation/
│           ├── providers/   # Riverpod state management
│           ├── screens/     # Page widgets
│           └── widgets/     # Feature-specific widgets
└── shared/
    ├── modern/              # REQUIRED: Modern Widget Library (use this)
    │   ├── modern.dart      # Main export
    │   ├── components/      # Buttons, cards, inputs, layout, feedback
    │   └── utils/           # Variants and enums
    └── widgets/             # DEPRECATED: Legacy widgets (do not use)
```

**Key Libraries:**
- **State Management:** Riverpod (flutter_riverpod, riverpod_generator)
- **Navigation:** GoRouter
- **Local Database:** SQLite (sqflite) - offline-first
- **Code Generation:** Freezed, JSON Serializable
- **DI:** GetIt

## Modern Widget Library (REQUIRED)

**CRITICAL:** All UI development MUST use the Modern Widget Library from `lib/shared/modern/`.

**Import:**
```dart
import 'package:kasbon_frontend/shared/modern/modern.dart';
```

**Available Components:**
| Category | Widgets |
|----------|---------|
| **Buttons** | `ModernButton` (primary/secondary/outline/text/destructive), `ModernIconButton` |
| **Cards** | `ModernCard` (elevated/outlined/filled), `ModernGradientCard` (primary/success/warning/error) |
| **Inputs** | `ModernTextField`, `ModernCurrencyField`, `ModernSearchField`, `ModernDropdown`, `ModernQuantityStepper` |
| **Layout** | `ModernAppShell`, `ModernAppBar`, `ModernScaffold`, `ModernDivider`, `ModernSectionHeader` |
| **Feedback** | `ModernDialog`, `ModernToast`, `ModernLoading`, `ModernBottomSheet`, `ModernEmptyState`, `ModernErrorState` |
| **Data Display** | `ModernBadge`, `ModernChip`, `ModernAvatar`, `ModernListTile`, `ModernSummaryRow`, `ModernDataTable` |

**Widget Replacement Table:**
| Instead of... | Use Modern Widget |
|--------------|-------------------|
| `ElevatedButton` | `ModernButton.primary()` |
| `OutlinedButton` | `ModernButton.outline()` |
| `TextButton` | `ModernButton.text()` |
| `TextField` | `ModernTextField` |
| `Card` | `ModernCard.elevated()` |
| `CircularProgressIndicator` | `ModernLoading()` |
| `AlertDialog` | `ModernDialog` |
| `SnackBar` | `ModernToast` |

**Size Variants:** All components support `ModernSize.small`, `ModernSize.medium`, `ModernSize.large`

**Responsive Design:**
```dart
if (context.isMobile) { /* mobile layout */ }
else { /* tablet layout */ }
```

## Database Schema

Main tables (SQLite locally, PostgreSQL in Supabase cloud):

- `shop_settings` - Single row for shop config
- `categories` - Product categories (Makanan, Minuman, etc.)
- `products` - Products with cost_price and selling_price for profit tracking
- `transactions` - Transaction headers with payment_status (paid/debt)
- `transaction_items` - Line items with snapshot of prices at transaction time

**Important:** Always use parameterized queries for SQLite. Store timestamps as milliseconds since epoch (INTEGER).

## Development Task Order

Follow TASKS/ directory in numerical order. Check TASKS/PROGRESS.md for current status.

**Phases:**
1. **Setup (001-003):** Project structure, database, core infrastructure
2. **MVP P0 (004-009):** Products, POS, transactions, dashboard, receipt, stock
3. **MVP P1 (010-014):** Profit, debt tracking, reports, settings, backup
4. **Testing (015-016):** Unit/widget tests, beta prep
5. **Phase 2 (017-021):** Auth, cloud sync, advanced reports, QRIS, deployment

## Feature Priorities

**P0 (Critical MVP):** Product management, POS (cash only), transaction history, dashboard, digital receipt, stock tracking, profit display

**P1 (Pre-launch polish):** Debt tracking (hutang), low stock alerts, basic reports, settings, backup/restore

**P2 (Phase 2 - Cloud):** Authentication, cloud sync, QRIS payment, customer database

**P3 (Nice-to-have):** Barcode scanner, product photos, category management, thermal printing

## UI/UX Guidelines

### Design System (Use Theme Tokens)
- **Colors:** Use `AppColors.*` from `config/theme/app_colors.dart` (never hardcode hex)
- **Spacing:** Use `AppDimensions.spacing*` (4, 8, 12, 16, 20, 24, 32, 40, 48)
- **Typography:** Use `AppTextStyles.*` (h1-h4, bodyLarge/Medium/Small, priceLarge/Medium/Small, button)
- **Radius:** Use `AppDimensions.radius*` (Small: 4, Medium: 8, Large: 12, XLarge: 16)

### Color Palette (AppColors)
- Primary: Blue `#2563EB` (trust, professional)
- Primary Dark: `#1D4ED8`
- Secondary: Navy Blue `#1E3A8A`
- Success: `#10B981`, Warning: `#F59E0B`, Error: `#EF4444`, Info: `#3B82F6`

### Design Principles
- Touch targets: minimum 48dp (`AppDimensions.minTouchTarget`)
- All text in Bahasa Indonesia
- Clear offline status indicators using `ModernBadge`
- Loading states with `ModernLoading()`
- Empty states with `ModernEmptyState()`
- Error states with `ModernErrorState()`
- Support 4.5"+ screens with responsive design

## Code Style Notes

- Use `Rp` currency format with `intl` package (Indonesian locale)
- Transaction numbers format: `TRX-YYYYMMDD-XXXX`
- Always handle empty states and loading states
- Prefer `Either<Failure, T>` from dartz for repository returns
- Use freezed for immutable data classes

### Widget Usage Rules
- ALWAYS import Modern widgets: `import 'package:kasbon_frontend/shared/modern/modern.dart';`
- NEVER use deprecated widgets from `lib/shared/widgets/`
- Use factory constructors: `ModernButton.primary()`, `ModernCard.elevated()`
- Handle async states with `ModernLoading`, `ModernEmptyState`, `ModernErrorState`
- Use `context.isMobile` for responsive layout decisions

## Performance Targets

- Cold start: < 3 seconds
- Screen navigation: < 300ms
- Search results: < 500ms
- Transaction creation: < 1 second
- App size: < 50MB

## Testing

- Unit tests: 70% coverage target (business logic, use cases)
- Widget tests: Critical UI components
- Integration tests: Complete transaction flow
- Manual testing on low-end Android (2GB RAM)
