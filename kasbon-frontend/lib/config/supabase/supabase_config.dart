/// Supabase configuration for KASBON POS app
///
/// Uses compile-time environment variables with sensible defaults for local development.
/// For production builds, pass values via --dart-define flags:
///
/// ```bash
/// # Local development (default)
/// flutter run
///
/// # Production build
/// flutter run --dart-define=PRODUCTION=true \
///   --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=your-anon-key
/// ```
class SupabaseConfig {
  SupabaseConfig._();

  /// Whether the app is running in production mode
  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false,
  );

  /// Supabase project URL
  ///
  /// Defaults to local Supabase instance (Docker) for development.
  /// Override with --dart-define=SUPABASE_URL=https://xxx.supabase.co
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'http://127.0.0.1:54321',
  );

  /// Supabase anonymous key
  ///
  /// For local development, get this from `supabase status` command.
  /// For production, get from Supabase Dashboard -> Project Settings -> API.
  ///
  /// Default value is the standard local Supabase anon key.
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH',
  );

  /// Validate configuration
  ///
  /// Returns true if configuration appears valid, false otherwise.
  static bool get isValid {
    return url.isNotEmpty && anonKey.isNotEmpty;
  }

  /// Check if using local Supabase instance
  static bool get isLocal {
    return url.contains('127.0.0.1') || url.contains('localhost');
  }
}
