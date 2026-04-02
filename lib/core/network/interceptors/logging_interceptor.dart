import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Intercepteur de journalisation — affiche les requêtes/réponses/erreurs
/// dans la console. À désactiver en production via [enabled].
@lazySingleton
class LoggingInterceptor extends Interceptor {
  final bool enabled;

  LoggingInterceptor({this.enabled = true});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enabled) {
      developer.log(
        '┌─────────────────────────────────────────────────────────',
        name: 'HTTP',
      );
      developer.log(
        '│ ➤  ${options.method.toUpperCase()} ${options.uri}',
        name: 'HTTP',
      );
      if (options.headers.isNotEmpty) {
        developer.log('│ Headers: ${options.headers}', name: 'HTTP');
      }
      if (options.data != null) {
        developer.log('│ Body: ${options.data}', name: 'HTTP');
      }
      if (options.queryParameters.isNotEmpty) {
        developer.log('│ Query: ${options.queryParameters}', name: 'HTTP');
      }
      developer.log(
        '└─────────────────────────────────────────────────────────',
        name: 'HTTP',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (enabled) {
      developer.log(
        '┌─────────────────────────────────────────────────────────',
        name: 'HTTP',
      );
      developer.log(
        '│ ✔  ${response.statusCode} ${response.requestOptions.uri}',
        name: 'HTTP',
      );
      developer.log('│ Response: ${response.data}', name: 'HTTP');
      developer.log(
        '└─────────────────────────────────────────────────────────',
        name: 'HTTP',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enabled) {
      developer.log(
        '┌─────────────────────────────────────────────────────────',
        name: 'HTTP',
        error: err,
      );
      developer.log(
        '│ ✘  [${err.response?.statusCode}] ${err.requestOptions.uri}',
        name: 'HTTP',
      );
      developer.log('│ Error: ${err.message}', name: 'HTTP');
      if (err.response?.data != null) {
        developer.log('│ Response: ${err.response?.data}', name: 'HTTP');
      }
      developer.log(
        '└─────────────────────────────────────────────────────────',
        name: 'HTTP',
      );
    }
    handler.next(err);
  }
}
