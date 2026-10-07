// =====================================================================
//  ProofDocument - Modele pour les preuves de formation (PDF)
// =====================================================================
import 'dart:typed_data';

class ProofDocument {
  final String title;
  final String? filePath;
  final String? fileName;
  final int? fileSize;
  final Uint8List? bytes;

  const ProofDocument({
    required this.title,
    this.filePath,
    this.fileName,
    this.fileSize,
    this.bytes,
  });

  bool get isComplete =>
      title.trim().isNotEmpty &&
      (filePath != null || (bytes != null && bytes!.isNotEmpty));

  bool get isEmpty =>
      title.trim().isEmpty &&
      filePath == null &&
      (bytes == null || bytes!.isEmpty);

  ProofDocument copyWith({
    String? title,
    String? filePath,
    String? fileName,
    int? fileSize,
    Uint8List? bytes,
    bool clearFile = false,
  }) {
    return ProofDocument(
      title: title ?? this.title,
      filePath: clearFile ? null : (filePath ?? this.filePath),
      fileName: clearFile ? null : (fileName ?? this.fileName),
      fileSize: clearFile ? null : (fileSize ?? this.fileSize),
      bytes: clearFile ? null : (bytes ?? this.bytes),
    );
  }

  String get formattedSize {
    if (fileSize == null) return '';
    if (fileSize! < 1024) return '$fileSize o';
    if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(0)} Ko';
    }
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} Mo';
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'fileName': fileName,
        'fileSize': fileSize,
      };

  @override
  String toString() => 'ProofDocument(title: $title, file: $fileName)';
}