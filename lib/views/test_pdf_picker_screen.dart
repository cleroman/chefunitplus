// =============================================================
// ChefUnitPlus - TEST PDF PICKER
// Ecran de test pour diagnostiquer file_picker sur Chrome
// =============================================================
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../core/constants/app_colors.dart';

class TestPdfPickerScreen extends StatefulWidget {
  const TestPdfPickerScreen({super.key});

  @override
  State<TestPdfPickerScreen> createState() => _TestPdfPickerScreenState();
}

class _TestPdfPickerScreenState extends State<TestPdfPickerScreen> {
  String _status = 'Pret a tester';
  String? _fileName;
  int? _fileSize;
  Uint8List? _fileBytes;
  String? _error;

  Future<void> _testPick() async {
    setState(() {
      _status = 'Ouverture de la fenetre...';
      _fileName = null;
      _fileSize = null;
      _fileBytes = null;
      _error = null;
    });

    try {
      debugPrint('[TEST] Appel de FilePicker.platform.pickFiles()');

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      debugPrint('[TEST] Resultat: $result');

      if (result == null) {
        setState(() {
          _status = 'Annule par l\'utilisateur';
        });
        return;
      }

      if (result.files.isEmpty) {
        setState(() {
          _status = 'Aucun fichier';
        });
        return;
      }

      final file = result.files.first;
      setState(() {
        _fileName = file.name;
        _fileSize = file.size;
        _fileBytes = file.bytes;
        _status = 'SUCCES';
      });

      debugPrint('[TEST] Fichier: ${file.name} (${file.size} octets)');
      debugPrint('[TEST] Bytes: ${file.bytes?.length ?? 0}');
    } catch (e, st) {
      debugPrint('[TEST] ERREUR: $e');
      debugPrint('[TEST] Stack: $st');
      setState(() {
        _status = 'ERREUR';
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Test PDF Picker'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Statut : $_status',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (_fileName != null)
                  Text('Fichier : $_fileName',
                      style: const TextStyle(fontSize: 14)),
                if (_fileSize != null)
                  Text('Taille : $_fileSize octets',
                      style: const TextStyle(fontSize: 14)),
                if (_fileBytes != null)
                  Text('Bytes charges : ${_fileBytes!.length}',
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.success)),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  const Text('Erreur :',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.danger)),
                  Text(_error!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.danger)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _testPick,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Tester le PDF picker'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mauve,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'INSTRUCTIONS :\n\n'
              '1. Clique sur le bouton\n'
              '2. Une fenetre doit s\'ouvrir\n'
              '3. Choisis un PDF\n'
              '4. Verifie le statut\n\n'
              'Regarde aussi la console Chrome (F12 -> Console) pour les logs [TEST]',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}