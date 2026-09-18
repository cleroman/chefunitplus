// Implementation mobile : utilise file_picker
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'pdf_picker.dart';

Future<PickedPdf?> pickPdf() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    final data = file.bytes;
    if (data == null) return null;

    return PickedPdf(
      name: file.name,
      bytes: data,
      path: file.path,
    );
  } catch (e) {
    debugPrint('[PDF Picker mobile] Erreur : $e');
    return null;
  }
}