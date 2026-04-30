import 'dart:developer' show inspect, log;

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/sync_response_model.dart';
import '../models/checklist_response_model.dart';

@lazySingleton
class AgentWorksRemoteDataSource {
  final Dio _dio;

  AgentWorksRemoteDataSource(this._dio);

  /// GET /wmwo/sync/all — load all work orders for the user.
  Future<SyncResponseModel> fetchAllWorks() async {
    final response = await _dio.post('/wmwo/sync/all', data: {});
    return SyncResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /wmwo/checklist/{woCode}/{act} — load checklist for a specific WO.
  Future<ChecklistResponseModel> fetchChecklist({
    required String woCode,
    required int act,
  }) async {
log("TAG");
    final response = await _dio.get('/wmwo/checklist/$woCode/$act');
    
    inspect(response);
    return ChecklistResponseModel();
    // return ChecklistResponseModel.fromJson(
    //   response.data as Map<String, dynamic>,
    // );                                      
                                                
                                                 
  }
}
