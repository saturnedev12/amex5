import 'package:dio/dio.dart';
import 'package:amex5/features/authentification/data/models/login_body_model.dart';
import 'package:amex5/features/authentification/data/models/login_response_model.dart';
import 'package:amex5/features/authentification/data/models/update_password_dto.dart';

class AuthentificationProvider {
  final Dio dio;

  AuthentificationProvider(this.dio);

  Future<LoginResponseModel> login(LoginBodyModel loginBodyModel) async {
    final response = await dio.post(
      "/omact/login",
      data: loginBodyModel.toJson(),
    );
    return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Response> updatePassword(
    String employeeCode,
    UpdatePasswordDto updatePasswordDto,
  ) async {
    final response = await dio.patch(
      "/xap-xp-auth/pwd/$employeeCode",
      data: updatePasswordDto.toJson(),
    );
    return response;
  }
}
