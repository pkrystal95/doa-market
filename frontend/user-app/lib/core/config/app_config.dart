class AppConfig {
  static const String appName = 'DOA Market';
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.doamarket.com',
  );
  
  static const int apiTimeout = 30;
  static const int pageSize = 20;
  
  // Assets
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderPath = 'assets/images/placeholder.png';
  
  // Storage Keys
  static const String accessTokenKey = 'accessToken';
  static const String refreshTokenKey = 'refreshToken';
  static const String userKey = 'user';
  
  // API Endpoints
  static const String authLogin = '/api/v1/auth/login';
  static const String authRegister = '/api/v1/auth/register';
  static const String authRefresh = '/api/v1/auth/refresh';
  static const String products = '/api/v1/products';
  static const String orders = '/api/v1/orders';
  static const String cart = '/api/v1/cart';
  static const String profile = '/api/v1/user/profile';
}
