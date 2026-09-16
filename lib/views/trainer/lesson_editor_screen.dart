import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../controllers/lesson_controller.dart';
import '../../models/lesson.dart';

class LessonEditorScreen extends StatefulWidget {
  final String moduleId;
  final Lesson? existingLesson;

  const LessonEditorScreen({
    super.key,
    required this.moduleId,
    this.existingLesson,
  });

  @override
  State<LessonEditorScreen> createState() => _LessonEditorScreenState();
}

class _LessonEditorScreenState extends State<LessonEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _videoCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '15');
  final _orderCtrl = TextEditingController(text: '1');

  String? _pdfFilePath;
  String? _pdfFileName;
  List<QuizQuestion> _quiz = [];
  bool _saving = false;

  bool get _isEditing => widget.existingLesson != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final l = widget.existingLesson!;
      _titleCtrl.text = l.title;
      _descCtrl.text = l.description ?? '';
      _contentCtrl.text = l.content ?? '';
      _videoCtrl.text = l.videoUrl ?? '';
      _durationCtrl.text = l.duration.toString();
      _orderCtrl.text = l.order.toString();
      _quiz = List.from(l.quiz);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _contentCtrl.dispose();
    _videoCtrl.dispose();
    _durationCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.path == null) return;
      setState(() {
        _pdfFilePath = file.path;
        _pdfFileName = file.name;
      });
    } catch (e) {
      if (!mounted) return;
      _showSnack('Erreur : $e', isError: true);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final ctrl = context.read<LessonController>();
    final duration = int.tryParse(_durationCtrl.text) ?? 0;
    final order = int.tryParse(_orderCtrl.text) ?? 0;

    bool ok;
    if (_isEditing) {
      ok = await ctrl.update(
        id: widget.existingLesson!.id,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        videoUrl: _videoCtrl.text.trim(),
        duration: duration,
        order: order,
        quiz: _quiz,
        pdfFilePath: _pdfFilePath,
      );
    } else {
      ok = await ctrl.create(
        moduleId: widget.moduleId,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        videoUrl: _videoCtrl.text.trim(),
        duration: duration,
        order: order,
        quiz: _quiz,
        pdfFilePath: _pdfFilePath,
      );
    }

    if (!mounted) return;
    setState(() => _saving = false);

    if (!mounted) return;
    if (ok) {
      _showSnack(_isEditing ? 'Lecon modifiee' : 'Lecon creee');
      Navigator.pop(context, true);
    } else {
      _showSnack(ctrl.errorMessage ?? 'Erreur', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier la lecon' : 'Nouvelle lecon'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Supprimer',
              onPressed: () => _confirmDelete(),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ============================================================
            // SECTION : Informations de base
            // ============================================================
            _section('Informations'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Titre de la lecon',
                hintText: 'Ex : Introduction au leadership',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Requis';
                if (v.trim().length < 3) return 'Au moins 3 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description courte (optionnel)',
                prefixIcon: Icon(Icons.description_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _durationCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duree (minutes)',
                      hintText: '15',
                      prefixIcon: Icon(Icons.schedule),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Requis';
                      final n = int.tryParse(v);
                      if (n == null || n <= 0) return 'Doit etre > 0';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _orderCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Ordre',
                      hintText: '1',
                      prefixIcon: Icon(Icons.format_list_numbered),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            // ============================================================
            // SECTION : Contenu
            // ============================================================
            const SizedBox(height: 24),
            _section('Contenu'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contentCtrl,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Contenu de la lecon',
                hintText: 'Ecrivez le contenu pedagogique...',
                prefixIcon: Icon(Icons.article_outlined),
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _videoCtrl,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'URL video (YouTube ou lien)',
                hintText: 'https://youtube.com/watch?v=...',
                prefixIcon: Icon(Icons.videocam_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            // ============================================================
            // SECTION : Support PDF
            // ============================================================
            const SizedBox(height: 24),
            _section('Support PDF'),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickPdf,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _pdfFileName != null
                      ? AppColors.success.withValues(alpha: 0.08)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _pdfFileName != null
                        ? AppColors.success
                        : AppColors.divider,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _pdfFileName != null
                          ? Icons.check_circle
                          : Icons.picture_as_pdf,
                      color: _pdfFileName != null
                          ? AppColors.success
                          : AppColors.mauve,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _pdfFileName ?? 'Choisir un PDF (optionnel)',
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_pdfFileName != null)
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() {
                          _pdfFilePath = null;
                          _pdfFileName = null;
                        }),
                      ),
                  ],
                ),
              ),
            ),

            // ============================================================
            // SECTION : Quiz
            // ============================================================
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _section('Quiz (${_quiz.length})')),
                TextButton.icon(
                  onPressed: _addQuizQuestion,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.mauve),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_quiz.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Aucune question',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ),
              )
            else
              ..._quiz.asMap().entries.map((entry) {
                final idx = entry.key;
                final q = entry.value;
                return _buildQuizCard(idx, q);
              }),

            // ============================================================
            // BOUTON SAUVEGARDER
            // ============================================================
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(_isEditing ? Icons.save : Icons.add),
                label: Text(
                  _saving
                      ? 'Enregistrement...'
                      : (_isEditing ? 'Enregistrer' : 'Creer la lecon'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mauve,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // QUIZ
  // ============================================================
  Future<void> _addQuizQuestion() async {
    final questionCtrl = TextEditingController();
    final options = [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ];
    int correctIndex = 0;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Nouvelle question'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: questionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Question',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Reponses (cochez la bonne) :',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                ...List.generate(4, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => setStateDialog(() => correctIndex = i),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              correctIndex == i
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: correctIndex == i
                                  ? AppColors.success
                                  : AppColors.textMuted,
                              size: 22,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: options[i],
                            decoration: InputDecoration(
                              hintText: 'Reponse ${i + 1}',
                              isDense: true,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.mauve),
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );

    if (result != true) return;
    if (questionCtrl.text.trim().isEmpty) return;

    final validOptions = options
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (validOptions.length < 2) return;

    setState(() {
      _quiz.add(QuizQuestion(
        question: questionCtrl.text.trim(),
        options: validOptions,
        correctIndex: correctIndex < validOptions.length ? correctIndex : 0,
      ));
    });
  }

  Widget _buildQuizCard(int index, QuizQuestion q) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.mauve.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Q${index + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mauve,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  q.question,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                onPressed: () => setState(() => _quiz.removeAt(index)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...q.options.asMap().entries.map((entry) {
            final isCorrect = entry.key == q.correctIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 12),
              child: Row(
                children: [
                  Icon(
                    isCorrect
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 14,
                    color: isCorrect
                        ? AppColors.success
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 12,
                        color: isCorrect
                            ? AppColors.success
                            : AppColors.textPrimary,
                        fontWeight:
                            isCorrect ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================
  // SUPPRESSION
  // ============================================================
  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la lecon'),
        content: const Text(
          'Voulez-vous vraiment supprimer cette lecon ?\n\n'
          'Cette action est irreversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;
    final ctrl = context.read<LessonController>();
    final ok = await ctrl.delete(widget.existingLesson!.id);

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      _showSnack(ctrl.errorMessage ?? 'Erreur', isError: true);
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================
  Widget _section(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.mauve,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
      ),
    );
  }
}