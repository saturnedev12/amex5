import 'dart:io';

import 'package:amex5/core/base/base_repository.dart';
import 'package:amex5/core/utils/result.dart';

import '../../data/datasources/discharge_files_remote_datasource.dart';
import '../entities/discharge_file_entities.dart';

class DischargeFilesRepository with SafeCallMixin {
  final DischargeFilesRemoteDataSource _remote;

  DischargeFilesRepository(this._remote);

  Future<Result<FileUploadResponse>> uploadFile({
    required String taskCode,
    required String lastModifiedDate,
    required String ref,
    required String label,
    required File file,
  }) {
    return safeCall(
      () => _remote.uploadFile(
        taskCode: taskCode,
        lastModifiedDate: lastModifiedDate,
        ref: ref,
        label: label,
        file: file,
      ),
    );
  }
}
