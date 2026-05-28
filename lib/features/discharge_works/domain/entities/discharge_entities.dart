import 'package:amex5/features/agent_works/data/models/check_items_work.dart';
import 'package:amex5/features/agent_works/data/models/wo_model.dart';

enum DischargeUploadStatus { pending, sending, sent, error }

class DischargePayload {
  final Map<String, dynamic> rawJson;
  final List<DischargeWorkLine> works;
  final List<DischargeCheckItemLine> checkItemsWorks;
  final int sizeBytes;
  final DateTime receivedAt;

  const DischargePayload({
    required this.rawJson,
    required this.works,
    required this.checkItemsWorks,
    required this.sizeBytes,
    required this.receivedAt,
  });

  int get totalChecklistItems => works.fold(
    0,
    (total, line) => total + (line.work.checkListItems?.length ?? 0),
  );

  int get totalItems => works.length + checkItemsWorks.length;

  String get sizeLabel {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  int get sentCount =>
      works.where((line) => line.status == DischargeUploadStatus.sent).length +
      checkItemsWorks
          .where((line) => line.status == DischargeUploadStatus.sent)
          .length;

  int get errorCount =>
      works.where((line) => line.status == DischargeUploadStatus.error).length +
      checkItemsWorks
          .where((line) => line.status == DischargeUploadStatus.error)
          .length;

  bool get allSent => totalItems > 0 && sentCount == totalItems;

  DischargePayload copyWith({
    Map<String, dynamic>? rawJson,
    List<DischargeWorkLine>? works,
    List<DischargeCheckItemLine>? checkItemsWorks,
    int? sizeBytes,
    DateTime? receivedAt,
  }) {
    return DischargePayload(
      rawJson: rawJson ?? this.rawJson,
      works: works ?? this.works,
      checkItemsWorks: checkItemsWorks ?? this.checkItemsWorks,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }
}

class DischargeWorkLine {
  final String id;
  final int index;
  final WoModel work;
  final DischargeUploadStatus status;
  final String? errorMessage;

  const DischargeWorkLine({
    required this.id,
    required this.index,
    required this.work,
    this.status = DischargeUploadStatus.pending,
    this.errorMessage,
  });

  String get title => work.woCode == null || work.woCode!.isEmpty
      ? 'WO #${index + 1}'
      : 'WO ${work.woCode}';

  DischargeWorkLine copyWith({
    WoModel? work,
    DischargeUploadStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DischargeWorkLine(
      id: id,
      index: index,
      work: work ?? this.work,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class DischargeCheckItemLine {
  final String id;
  final int index;
  final CheckItemsWork checkItem;
  final DischargeUploadStatus status;
  final String? errorMessage;

  const DischargeCheckItemLine({
    required this.id,
    required this.index,
    required this.checkItem,
    this.status = DischargeUploadStatus.pending,
    this.errorMessage,
  });

  String get title =>
      checkItem.checkItemCode == null || checkItem.checkItemCode!.isEmpty
      ? 'Check item #${index + 1}'
      : checkItem.checkItemCode!;

  DischargeCheckItemLine copyWith({
    CheckItemsWork? checkItem,
    DischargeUploadStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DischargeCheckItemLine(
      id: id,
      index: index,
      checkItem: checkItem ?? this.checkItem,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Résultat d'un upload de discharge works.
class DischargeUploadResult {
  final bool success;
  final String? message;
  final Map<String, dynamic>? responseData;
  final DateTime uploadedAt;

  const DischargeUploadResult({
    required this.success,
    required this.uploadedAt,
    this.message,
    this.responseData,
  });
}

/// Fichier JSON sélectionné prêt à être envoyé.
class DischargeFile {
  final String path;
  final String name;
  final Map<String, dynamic> content;
  final int sizeBytes;

  const DischargeFile({
    required this.path,
    required this.name,
    required this.content,
    required this.sizeBytes,
  });

  String get sizeLabel {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
