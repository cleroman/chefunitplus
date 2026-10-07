// =====================================================================
//  PdfProofList - Liste editable de preuves de formation (PDF)
// =====================================================================
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/proof_document.dart';

class PdfProofList extends StatefulWidget {
  final ValueChanged<List<ProofDocument>> onChanged;
  final List<ProofDocument> initialValue;
  final int maxDocuments;
  final int maxSizeMb;

  const PdfProofList({
    super.key,
    required this.onChanged,
    this.initialValue = const [],
    this.maxDocuments = 5,
    this.maxSizeMb = 5,
  });

  @override
  State<PdfProofList> createState() => PdfProofListState();
}

class PdfProofListState extends State<PdfProofList> {
  late List<ProofDocument> _documents;
  final List<TextEditingController> _titleControllers = [];
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    _documents = List.from(widget.initialValue);
    for (var doc in _documents) {
      _titleControllers.add(TextEditingController(text: doc.title));
    }
  }

  @override
  void dispose() {
    for (var ctrl in _titleControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _notify() {
    widget.onChanged(List.from(_documents));
  }

  void _addDocument() {
    if (_documents.length >= widget.maxDocuments) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum ${widget.maxDocuments} documents autorises'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() {
      _documents.add(const ProofDocument(title: ''));
      _titleControllers.add(TextEditingController());
    });
    _notify();
  }

  void _removeDocument(int index) {
    setState(() {
      _documents.removeAt(index);
      _titleControllers[index].dispose();
      _titleControllers.removeAt(index);
    });
    _notify();
  }

  void _updateTitle(int index, String value) {
    _documents[index] = _documents[index].copyWith(title: value);
    _notify();
  }

  Future<void> _pickFile(int index) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final picked = result.files.first;
      final sizeBytes = picked.size;
      final sizeMb = sizeBytes / (1024 * 1024);

      if (sizeMb > widget.maxSizeMb) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Fichier trop gros : ${sizeMb.toStringAsFixed(1)} Mo '
                '(max ${widget.maxSizeMb} Mo)',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final name = picked.name.toLowerCase();
      if (!name.endsWith('.pdf')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Seuls les fichiers PDF sont acceptes'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        _documents[index] = _documents[index].copyWith(
          filePath: picked.path,
          fileName: picked.name,
          fileSize: picked.size,
          bytes: picked.bytes,
        );
      });
      _notify();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearFile(int index) {
    setState(() {
      _documents[index] = _documents[index].copyWith(clearFile: true);
    });
    _notify();
  }

  List<int> validate() {
    final incomplete = <int>[];
    for (var i = 0; i < _documents.length; i++) {
      if (!_documents[i].isComplete) {
        incomplete.add(i);
      }
    }
    if (incomplete.isNotEmpty) {
      setState(() => _showErrors = true);
    }
    return incomplete;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_file_rounded,
                  size: 22, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Preuves de formation',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Ajoutez vos diplomes, attestations ou certificats (PDF)',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          if (_documents.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.grey.shade400, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Aucun document. Cette section est optionnelle.',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            )
          else
            ...List.generate(_documents.length, (i) {
              return Padding(
                padding: EdgeInsets.only(
                    bottom: i < _documents.length - 1 ? 12 : 0),
                child: _buildCard(i),
              );
            }),

          const SizedBox(height: 12),

          if (_documents.length < widget.maxDocuments)
            OutlinedButton.icon(
              onPressed: _addDocument,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(
                _documents.isEmpty
                    ? 'Ajouter un document'
                    : 'Ajouter un autre document',
              ),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

          const SizedBox(height: 8),
          Text(
            'Formats acceptes : PDF uniquement. '
            'Taille max : ${widget.maxSizeMb} Mo par fichier. '
            'Maximum ${widget.maxDocuments} documents.',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    final doc = _documents[index];
    final titleEmpty = doc.title.trim().isEmpty;
    final fileMissing =
        doc.filePath == null && (doc.bytes == null || doc.bytes!.isEmpty);
    final showError = _showErrors && (titleEmpty || fileMissing);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: showError ? Colors.red.shade300 : Colors.grey.shade300,
          width: showError ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Document ${index + 1}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => _removeDocument(index),
                tooltip: 'Supprimer',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: Colors.grey.shade600,
              ),
            ],
          ),
          const SizedBox(height: 8),

          TextFormField(
            controller: _titleControllers[index],
            decoration: InputDecoration(
              labelText: 'Titre du document *',
              hintText: 'Ex : Diplome BTS 2024',
              prefixIcon: const Icon(Icons.title_rounded, size: 20),
              border: const OutlineInputBorder(),
              isDense: true,
              errorText:
                  (_showErrors && titleEmpty) ? 'Titre obligatoire' : null,
            ),
            onChanged: (v) => _updateTitle(index, v),
          ),
          const SizedBox(height: 12),

          if (doc.fileName == null)
            OutlinedButton.icon(
              onPressed: () => _pickFile(index),
              icon: const Icon(Icons.upload_file_rounded, size: 20),
              label: const Text('Choisir un PDF'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          else
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf_rounded,
                      color: Colors.red, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.fileName!,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (doc.fileSize != null)
                          Text(
                            doc.formattedSize,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade600),
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _pickFile(index),
                    child:
                        const Text('Changer', style: TextStyle(fontSize: 12)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () => _clearFile(index),
                    tooltip: 'Retirer le fichier',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),

          if (_showErrors && fileMissing)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                'Fichier PDF obligatoire',
                style: TextStyle(fontSize: 12, color: Colors.red.shade700),
              ),
            ),
        ],
      ),
    );
  }
}