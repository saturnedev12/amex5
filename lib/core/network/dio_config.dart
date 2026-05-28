import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:amex5/core/constants/api_constants.dart';
import 'package:amex5/core/network/interceptors/auth_interceptor.dart';
import 'package:amex5/core/network/interceptors/error_interceptor.dart';
import 'package:amex5/features/agent_works/data/datasources/agent_works_remote_datasource.dart';
import 'package:amex5/features/authentification/data/authentification_provider.dart';
import 'package:amex5/features/discharge_works/data/datasources/discharge_works_remote_datasource.dart';

@module
abstract class DioConfig {
  String _baseUrl() {
    final envBaseUrl = dotenv.isInitialized
        ? dotenv.env['BASE_URL']?.trim()
        : null;
    if (envBaseUrl != null && envBaseUrl.isNotEmpty) {
      return envBaseUrl.replaceAll(RegExp(r'/$'), '');
    }
    return ApiConstants.baseUrl;
  }

  @lazySingleton
  Dio dio(AuthInterceptor authInterceptor, ErrorInterceptor errorInterceptor) {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl(),
        connectTimeout: const Duration(seconds: 120),
        receiveTimeout: const Duration(seconds: 120),
        sendTimeout: const Duration(seconds: 120),
        headers: {
          ApiConstants.headerContentType: ApiConstants.headerApplicationJson,
          ApiConstants.headerAccept: '*/*',
        },
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

  @lazySingleton
  AuthentificationProvider authentificationProvider(Dio dio) {
    return AuthentificationProvider(dio);
  }

  @lazySingleton
  AgentWorksRemoteDataSource agentWorksRemoteDataSource(Dio dio) {
    return AgentWorksRemoteDataSource(dio);
  }

  @lazySingleton
  DischargeWorksRemoteDataSource dischargeWorksRemoteDataSource(Dio dio) {
    return DischargeWorksRemoteDataSource(dio);
  }
}
