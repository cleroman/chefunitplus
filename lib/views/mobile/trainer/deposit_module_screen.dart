// =============================================================
// ChefUnitPlus - DepositModuleScreen
// Le formateur depose un module (PDF + infos)
// =============================================================

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../services/deposit_module_service.dart';

class DepositModuleScreen extends StatefulWidget {
  const DepositModuleScreen({super.key});

  @override
  State<DepositModuleScreen> createState() => _DepositModuleScreenState();
}

class _DepositModuleScreenState extends State<DepositModuleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  PlatformFile? _pdfFile;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DepositModuleService>().loadMyDeposits();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _hoursCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() => _pdfFile = result.files.first);
      }
    } catch (e) {
      setState(() => _error = 'Erreur selection : $e');
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    final svc = context.read<DepositModuleService>();
    final messenger = ScaffoldMessenger.of(context);

    final result = await svc.deposit(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      hours: int.tryParse(_hoursCtrl.text.trim()),
      startDate: _startDate,
      endDate: _endDate,
      pdfFile: _pdfFile,
    );

    if (!mounted) return;

    setState(() => _saving = false);

    if (result != null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Module depose avec succes'),
          backgroundColor: AppColors.success,
        ),
      );
      _resetForm();
    } else {
      setState(() => _error = svc.error ?? 'Erreur lors du depot');
    }
  }

  void _resetForm() {
    _titleCtrl.clear();
    _descCtrl.clear();
    _hoursCtrl.clear();
    setState(() {
      _startDate = null;
      _endDate = null;
      _pdfFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Deposer un module'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 20),

          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Informations du module',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Titre *',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Titre requis' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _hoursCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Volume horaire (heures)',
                    prefixIcon: Icon(Icons.schedule),
                    border: OutlineInputBorder(),
                    suffixText: 'h',
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildDateField('Date debut', _startDate, () => _pickDate(true)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateField('Date fin', _endDate, () => _pickDate(false)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                const Text('Document PDF',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 12),
                _buildPdfPicker(),
                const SizedBox(height: 20),

                if (_error != null) ...[
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
                          child: Text(_error!,
                              style: const TextStyle(color: AppColors.danger)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _submit,
                    icon: _saving
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: Text(_saving ? 'Envoi...' : 'Deposer le module'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          _buildMyDepositsSection(),
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
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.mauve),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Deposez vos modules ici. Le directeur les attachera aux formations.',
              style: TextStyle(fontSize: 13, color: AppColors.mauve),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          border: const OutlineInputBorder(),
        ),
        child: Text(
          date != null ? '${date.day}/${date.month}/${date.year}' : 'Selectionner',
          style: TextStyle(
            color: date != null ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildPdfPicker() {
    if (_pdfFile == null) {
      return InkWell(
        onTap: _pickPdf,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.mauve.withValues(alpha: 0.3), width: 2),
          ),
          child: const Column(
            children: [
              Icon(Icons.upload_file, size: 48, color: AppColors.mauve),
              SizedBox(height: 8),
              Text('Cliquez pour selectionner un PDF',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 4),
              Text('PDF uniquement', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: AppColors.success, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_pdfFile!.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                Text('${(_pdfFile!.size / 1024).toStringAsFixed(1)} KB',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.danger),
            onPressed: () => setState(() => _pdfFile = null),
          ),
        ],
      ),
    );
  }

  Widget _buildMyDepositsSection() {
    return Consumer<DepositModuleService>(
      builder: (context, svc, _) {
        if (svc.myDeposits.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mes depots',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 12),
            ...svc.myDeposits.map((d) => _buildDepositCard(d)),
          ],
        );
      },
    );
  }

  Widget _buildDepositCard(Map<String, dynamic> d) {
    final status = d['status'] as String? ?? 'available';
    final isAttached = status == 'attached';
    final color = isAttached ? AppColors.success : AppColors.warning;
    final label = isAttached ? 'Attache' : 'Disponible';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(d['title'] as String? ?? 'Module',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(label,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
              ),
            ],
          ),
          if (isAttached && d['attached_formation_title'] != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.school_outlined, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(d['attached_formation_title'] as String,
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
          if (!isAttached) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  // Capturer le service AVANT le await
                  final svc = context.read<DepositModuleService>();
                  
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Supprimer'),
                      content: const Text('Voulez-vous supprimer ce depot ?'),
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
                  if (confirmed == true && mounted) {
                    await svc.deleteDeposit(d['id'] as String);
                  }
                },
                icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                label: const Text('Supprimer',
                    style: TextStyle(color: AppColors.danger, fontSize: 12)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}