// =============================================================
// ChefUnitPlus - AttachLessonScreen
// Le formateur attache une lecon PDF a un module
// =============================================================

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AttachLessonScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const AttachLessonScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  State<AttachLessonScreen> createState() => _AttachLessonScreenState();
}

class _AttachLessonScreenState extends State<AttachLessonScreen> {
  PlatformFile? _selectedFile;
  bool _uploading = false;
  String? _error;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
          _error = null;
        });
      }
    } catch (e) {
      setState(() => _error = 'Erreur selection : $e');
    }
  }

  Future<void> _upload() async {
    if (_selectedFile == null) {
      setState(() => _error = 'Selectionnez un fichier PDF');
      return;
    }

    setState(() {
      _uploading = true;
      _error = null;
    });

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      //TODO: Implementer l'upload via ApiClient.uploadFile
      // Pour l'instant, on simule un succes
      final res = <String, dynamic>{
        'success': true,
        'message': 'Lecon attachee (simule)'
      };

      if (!mounted) return;

      if (res['success'] == true) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Lecon attachee avec succes'),
            backgroundColor: AppColors.success,
          ),
        );
        navigator.pop(true);
      } else {
        setState(() => _error = res['message'] as String? ?? 'Erreur upload');
      }
    } catch (e) {
      setState(() => _error = 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attacher une lecon'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          const Text(
            '1. Selectionnez votre lecon PDF',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 12),
          if (_selectedFile == null)
            _buildPickButton()
          else
            _buildSelectedFile(),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.danger),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.danger),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          if (_selectedFile != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _uploading ? null : _upload,
                icon: _uploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(
                  _uploading ? 'Envoi en cours...' : 'Envoyer la lecon',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          const SizedBox(height: 12),
          const Text(
            'Une fois la lecon envoyee, le directeur sera notifie.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mauve.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.menu_book, color: AppColors.mauve),
              SizedBox(width: 8),
              Text(
                'Module a completer',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.mauve,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.moduleTitle,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPickButton() {
    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.mauve.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: const Column(
          children: [
            Icon(Icons.upload_file, size: 64, color: AppColors.mauve),
            SizedBox(height: 16),
            Text(
              'Cliquez pour selectionner un PDF',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4),
            Text(
              'Formats acceptes : PDF uniquement',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: AppColors.success, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedFile!.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${(_selectedFile!.size / 1024).toStringAsFixed(1)} KB',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.danger),
            onPressed: () => setState(() => _selectedFile = null),
          ),
        ],
      ),
    );
  }
}
