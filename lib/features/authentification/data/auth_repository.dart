import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:amex5/features/authentification/data/authentification_provider.dart';
import 'package:amex5/features/authentification/data/models/login_body_model.dart';
import 'package:amex5/features/authentification/data/models/login_response_model.dart';
import 'package:amex5/features/authentification/data/models/update_password_dto.dart';

@lazySingleton
class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<LoginResponseModel> login({required LoginBodyModel body}) async {
    try {
      final response = await AuthentificationProvider(_dio).login(body);
      return response;
    } on DioException catch (dioError) {
      print('DioError: ${dioError.message}  ${dioError.error}');
      throw Exception('Failed to login: ${dioError.message}');
    } catch (error) {
      print(error.toString());
      throw Exception('Failed to login: $error');
    }
  }

  Future<Response> updatePassword({
    required String employeeCode,
    required UpdatePasswordDto body,
  }) async {
    try {
      final response = await AuthentificationProvider(_dio).updatePassword(employeeCode, body);
      return response;
    } on DioException catch (dioError) {
      print('DioError: ${dioError.message}  ${dioError.error}');
      throw Exception('Failed to update password: ${dioError.message}');
    } catch (error) {
      print(error.toString());
      throw Exception('Failed to update password: $error');
    }
  }
}
