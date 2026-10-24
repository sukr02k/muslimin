/// Konfigurasi dari `--dart-define`. Nilai default aman untuk development.
abstract final class AppConfig {
  static const env =
      String.fromEnvironment('APP_ENV', defaultValue: 'development');
  static const appName =
      String.fromEnvironment('APP_NAME', defaultValue: 'Muslimin');
  static const appVersion =
      String.fromEnvironment('APP_VERSION', defaultValue: '0.1.0');
}