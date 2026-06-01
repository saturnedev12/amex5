import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../domain/entities/discharge_file_entities.dart';

class DischargeFilesRemoteDataSource {
  final Dio _dio;

  DischargeFilesRemoteDataSource(this._dio);

  Future<FileUploadResponse> uploadFile({
    required String taskCode,
    required String lastModifiedDate,
    required String ref,
    required String label,
    required File file,
  }) async {
    final formData = FormData.fromMap({
      'lastModifiedDate': lastModifiedDate,
      'ref': ref,
      'label': label,
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.uri.pathSegments.isEmpty
            ? 'file'
            : file.uri.pathSegments.last,
      ),
    });

    final response = await _dio.post<dynamic>(
      '/wmwo/check-item/doc/${Uri.encodeComponent(taskCode)}',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return FileUploadResponse.fromJson(data);
    }
    if (data is Map) {
      return FileUploadResponse.fromJson(
        data.map((key, value) => MapEntry(key.toString(), value)),
      );
    }
    if (data is String && data.trim().isNotEmpty) {
      final decoded = jsonDecode(data);
      if (decoded is Map) {
        return FileUploadResponse.fromJson(
          decoded.map((key, value) => MapEntry(key.toString(), value)),
        );
      }
    }

    throw const FormatException('Réponse upload fichier invalide.');
  }
}
