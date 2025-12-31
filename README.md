# KASBON - Kasir Bisnis Online

An offline-first POS (Point of Sale) application for Indonesian small businesses (UMKM), built with Flutter and Supabase.

## Key Features

- **100% Offline-First** - Works without internet using SQLite
- **Profit Tracking** - Track profits, not just revenue
- **Debt Management** - Built-in debt (hutang) tracking for local business needs
- **Lightweight** - Optimized for low-end devices (2GB RAM, Android 5.0+)

## Tech Stack

- **Frontend:** Flutter
- **State Management:** Riverpod
- **Local Database:** SQLite (sqflite)
- **Cloud Backend:** Supabase
- **Architecture:** Clean Architecture

## Project Structure

```
Kasbon/
├── kasbon-frontend/    # Flutter mobile app
├── supabase/           # Supabase local dev config
├── DOCS/               # Project documentation
└── TASKS/              # Development tasks
```

## Development

### Prerequisites

- Flutter SDK 3.x
- Dart SDK
- Supabase CLI (for local development)

### Setup

```bash
# Clone repository
git clone <repository-url>
cd Kasbon

# Install Flutter dependencies
cd kasbon-frontend
flutter pub get

# Run the app
flutter run
```

### Supabase Local Development

```bash
# Start local Supabase
supabase start

# Stop Supabase
supabase stop
```

## Documentation

See the `DOCS/` folder for full documentation:
- `PROJECT_BRIEF.md` - Business & technical specifications
- `TECHNICAL_REQUIREMENTS.md` - Database schema, API specs
- `FEATURE_PRIORITY_AND_PHASES.md` - Feature breakdown & priorities

## License

[License information here]
