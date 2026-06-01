import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'package:amex5/core/ble/ble_service.dart';

import '../../domain/entities/discharge_file_entities.dart';
import '../../domain/repositories/discharge_files_repository.dart';

class DischargeFilesCubit extends Cubit<DischargeFilesState> {
  final BleService _bluetoothService;
  final DischargeFilesRepository _repository;
  StreamSubscription<Map<String, dynamic>>? _jsonSubscription;

  DischargeFilesCubit(this._bluetoothService, this._repository)
    : super(const DischargeFilesState()) {
    _jsonSubscription = _bluetoothService.receivedJsonStream.listen(
      handleBluetoothJson,
      onError: (Object error) => emit(
        state.copyWith(errorMessage: 'Erreur réception bluetooth : $error'),
      ),
    );
  }

  Future<void> handleBluetoothJson(Map<String, dynamic> json) async {
    final type = json['TYPE']?.toString();
    try {
      switch (type) {
        case 'FILES_TRANSFER_MANIFEST':
          _handleManifest(json);
        case 'FILE_TRANSFER_ITEM':
          await _handleFileItem(json);
        case 'FILES_TRANSFER_COMPLETE':
          _handleComplete(json);
        case null:
          return;
        default:
          return;
      }
    } catch (error) {
      emit(state.copyWith(errorMessage: 'Fichier bluetooth invalide : $error'));
    }
  }

  void selectFile(String id) {
    emit(state.copyWith(selectedFileId: id));
  }

  Future<void> uploadFile(String id) async {
    final file = state.files.where((item) => item.id == id).firstOrNull;
    if (file == null || file.path == null) return;

    final localFile = File(file.path!);
    if (!await localFile.exists()) {
      emit(
        _replaceFile(
          file.copyWith(
            uploadStatus: DischargeFileUploadStatus.error,
            errorMessage: 'Fichier local introuvable.',
          ),
        ),
      );
      return;
    }

    if (file.metadata.taskCode.isEmpty) {
      emit(
        _replaceFile(
          file.copyWith(
            uploadStatus: DischargeFileUploadStatus.error,
            errorMessage: 'taskCode manquant pour l’upload API.',
          ),
        ),
      );
      return;
    }

    emit(
      _replaceFile(
        file.copyWith(
          uploadStatus: DischargeFileUploadStatus.uploading,
          clearError: true,
        ),
      ).copyWith(clearError: true, clearSuccess: true),
    );

    final result = await _repository.uploadFile(
      taskCode: file.metadata.taskCode,
      lastModifiedDate: file.metadata.lastModifiedDate,
      ref: file.metadata.ref,
      label: file.metadata.label,
      file: localFile,
    );

    result.fold(
      (failure) => emit(
        _replaceFile(
          file.copyWith(
            uploadStatus: DischargeFileUploadStatus.error,
            errorMessage: failure.message,
          ),
        ).copyWith(errorMessage: failure.message),
      ),
      (response) => emit(
        _replaceFile(
          file.copyWith(
            uploadStatus: DischargeFileUploadStatus.uploaded,
            serverCode: response.code,
            serverRef: response.ref,
            clearError: true,
          ),
        ),
      ),
    );
  }

