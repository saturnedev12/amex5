import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../constants/api_constants.dart';
import '../../session/session_manager.dart';
import 'token_provider.dart';

/// Intercepteur d'authentification.
///
/// Injecte le Bearer token et X-device dans chaque requête.
/// Détecte 401 EXPIRED_TOKEN et déclenche la redirection vers login.
@lazySingleton
class AuthInterceptor extends Interceptor {
  final TokenProvider _tokenProvider;
  final SessionManager _sessionManager;

  /// Callback set by the app to navigate to login on token expiry.
  static void Function()? onTokenExpired;

  AuthInterceptor(this._tokenProvider, this._sessionManager);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = _sessionManager.token;
    if (token != null && token.isNotEmpty) {
      options.headers[ApiConstants.headerAuthorization] = token;
    }
    options.headers['X-device'] = _sessionManager.xDevice;
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final body = err.response?.data;
      final isExpired =
          body is String && body.contains('EXPIRED_TOKEN') ||
          (body is Map && body.toString().contains('EXPIRED_TOKEN'));

      if (isExpired) {
        await _sessionManager.clear();
        onTokenExpired?.call();
        handler.next(err);
        return;
      }
    }
    handler.next(err);
  }
}
