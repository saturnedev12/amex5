import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../../constants/api_constants.dart';
import '../../session/session_manager.dart';
import '../dialogs/token_expired_dialog.dart';
import '../../router/app_router.dart';
import 'token_provider.dart';

/// Intercepteur d'authentification.
///
/// Injecte le Bearer token et X-device dans chaque requête.
/// Détecte 401 EXPIRED_TOKEN et déclenche le callback pour re-login.
@lazySingleton
class AuthInterceptor extends Interceptor {
  final TokenProvider _tokenProvider;
  final SessionManager _sessionManager;

  /// Callback set by the app to handle token expiry — typically shows a re-login dialog.
  static Future<void> Function(BuildContext)? onTokenExpired;

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
          (body is String && body.contains('EXPIRED_TOKEN')) ||
          (body is Map && body.toString().contains('EXPIRED_TOKEN'));

      if (isExpired) {
        await _sessionManager.clear();

        // Afficher le dialog de re-login si on a un contexte disponible
        final context = appNavigatorKey.currentContext;
        if (context != null && context.mounted) {
          Future.microtask(() async {
            // Utiliser le callback personnalisé s'il existe, sinon afficher le dialog par défaut
            if (onTokenExpired != null) {
              await onTokenExpired!(context);
            } else {
              await showTokenExpiredDialog(context);
            }
          });
        }

        handler.next(err);
        return;
      }
    }
    handler.next(err);
  }
}
