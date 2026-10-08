// =============================================================
// ChefUnitPlus - Ecran de soumission des preuves de formation
// Permet d uploader 1 a 5 PDFs (max 5 Mo chacun)
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/pdf_proof_list.dart';
import '../mobile/auth/pending_validation_screen.dart';

class SubmitProofsScreen extends StatefulWidget {
  final String email;

  const SubmitProofsScreen({
    super.key,
    required this.email,
  });

  @override
  State<SubmitProofsScreen> createState() => _SubmitProofsScreenState();
}

// Mapping titre -> nombre de buchettes
const Map<String, int> kBuchettesParTitre = {
  'Formateur': 4,
  'Formateur Adjoint': 3,
  'Woodbadge': 2,
  'Training': 1,
  'Camp Ecole': 0,
};

class _SubmitProofsScreenState extends State<SubmitProofsScreen> {
  String? _selectedTitle;
  final List<Map<String, dynamic>> _proofs = [];
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_proofs.isEmpty) {
      setState(() {
        _error = 'Ajoutez au moins 1 preuve (PDF)';
      });
      return;
    }

    if (_selectedTitle == null) {
      setState(() {
        _error = 'Choisissez le titre de votre preuve';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final authService = AuthService(
        api: context.read<ApiClient>(),
        storage: context.read<StorageService>(),
      );

      final buchettes = kBuchettesParTitre[_selectedTitle] ?? 0;
      final result = await authService.submitProofs(
        proofs: _proofs,
        buchettes: buchettes,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PendingValidationScreen(email: widget.email),
          ),
        );
      } else {
        setState(() {
          _error = result['message'] ?? 'Erreur lors de la soumission';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erreur : ' + e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Preuves de formation'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.upload_file,
                size: 64,
                color: AppColors.mauve,
              ),
              const SizedBox(height: 16),
              const Text(
                'Soumettez vos preuves',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.kakiSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.kaki, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ajoutez 1 a 5 fichiers PDF (max 5 Mo chacun). '
                        'Ces preuves seront verifiees par un administrateur.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Selecteur de titre
              DropdownButtonFormField<String>(
                value: _selectedTitle,
                decoration: const InputDecoration(
                  labelText: 'Titre de la preuve',
                  prefixIcon: Icon(Icons.local_fire_department),
                ),
                items: kBuchettesParTitre.keys.map((titre) {
                  final nb = kBuchettesParTitre[titre] ?? 0;
                  return DropdownMenuItem<String>(
                    value: titre,
                    child: Text(
                      nb > 0 ? '$titre ($nb buchettes)' : '$titre (0 buchette)',
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedTitle = val;
                    _error = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              PdfProofList(
                onChanged: (list) {
                  _proofs.clear();
                  for (final doc in list) {
                    _proofs.add({
                      'title': doc.title,
                      'filePath': doc.filePath,
                      'fileName': doc.fileName,
                      'fileSize': doc.fileSize,
                      'bytes': doc.bytes,
                    });
                  }
                },
                maxDocuments: 5,
                maxSizeMb: 5,
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.dangerSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.danger, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mauve,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Soumettre mes preuves',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


