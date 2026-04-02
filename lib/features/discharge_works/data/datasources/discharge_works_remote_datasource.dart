import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/discharge_entities.dart';

@lazySingleton
class DischargeWorksRemoteDataSource {
  static const String _endpoint = '/test_upload';

  final Dio _client;

  DischargeWorksRemoteDataSource(this._client);

  Future<DischargeUploadResult> uploadDischargeWorks(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        _endpoint,
        data: payload,
      );

      final data = response.data;
      return DischargeUploadResult(
        success: true,
        message: data?['message']?.toString() ?? 'Upload réussi.',
        responseData: data,
        uploadedAt: DateTime.now(),
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }
}
