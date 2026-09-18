// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
// Implementation Web : utilise <input type="file"> HTML natif
// Compatible avec Flutter Web (dart:html)
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'pdf_picker.dart';

Future<PickedPdf?> pickPdf() async {
  final completer = Completer<PickedPdf?>();

  // Creer un input file
  final input = html.FileUploadInputElement()
    ..accept = 'application/pdf,.pdf'
    ..style.display = 'none';

  // Ajouter au DOM
  html.document.body?.append(input);

  // Ecouter le changement
  input.onChange.listen((event) {
    if (input.files == null || input.files!.isEmpty) {
      if (!completer.isCompleted) completer.complete(null);
      input.remove();
      return;
    }

    final file = input.files!.first;
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);

    reader.onLoadEnd.listen((_) {
      final result = reader.result;
      if (result is List<int>) {
        if (!completer.isCompleted) {
          completer.complete(PickedPdf(
            name: file.name,
            bytes: Uint8List.fromList(result),
          ));
        }
      } else if (result is ByteBuffer) {
        if (!completer.isCompleted) {
          completer.complete(PickedPdf(
            name: file.name,
            bytes: Uint8List.view(result),
          ));
        }
      } else {
        if (!completer.isCompleted) completer.complete(null);
      }
      input.remove();
    });

    reader.onError.listen((_) {
      if (!completer.isCompleted) completer.complete(null);
      input.remove();
    });
  });

  // Declencher le clic sur l'input
  input.click();

  return completer.future;
}