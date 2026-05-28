import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:amex5/core/network/api_response_parser.dart';
import '../../domain/entities/discharge_entities.dart';

part 'discharge_works_remote_datasource.g.dart';

@RestApi(baseUrl: null)
abstract class DischargeWorksApi {
  factory DischargeWorksApi(Dio dio, {String? baseUrl}) = _DischargeWorksApi;

  @POST('/test_upload')
  @DioResponseType(ResponseType.plain)
  Future<HttpResponse<String?>> uploadDischargeWorksRaw(
    @Body() Map<String, dynamic> payload,
    @DioOptions() Options options,
  );
}

class DischargeWorksRemoteDataSource {
  final DischargeWorksApi _api;

  DischargeWorksRemoteDataSource(Dio dio) : _api = DischargeWorksApi(dio);

  Future<DischargeUploadResult> uploadDischargeWorks(
    Map<String, dynamic> payload,
  ) async {
    final httpResponse = await _api.uploadDischargeWorksRaw(
      payload,
      _captureAllStatuses(),
    );
    final data = ApiResponseParser.parseMap(
      httpResponse.response,
      operation: 'uploadDischargeWorks',
      allowEmpty: true,
    );

    return DischargeUploadResult(
      success: true,
      message: data['message']?.toString() ?? 'Upload réussi.',
      responseData: data,
      uploadedAt: DateTime.now(),
    );
  }
}

Options _captureAllStatuses() =>
    Options(contentType: 'application/json', validateStatus: (_) => true);
