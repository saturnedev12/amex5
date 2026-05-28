import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:amex5/core/network/api_response_parser.dart';
import 'package:amex5/features/authentification/data/models/login_body_model.dart';
import 'package:amex5/features/authentification/data/models/login_response_model.dart';
import 'package:amex5/features/authentification/data/models/update_password_dto.dart';

part 'authentification_provider.g.dart';

@RestApi(baseUrl: null)
abstract class AuthentificationApi {
  factory AuthentificationApi(Dio dio, {String? baseUrl}) =
      _AuthentificationApi;

  @POST('/omact/login')
  @DioResponseType(ResponseType.plain)
  Future<HttpResponse<String?>> loginRaw(
    @Body() Map<String, dynamic> body,
    @DioOptions() Options options,
  );

  @PATCH('/xap-xp-auth/pwd/{employeeCode}')
  @DioResponseType(ResponseType.plain)
  Future<HttpResponse<String?>> updatePasswordRaw(
    @Path('employeeCode') String employeeCode,
    @Body() Map<String, dynamic> body,
    @DioOptions() Options options,
  );
}

class AuthentificationProvider {
  final AuthentificationApi _api;

  AuthentificationProvider(Dio dio) : _api = AuthentificationApi(dio);

  Future<LoginResponseModel> login(LoginBodyModel loginBodyModel) async {
    final httpResponse = await _api.loginRaw(
      loginBodyModel.toJson(),
      _captureAllStatuses(),
    );
    return ApiResponseParser.parseModel(
      httpResponse.response,
      LoginResponseModel.fromJson,
      operation: 'login',
    );
  }

  Future<Response> updatePassword(
    String employeeCode,
    UpdatePasswordDto updatePasswordDto,
  ) async {
    final httpResponse = await _api.updatePasswordRaw(
      employeeCode,
      updatePasswordDto.toJson(),
      _captureAllStatuses(),
    );
    return ApiResponseParser.ensureSuccess(
      httpResponse.response,
      operation: 'updatePassword',
    );
  }
}

Options _captureAllStatuses() =>
    Options(contentType: 'application/json', validateStatus: (_) => true);
