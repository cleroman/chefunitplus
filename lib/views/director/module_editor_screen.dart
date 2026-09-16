import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../controllers/module_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/module.dart';
import '../../models/role.dart';
import '../../widgets/utils/pdf_picker.dart';

class ModuleEditorScreen extends StatefulWidget {
  final String formationId;
  final Module? existingModule;

  const ModuleEditorScreen({
    super.key,
    required this.formationId,
    this.existingModule,
  });

  @override
  State<ModuleEditorScreen> createState() => _ModuleEditorScreenState();
}

class _ModuleEditorScreenState extends State<ModuleEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController(text: '8');
  final _orderCtrl = TextEditingController(text: '1');

  String? _trainerId;
  DateTime? _startDate;
  DateTime? _endDate;
  Uint8List? _pdfBytes;
  String? _pdfFileName;

  bool _saving = false;

  bool get _isEditing => widget.existingModule != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserController>().loadAll(refresh: true);
    });

    if (_isEditing) {
      final m = widget.existingModule!;
      _titleCtrl.text = m.title;
      _descCtrl.text = m.description ?? '';
      _hoursCtrl.text = m.hours.toString();
      _orderCtrl.text = m.order.toString();
      _trainerId = m.trainerId;
      _startDate = m.startDate;
      _endDate = m.endDate;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _hoursCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? (_startDate ?? DateTime.now()).add(const Duration(days: 1)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickPdf() async {
    final picked = await PdfPicker.pick();
    if (picked == null) return;
    if (!mounted) return;
    setState(() {
      _pdfBytes = picked.bytes;
      _pdfFileName = picked.name;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final ctrl = context.read<ModuleController>();
    final hours = int.tryParse(_hoursCtrl.text) ?? 0;
    final order = int.tryParse(_orderCtrl.text) ?? 0;

    bool ok;
    if (_isEditing) {
      ok = await ctrl.update(
        id: widget.existingModule!.id,
        formationId: widget.formationId,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        trainerId: _trainerId,
        order: order,
        hours: hours,
        startDate: _startDate,
        endDate: _endDate,
        pdfBytes: _pdfBytes, pdfFileName: _pdfFileName,
      );
    } else {
      ok = await ctrl.create(
        formationId: widget.formationId,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        trainerId: _trainerId,
        order: order,
        hours: hours,
        startDate: _startDate,
        endDate: _endDate,
        pdfBytes: _pdfBytes, pdfFileName: _pdfFileName,
      );
    }

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Module modifie' : 'Module cree'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ctrl.errorMessage ?? 'Erreur'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le module' : 'Nouveau module'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Titre du module',
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
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (optionnel)',
                prefixIcon: Icon(Icons.description_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _hoursCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Volume horaire (h)',
                      hintText: '8',
                      prefixIcon: Icon(Icons.schedule),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Requis';
                      final h = int.tryParse(v);
                      if (h == null || h <= 0) return 'Nombre > 0';
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
            const SizedBox(height: 24),

            _buildTrainerDropdown(),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _datePicker(
                  label: 'Date debut', date: _startDate, isStart: true)),
                const SizedBox(width: 12),
                Expanded(child: _datePicker(
                  label: 'Date fin', date: _endDate, isStart: false)),
              ],
            ),
            const SizedBox(height: 24),

            const Text('Support PDF du module (optionnel)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('PDF telechargeable par les apprenants valides',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            const SizedBox(height: 8),
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
                        _pdfFileName ?? 'Choisir un PDF',
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_pdfFileName != null)
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() {
                          _pdfBytes = null;
                          _pdfFileName = null;
                        }),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(_isEditing ? Icons.save : Icons.add),
                label: Text(_saving
                    ? 'Enregistrement...'
                    : (_isEditing ? 'Enregistrer' : 'Creer le module')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mauve,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _datePicker({
    required String label,
    required DateTime? date,
    required bool isStart,
  }) {
    return InkWell(
      onTap: () => _pickDate(isStart: isStart),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          border: const OutlineInputBorder(),
        ),
        child: Text(
          date != null ? _fmt(date) : 'Choisir',
          style: TextStyle(
            color: date != null
                ? AppColors.textPrimary
                : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildTrainerDropdown() {
    final userCtrl = context.watch<UserController>();
    final trainers = userCtrl.users
        .where((u) =>
            u.role == UserRole.formateur || u.role == UserRole.directeur)
        .toList();

    if (userCtrl.isLoading && trainers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return DropdownButtonFormField<String>(
      initialValue:
          trainers.any((t) => t.id == _trainerId) ? _trainerId : null,
      decoration: const InputDecoration(
        labelText: 'Formateur du module',
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(),
      ),
      items: trainers
          .map((u) => DropdownMenuItem<String>(
                value: u.id, child: Text(u.fullName)))
          .toList(),
      onChanged: (v) => setState(() => _trainerId = v),
      hint: Text(trainers.isEmpty
          ? 'Aucun formateur disponible'
          : 'Selectionner'),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}