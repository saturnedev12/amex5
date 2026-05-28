import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:amex5/core/base/base_repository.dart';
import 'package:amex5/core/error/exceptions.dart';
import 'package:amex5/features/authentification/data/authentification_provider.dart';
import 'package:amex5/features/authentification/data/models/login_body_model.dart';
import 'package:amex5/features/authentification/data/models/login_response_model.dart';
import 'package:amex5/features/authentification/data/models/update_password_dto.dart';

@lazySingleton
class AuthRepository with SafeCallMixin {
  final AuthentificationProvider _provider;

  AuthRepository(this._provider);

  Future<LoginResponseModel> login({required LoginBodyModel body}) {
    return _runAuthCall('login', () => _provider.login(body));
  }

  Future<Response> updatePassword({
    required String employeeCode,
    required UpdatePasswordDto body,
  }) {
    return _runAuthCall(
      'updatePassword',
      () => _provider.updatePassword(employeeCode, body),
    );
  }

  Future<T> _runAuthCall<T>(String operation, Future<T> Function() call) async {
    try {
      return await call();
    } on AppException catch (error, stackTrace) {
      log(
        'AuthRepository.$operation failed: ${error.message}',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } on DioException catch (error, stackTrace) {
      final exception = exceptionFromDio(error);
      log(
        'AuthRepository.$operation failed: ${exception.message}',
        error: exception,
        stackTrace: stackTrace,
      );
      throw exception;
    }
  }
}
