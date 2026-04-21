import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:amex5/features/agent_works/data/models/wo_model.dart';

@lazySingleton
class BleReceiveRemoteDataSource {
  final Dio _dio;

  BleReceiveRemoteDataSource(this._dio);

  /// POST /wmwo/act — soumet un travail unique vers l'API.
  Future<void> submitWork(WoModel wo) async {
    await _dio.post<void>('/wmwo/act', data: wo.toJson());
  }
}
