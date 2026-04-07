import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:amex5/core/constants/api_constants.dart';
import 'package:amex5/core/network/interceptors/auth_interceptor.dart';
import 'package:amex5/core/network/interceptors/error_interceptor.dart';

@module
abstract class DioConfig {
  @lazySingleton
  Dio dio(AuthInterceptor authInterceptor, ErrorInterceptor errorInterceptor) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: ApiConstants.connectTimeoutMs,
        ),
        receiveTimeout: const Duration(
          milliseconds: ApiConstants.receiveTimeoutMs,
        ),
        sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeoutMs),
        headers: {
          ApiConstants.headerContentType: ApiConstants.headerApplicationJson,
          ApiConstants.headerAccept: ApiConstants.headerApplicationJson,
        },
        responseType: ResponseType.json,
      ),
    );
    dio.interceptors.addAll([
      if (kDebugMode)
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      authInterceptor,
      errorInterceptor,
    ]);
    return dio;
  }
}
