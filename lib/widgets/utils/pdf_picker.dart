import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

/// Resultat d'un pick de fichier PDF, compatible Web ET natif.
class PickedPdf {
  final String name;
  final Uint8List bytes;
  final String? path;
  PickedPdf({required this.name, required this.bytes, this.path});
}

/// Utilitaire pour choisir un PDF de maniere compatible multi-plateforme.
class PdfPicker {
  PdfPicker._();

  /// Ouvre le file picker et retourne le fichier ou null si annule.
  /// On lit TOUJOURS les bytes (withData: true) : ca marche sur Web + natif.
  static Future<PickedPdf?> pick() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true, // OBLIGATOIRE : charge les bytes partout
      );
      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;
      final data = file.bytes;
      if (data == null) return null;

      return PickedPdf(name: file.name, bytes: data, path: file.path);
    } catch (_) {
      return null;
    }
  }
}