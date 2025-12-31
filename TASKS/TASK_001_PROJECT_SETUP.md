# TASK_001: Project Setup & Architecture

**Priority:** P0 (Critical)
**Complexity:** MEDIUM
**Phase:** MVP - Setup
**Status:** Completed

---

## Objective

Set up Flutter project with Clean Architecture structure, state management (Riverpod), navigation (GoRouter), and all required dependencies for MVP development.

---

## Prerequisites

- None (this is the first task)

---

## Subtasks

### 1. Package Configuration
- [x] Update `pubspec.yaml` package name from `kasbon_app` to `kasbon_pos`
- [x] Update Flutter SDK constraint to stable: `sdk: '>=3.2.0 <4.0.0'`
- [x] Add all MVP dependencies (see Dependencies section)
- [x] Add dev dependencies (build_runner, freezed, etc.)
- [x] Run `flutter pub get` to install packages

### 2. Android Configuration
- [x] Update `android/app/build.gradle` applicationId to `com.kasbon.pos`
- [x] Update `android/app/src/main/AndroidManifest.xml` app label to "KASBON"
- [x] Set minimum SDK to API 21 (Android 5.0)
- [x] Configure app icon placeholder

### 3. Folder Structure
- [x] Create `lib/core/constants/` directory
- [x] Create `lib/core/errors/` directory
- [x] Create `lib/core/utils/` directory
- [x] Create `lib/core/usecase/` directory
- [x] Create `lib/config/routes/` directory
- [x] Create `lib/config/theme/` directory
- [x] Create `lib/config/database/` directory
- [x] Create `lib/config/di/` directory
- [x] Create `lib/features/products/` directory (with data/, domain/, presentation/ subdirs)
- [x] Create `lib/features/pos/` directory (with data/, domain/, presentation/ subdirs)
- [x] Create `lib/features/transactions/` directory (with data/, domain/, presentation/ subdirs)
- [x] Create `lib/features/reports/` directory (with data/, domain/, presentation/ subdirs)
- [x] Create `lib/features/dashboard/` directory (with data/, domain/, presentation/ subdirs)
- [x] Create `lib/features/settings/` directory (with data/, domain/, presentation/ subdirs)
- [x] Create `lib/shared/widgets/` directory
- [x] Create `lib/shared/providers/` directory

### 4. Assets Setup
- [x] Create `assets/images/` directory
- [x] Create `assets/icons/` directory
- [x] Create `assets/sample_data/` directory (for testing)
- [x] Update `pubspec.yaml` assets configuration

### 5. Base App Setup
- [x] Create `lib/core/constants/app_constants.dart`
- [x] Create `lib/config/routes/app_router.dart` (GoRouter setup)
- [x] Create `lib/config/theme/app_theme.dart`
- [x] Create `lib/config/theme/app_colors.dart`
- [x] Create `lib/config/di/injection.dart` (GetIt setup)
- [x] Update `lib/main.dart` with ProviderScope and basic app structure

---

## Dependencies to Add

### pubspec.yaml - dependencies:
```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # Local Database (Offline-First)
  sqflite: ^2.3.0
  path_provider: ^2.1.1
  path: ^1.8.3

  # Local Storage (Settings, Cache)
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2

  # Dependency Injection
  get_it: ^7.6.4

  # Navigation
  go_router: ^12.1.1

  # UI Components
  fl_chart: ^0.65.0
  shimmer: ^3.0.0
  flutter_slidable: ^3.0.1

  # Utilities
  intl: ^0.18.1
  uuid: ^4.2.1
  equatable: ^2.0.5
  dartz: ^0.10.1
  logger: ^2.0.2
```

### pubspec.yaml - dev_dependencies:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

  # Code Generation
  build_runner: ^2.4.6
  riverpod_generator: ^2.3.9
  freezed: ^2.4.5
  freezed_annotation: ^2.4.1
  json_serializable: ^6.7.1

  # Testing
  mocktail: ^1.0.1
```

---

## Target Folder Structure

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── errors/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   ├── utils/
│   │   ├── currency_formatter.dart
│   │   ├── date_formatter.dart
│   │   └── validators.dart
│   └── usecase/
│       └── usecase.dart
├── config/
│   ├── routes/
│   │   └── app_router.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   └── app_text_styles.dart
│   ├── database/
│   │   └── (TASK_002)
│   └── di/
│       └── injection.dart
├── features/
│   ├── products/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   ├── pos/
│   ├── transactions/
│   ├── reports/
│   ├── dashboard/
│   └── settings/
└── shared/
    ├── widgets/
    └── providers/
```

---

## Files to Create

| File | Purpose |
|------|---------|
| `lib/core/constants/app_constants.dart` | App-wide constants |
| `lib/core/errors/failures.dart` | Failure classes for error handling |
| `lib/core/errors/exceptions.dart` | Exception classes |
| `lib/core/usecase/usecase.dart` | Base UseCase class |
| `lib/config/routes/app_router.dart` | GoRouter configuration |
| `lib/config/theme/app_theme.dart` | ThemeData configuration |
| `lib/config/theme/app_colors.dart` | Color constants |
| `lib/config/di/injection.dart` | GetIt service locator |
| `lib/main.dart` | Updated app entry point |

---

## Acceptance Criteria

- [x] `flutter pub get` runs without errors
- [x] `flutter analyze` reports no issues
- [x] `flutter run` launches app successfully
- [x] App displays with KASBON branding (app name, colors)
- [x] All directories exist in lib/ folder
- [x] GoRouter navigation is configured (even if only 1 route)
- [x] Riverpod ProviderScope wraps the app
- [x] GetIt is initialized in main()

---

## Notes

### Why Riverpod over Bloc?
- Simpler syntax for solo developer
- Less boilerplate
- Better compile-time safety
- Easier testing

### Why GetIt + Riverpod?
- GetIt for dependency injection (database, services)
- Riverpod for UI state management
- Clear separation of concerns

### Reference
- See `DOCS/TECHNICAL_REQUIREMENTS.md` Section 3.2 for full folder structure
- See `DOCS/TECHNICAL_REQUIREMENTS.md` Section 2.2 for dependencies list

---

## Estimated Time

**3-4 hours** for complete setup

---

## Next Task

After completing this task, proceed to:
- [TASK_002_DATABASE_SETUP.md](./TASK_002_DATABASE_SETUP.md)