  Future<void> uploadAll() async {
    if (state.isUploadingAll) return;
    emit(
      state.copyWith(
        isUploadingAll: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    for (final file in state.files) {
      final current = state.files
          .where((item) => item.id == file.id)
          .firstOrNull;
      if (current == null ||
          !current.received ||
          current.uploadStatus == DischargeFileUploadStatus.uploaded) {
        continue;
      }
      await uploadFile(current.id);
    }

    final errorCount = state.files
        .where((file) => file.uploadStatus == DischargeFileUploadStatus.error)
        .length;
    emit(
      state.copyWith(
        isUploadingAll: false,
        successMessage: errorCount == 0
            ? 'Tous les fichiers reçus ont été envoyés.'
            : null,
        errorMessage: errorCount == 0
            ? null
            : '$errorCount fichier(s) en erreur pendant l’upload.',
        clearError: errorCount == 0,
        clearSuccess: errorCount != 0,
      ),
    );
  }

  void reset() {
    emit(const DischargeFilesState());
  }

  void _handleManifest(Map<String, dynamic> json) {
    final filesJson = json['files'] is List ? json['files'] as List : const [];
    final files = filesJson.asMap().entries.map((entry) {
      return ReceivedDischargeFile.fromJson(
        _toStringMap(entry.value),
        index: entry.key,
      );
    }).toList();

    emit(
      DischargeFilesState(
        transferId: json['transferId']?.toString(),
        createdAt: json['createdAt']?.toString(),
        totalFiles: (json['totalFiles'] as num?)?.toInt() ?? files.length,
        files: files,
        selectedFileId: files.isEmpty ? null : files.first.id,
        successMessage:
            'Manifeste reçu : ${files.length} fichier(s) annoncé(s).',
      ),
    );
  }

  Future<void> _handleFileItem(Map<String, dynamic> json) async {
    final fileJson = _toStringMap(json['file']);
    final base64Value = fileJson['base64']?.toString() ?? '';
    final bytes = base64Decode(base64Value);
    final index = (json['index'] as num?)?.toInt();
    final transferId = json['transferId']?.toString() ?? state.transferId;
    final outputFile = await _writeFile(
      transferId: transferId,
      fileName: fileJson['fileName']?.toString() ?? 'fichier_$index',
      bytes: bytes,
    );

    final incoming = ReceivedDischargeFile.fromJson(
      fileJson,
      index: index,
      path: outputFile.path,
      received: true,
    );

    final existingIndex = state.files.indexWhere(
      (item) => item.id == incoming.id,
    );
    final files = [...state.files];
    if (existingIndex >= 0) {
      files[existingIndex] = incoming.copyWith(
        uploadStatus: files[existingIndex].uploadStatus,
        serverCode: files[existingIndex].serverCode,
        serverRef: files[existingIndex].serverRef,
      );
    } else {
      files.add(incoming);
    }

    emit(
      state.copyWith(
        transferId: transferId,
        totalFiles: state.totalFiles == 0 ? files.length : state.totalFiles,
        files: files,
        selectedFileId: incoming.id,
        successMessage: 'Fichier reçu : ${incoming.fileName}',
        clearError: true,
      ),
    );
  }

  void _handleComplete(Map<String, dynamic> json) {
    emit(
      state.copyWith(
        transferId: json['transferId']?.toString() ?? state.transferId,
        totalFiles: (json['totalFiles'] as num?)?.toInt() ?? state.totalFiles,
        sentFiles: (json['sentFiles'] as num?)?.toInt(),
        completedAt: json['completedAt']?.toString(),
        transferCompleted: true,
        successMessage: 'Transfert bluetooth terminé.',
        clearError: true,
      ),
    );
  }

  Future<File> _writeFile({
    required String? transferId,
    required String fileName,
    required List<int> bytes,
  }) async {
    final docs = await getApplicationDocumentsDirectory();
    final safeTransferId = _sanitizeName(transferId ?? 'unknown_transfer');
    final outputDir = Directory(
      '${docs.path}${Platform.pathSeparator}received_bluetooth_files${Platform.pathSeparator}$safeTransferId',
    );
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }
    final outputFile = File(
      '${outputDir.path}${Platform.pathSeparator}${_sanitizeName(fileName)}',
    );
    await outputFile.writeAsBytes(bytes, flush: true);
    return outputFile;
  }

  String _sanitizeName(String value) {
    final sanitized = value.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trim();
    return sanitized.isEmpty ? 'file' : sanitized;
  }

  Map<String, dynamic> _toStringMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    throw FormatException('Objet JSON attendu, reçu ${value.runtimeType}.');
  }

  DischargeFilesState _replaceFile(ReceivedDischargeFile updated) {
    final files = state.files
        .map((file) => file.id == updated.id ? updated : file)
        .toList();
    return state.copyWith(files: files);
  }

  @override
  Future<void> close() async {
    await _jsonSubscription?.cancel();
    return super.close();
  }
}

class DischargeFilesState {
  final String? transferId;
  final String? createdAt;
  final String? completedAt;
  final int totalFiles;
  final int? sentFiles;
  final bool transferCompleted;
  final List<ReceivedDischargeFile> files;
  final String? selectedFileId;
  final bool isUploadingAll;
  final String? errorMessage;
  final String? successMessage;

  const DischargeFilesState({
    this.transferId,
    this.createdAt,
    this.completedAt,
    this.totalFiles = 0,
    this.sentFiles,
    this.transferCompleted = false,
    this.files = const [],
    this.selectedFileId,
    this.isUploadingAll = false,
    this.errorMessage,
    this.successMessage,
  });

  int get receivedCount => files.where((file) => file.received).length;
  int get uploadedCount => files
      .where((file) => file.uploadStatus == DischargeFileUploadStatus.uploaded)
      .length;
  int get errorCount => files
      .where((file) => file.uploadStatus == DischargeFileUploadStatus.error)
      .length;
  int get totalBytes => files.fold(0, (total, file) => total + file.sizeBytes);

  ReceivedDischargeFile? get selectedFile {
    if (selectedFileId == null) return files.firstOrNull;
    return files.where((file) => file.id == selectedFileId).firstOrNull ??
        files.firstOrNull;
  }

  bool get canUploadAll =>
      !isUploadingAll &&
      files.any(
        (file) =>
            file.received &&
            file.uploadStatus != DischargeFileUploadStatus.uploaded,
      );

  String get totalSizeLabel {
    if (totalBytes < 1024) return '$totalBytes B';
    if (totalBytes < 1024 * 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  DischargeFilesState copyWith({
    String? transferId,
    String? createdAt,
    String? completedAt,
    int? totalFiles,
    int? sentFiles,
    bool? transferCompleted,
    List<ReceivedDischargeFile>? files,
    String? selectedFileId,
    bool? isUploadingAll,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return DischargeFilesState(
      transferId: transferId ?? this.transferId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      totalFiles: totalFiles ?? this.totalFiles,
      sentFiles: sentFiles ?? this.sentFiles,
      transferCompleted: transferCompleted ?? this.transferCompleted,
      files: files ?? this.files,
      selectedFileId: selectedFileId ?? this.selectedFileId,
      isUploadingAll: isUploadingAll ?? this.isUploadingAll,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}
