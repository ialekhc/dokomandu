class AppConfig {
  const AppConfig._();

  static const String appName = 'Dokomandu';
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com/v1',
  );
  static const bool bypassAuth = bool.fromEnvironment(
    'BYPASS_AUTH',
    defaultValue: true,
  );
  static const bool useStaticContent = bool.fromEnvironment(
    'USE_STATIC_CONTENT',
    defaultValue: true,
  );

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 20);

  static const double serviceRadiusInKm = 3.0;

  static const String hiveBoxAppCache = 'app_cache_box';
  static const String hiveBoxCart = 'cart_box';
}
