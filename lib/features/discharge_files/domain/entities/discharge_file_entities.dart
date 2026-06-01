import 'dart:io';

enum DischargeFileUploadStatus { pending, uploading, uploaded, error }

class FileTransferMetadata {
  final String taskCode;
  final String lastModifiedDate;
  final String ref;
  final String label;
  final String entity;

  const FileTransferMetadata({
    required this.taskCode,
    required this.lastModifiedDate,
    required this.ref,
    required this.label,
    required this.entity,
  });

  factory FileTransferMetadata.fromJson(Map<String, dynamic>? json) {
    return FileTransferMetadata(
      taskCode: json?['taskCode']?.toString() ?? '',
      lastModifiedDate: json?['lastModifiedDate']?.toString() ?? '',
      ref: json?['ref']?.toString() ?? '',
      label: json?['label']?.toString() ?? '',
      entity: json?['entity']?.toString() ?? '',
    );
  }
}

class ReceivedDischargeFile {
  final String id;
  final int? localId;
  final int? index;
  final String fileName;
  final String extension;
  final String mimeType;
  final int sizeBytes;
  final FileTransferMetadata metadata;
  final String? path;
  final bool received;
  final DischargeFileUploadStatus uploadStatus;
  final String? serverCode;
  final String? serverRef;
  final String? errorMessage;

  const ReceivedDischargeFile({
    required this.id,
    required this.fileName,
    required this.extension,
    required this.mimeType,
    required this.sizeBytes,
    required this.metadata,
    this.localId,
    this.index,
    this.path,
    this.received = false,
    this.uploadStatus = DischargeFileUploadStatus.pending,
    this.serverCode,
    this.serverRef,
    this.errorMessage,
  });

  factory ReceivedDischargeFile.fromJson(
    Map<String, dynamic> json, {
    int? index,
    String? path,
    bool received = false,
  }) {
    final localId = (json['localId'] as num?)?.toInt();
    final fileName = json['fileName']?.toString() ?? 'fichier_$index';
    return ReceivedDischargeFile(
      id: _buildFileId(localId: localId, fileName: fileName, index: index),
      localId: localId,
      index: index,
      fileName: fileName,
      extension: json['extension']?.toString() ?? '',
      mimeType: json['mimeType']?.toString() ?? '',
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      metadata: FileTransferMetadata.fromJson(
        json['metadata'] is Map
            ? Map<String, dynamic>.from(json['metadata'])
            : null,
      ),
      path: path,
      received: received,
    );
  }

  bool get isImage =>
      mimeType.startsWith('image/') ||
      _imageExtensions.contains(extension.toLowerCase());

  bool get isVideo =>
      mimeType.startsWith('video/') ||
      _videoExtensions.contains(extension.toLowerCase());

  File? get file => path == null ? null : File(path!);

  String get sizeLabel {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  ReceivedDischargeFile copyWith({
    int? index,
    String? path,
    bool? received,
    DischargeFileUploadStatus? uploadStatus,
    String? serverCode,
    String? serverRef,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ReceivedDischargeFile(
      id: id,
      localId: localId,
      index: index ?? this.index,
      fileName: fileName,
      extension: extension,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      metadata: metadata,
      path: path ?? this.path,
      received: received ?? this.received,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      serverCode: serverCode ?? this.serverCode,
      serverRef: serverRef ?? this.serverRef,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class FileUploadResponse {
  final String code;
  final String ref;

  const FileUploadResponse({required this.code, required this.ref});

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) {
    return FileUploadResponse(
      code: json['code']?.toString() ?? '',
      ref: json['ref']?.toString() ?? '',
    );
  }
}

String _buildFileId({int? localId, required String fileName, int? index}) {
  if (localId != null) return 'local-$localId';
  if (index != null) return 'index-$index-$fileName';
  return 'file-$fileName';
}

const _imageExtensions = {'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'};
const _videoExtensions = {'mp4', 'mov', 'avi', 'mkv', 'webm', 'wmv'};
