class ApiConstants {
  ApiConstants._();

  // Base URL — à modifier selon votre environnement
  // static const String baseUrl = 'http://172.16.2.185:8090';
  static const String baseUrl = 'http://192.168.1.7:8087';
  // Timeouts
  static const int connectTimeoutMs = 50000;
  static const int receiveTimeoutMs = 50000;
  static const int sendTimeoutMs = 50000;

  // Headers
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';
  static const String headerAuthorization = 'Authorization';
  static const String headerBearerPrefix = 'Bearer ';
  static const String headerApplicationJson = 'application/json';

  // Storage keys (pour récupérer le token)
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
}
