import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:amex5/core/constants/api_constants.dart';
import 'package:amex5/core/network/interceptors/auth_interceptor.dart';
import 'package:amex5/core/network/interceptors/error_interceptor.dart';
import 'package:amex5/core/network/interceptors/logging_interceptor.dart';

@module
abstract class DioConfig {
  @lazySingleton
  Dio dio(
    AuthInterceptor authInterceptor,
    ErrorInterceptor errorInterceptor,
    LoggingInterceptor loggingInterceptor,
  ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeoutMs),
        sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeoutMs),
        headers: {
          ApiConstants.headerContentType: ApiConstants.headerApplicationJson,
          ApiConstants.headerAccept: ApiConstants.headerApplicationJson,
        },
        responseType: ResponseType.json,
      ),
    );
    dio.interceptors.addAll([
      loggingInterceptor,
      authInterceptor,
      errorInterceptor,
    ]);
    return dio;
  }
}
