import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../../constants/api_constants.dart';
import '../../router/app_router.dart';
import '../../session/session_manager.dart';
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
    final token = await _tokenProvider.accessToken() ?? _sessionManager.token;
    if (token != null && token.isNotEmpty) {
      options.headers[ApiConstants.headerAuthorization] = token;
    }
    options.headers['X-device'] = _sessionManager.xDevice;
    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    if (_tokenProvider.isExpiredTokenResponse(response.data)) {
      await _handleExpiredToken();
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_tokenProvider.isExpiredTokenResponse(err.response?.data)) {
      await _handleExpiredToken();
    }
    handler.next(err);
  }

  Future<void> _handleExpiredToken() async {
    await _sessionManager.clear();

    if (onTokenExpired != null) {
      final context = appNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        unawaited(onTokenExpired!(context));
        return;
      }
    }

    unawaited(_tokenProvider.showExpiredTokenDialog());
  }
}
