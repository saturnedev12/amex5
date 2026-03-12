import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/discharge_entities.dart';

class DischargeWorksRemoteDataSource {
  static const String _endpoint = '/test_upload';

  final DioClient _client;

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
