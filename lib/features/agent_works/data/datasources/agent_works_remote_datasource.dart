import 'package:amex5/features/agent_works/data/models/wo_model.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:amex5/core/network/api_response_parser.dart';
import '../models/check_items_work.dart';
import '../models/checklist_response_model.dart';
import '../models/sync_response_model.dart';

part 'agent_works_remote_datasource.g.dart';

@RestApi(baseUrl: null)
abstract class AgentWorksApi {
  factory AgentWorksApi(Dio dio, {String? baseUrl}) = _AgentWorksApi;

  @POST('/wmwo/sync/all')
  @DioResponseType(ResponseType.plain)
  Future<HttpResponse<String?>> fetchAllWorksRaw(
    @Body() Map<String, dynamic> body,
    @DioOptions() Options options,
  );

  @GET('/wmwo/checklist/{woCode}/{act}')
  @DioResponseType(ResponseType.plain)
  Future<HttpResponse<String?>> fetchChecklistRaw(
    @Path('woCode') String woCode,
    @Path('act') int act,
    @DioOptions() Options options,
  );
}

class AgentWorksRemoteDataSource {
  final Dio _dio;
  final AgentWorksApi _api;

  AgentWorksRemoteDataSource(Dio dio) : _dio = dio, _api = AgentWorksApi(dio);

  Future<SyncResponseModel> fetchAllWorks() async {
    final httpResponse = await _api.fetchAllWorksRaw(
      <String, dynamic>{},
      _captureAllStatuses(),
    );
    return ApiResponseParser.parseModel(
      httpResponse.response,
      SyncResponseModel.fromJson,
      operation: 'fetchAllWorks',
    );
  }

  Future<ChecklistResponseModel> fetchChecklist({
    required String woCode,
    required int act,
  }) async {
    final httpResponse = await _api.fetchChecklistRaw(
      woCode,
      act,
      _captureAllStatuses(),
    );
    return ApiResponseParser.parseModel(
      httpResponse.response,
      ChecklistResponseModel.fromJson,
      operation: 'fetchChecklist',
    );
  }

  Future<void> sendWorkStatus(WoModel work) async {
    await _dio.post<void>('/wmwo/act', data: work.toJson());
  }

  Future<void> createCheckItemWo(CheckItemsWork body) async {
    await _dio.post<void>('/wmwo/check-item/wo', data: body.toJson());
  }
}

Options _captureAllStatuses() =>
    Options(contentType: 'application/json', validateStatus: (_) => true);
