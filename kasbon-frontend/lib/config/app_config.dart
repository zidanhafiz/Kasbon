/// Application configuration using compile-time flags.
///
/// Build commands:
/// - Local mode (default): flutter build apk
/// - Supabase mode: flutter build apk --dart-define=APP_MODE=supabase
///     --dart-define=SUPABASE_URL=https://xxx.supabase.co
///     --dart-define=SUPABASE_ANON_KEY=your-key
class AppConfig {
  AppConfig._();

  static const String appMode = String.fromEnvironment(
    'APP_MODE',
    defaultValue: 'local',
  );

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static bool get isLocalMode => appMode != 'supabase';
  static bool get isSupabaseMode => appMode == 'supabase';

  static bool get isSupabaseConfigValid =>
      isLocalMode || (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty);

  static String get modeLabel => isSupabaseMode ? 'Cloud (Supabase)' : 'Lokal';
}
