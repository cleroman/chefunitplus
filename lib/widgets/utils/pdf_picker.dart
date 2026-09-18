// =============================================================
// ChefUnitPlus - PdfPicker Hybride (Web natif + Mobile file_picker)
// =============================================================
// Sur Web  : utilise <input type="file"> HTML natif (fiable a 100%)
// Sur mobile : utilise file_picker (fiable)
// =============================================================
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

// Import conditionnel : Web vs natif
import 'pdf_picker_stub.dart'
    if (dart.library.html) 'pdf_picker_web.dart' as platform;
import 'pdf_picker_mobile.dart' as mobile;

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
  static Future<PickedPdf?> pick() async {
    try {
      if (kIsWeb) {
        debugPrint('[PDF Picker] Mode Web natif');
        return await platform.pickPdf();
      } else {
        debugPrint('[PDF Picker] Mode mobile file_picker');
        return await mobile.pickPdf();
      }
    } catch (e, st) {
      debugPrint('[PDF Picker] Erreur : $e');
      debugPrint('[PDF Picker] Stack : $st');
      return null;
    }
  }
}