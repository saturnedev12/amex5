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
    if (sizeBytes < 1024 * 1024)
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
