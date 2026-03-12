import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';

/// Intercepteur d'authentification.
///
/// Injecte le Bearer token dans chaque requête.
/// Gère le refresh du token si le serveur retourne un 401.
class AuthInterceptor extends Interceptor {
  /// Fournisseur de token — à remplacer par votre service de stockage
  /// (par ex. SharedPreferences, flutter_secure_storage, etc.).
  final Future<String?> Function() _getAccessToken;
  final Future<String?> Function()? _getRefreshToken;
  final Future<String?> Function(String refreshToken)? _onRefresh;

  AuthInterceptor({
    Future<String?> Function()? getAccessToken,
    Future<String?> Function()? getRefreshToken,
    Future<String?> Function(String refreshToken)? onRefresh,
  }) : _getAccessToken = getAccessToken ?? _defaultGetToken,
       _getRefreshToken = getRefreshToken,
       _onRefresh = onRefresh;

  /// Implémentation par défaut — retourne null (pas de token).
  /// Remplacez-la via le constructeur.
  static Future<String?> _defaultGetToken() async => null;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers[ApiConstants.headerAuthorization] =
          '${ApiConstants.headerBearerPrefix}$token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Tentative de refresh si 401 et refresh token disponible
    if (err.response?.statusCode == 401 &&
        _getRefreshToken != null &&
        _onRefresh != null) {
      final refreshToken = await _getRefreshToken();
      if (refreshToken != null) {
        final newToken = await _onRefresh(refreshToken);
        if (newToken != null) {
          // Rejoue la requête avec le nouveau token
          final opts = err.requestOptions;
          opts.headers[ApiConstants.headerAuthorization] =
              '${ApiConstants.headerBearerPrefix}$newToken';
          try {
            final dio = Dio();
            final response = await dio.fetch(opts);
            return handler.resolve(response);
          } catch (e) {
            // Le retry a échoué → on propage l'erreur
          }
        }
      }
    }
    handler.next(err);
  }
}
