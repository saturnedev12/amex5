import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../constants/api_constants.dart';
import 'token_provider.dart';

/// Intercepteur d'authentification.
///
/// Injecte le Bearer token dans chaque requête.
/// Gère le refresh du token si le serveur retourne un 401.
@lazySingleton
class AuthInterceptor extends Interceptor {
  final TokenProvider _tokenProvider;

  AuthInterceptor(this._tokenProvider);

  /// Implémentation par défaut — retourne null (pas de token).
  static Future<String?> _defaultGetToken() async => null;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final tokenFn = _tokenProvider.getAccessToken ?? _defaultGetToken;
    final token = await tokenFn();
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
        _tokenProvider.getRefreshToken != null &&
        _tokenProvider.onRefresh != null) {
      final refreshToken = await _tokenProvider.getRefreshToken!();
      if (refreshToken != null) {
        final newToken = await _tokenProvider.onRefresh!(refreshToken);
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
