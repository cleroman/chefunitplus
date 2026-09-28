// =============================================================
// ChefUnitPlus - TrainerScanQrScreen
// Le formateur scanne le QR code de l'apprenant
// =============================================================

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../../services/permission_service.dart';

import '../../../core/constants/app_colors.dart';
import '../../../services/qr_service.dart';

class TrainerScanQrScreen extends StatefulWidget {
  const TrainerScanQrScreen({super.key});

  @override
  State<TrainerScanQrScreen> createState() => _TrainerScanQrScreenState();
}

class _TrainerScanQrScreenState extends State<TrainerScanQrScreen> {
  final _codeCtrl = TextEditingController();

  List<Map<String, dynamic>> _modules = [];
  String? _selectedModuleId;
  bool _loadingModules = true;
  bool _scanning = false;
  Map<String, dynamic>? _lastResult;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadModules());
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadModules() async {
    setState(() {
      _loadingModules = true;
      _error = null;
    });

    final qr = context.read<QrService>();
    final modules = await qr.getAvailableForScan();

    if (!mounted) return;

    setState(() {
      _modules = modules;
      _loadingModules = false;
      if (modules.isNotEmpty) {
        _selectedModuleId = modules.first['id'] as String?;
      }
    });
  }

  Future<void> _scan() async {
    if (_selectedModuleId == null) {
      setState(() => _error = 'Selectionnez un module');
      return;
    }

    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Entrez ou scannez un code QR');
      return;
    }

    setState(() {
      _scanning = true;
      _error = null;
      _lastResult = null;
    });

    final qr = context.read<QrService>();
    final result = await qr.scanByTrainer(
      code: code,
      moduleId: _selectedModuleId!,
    );

    if (!mounted) return;

    setState(() {
      _scanning = false;
      if (result != null) {
        _lastResult = result;
        _codeCtrl.clear();
      } else {
        _error = qr.error ?? 'Erreur lors du scan';
      }
    });
  }

  Future<void> _openCameraScanner() async {
    // Demander la permission camera
    final hasCamera = await PermissionService.requestCamera();
    if (!hasCamera) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission camera refusee'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    // ✅ Verification mounted avant usage de context
    if (!mounted) return;

    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const _CameraScanPage(),
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      _codeCtrl.text = result;
      await _scan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Scanner un QR code'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadModules,
            tooltip: 'Recharger les modules',
          ),
        ],
      ),
      body: _loadingModules
          ? const Center(child: CircularProgressIndicator())
          : _modules.isEmpty
              ? _buildEmpty()
              : _buildForm(),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: AppColors.textMuted),
            SizedBox(height: 16),
            Text(
              'Aucun module disponible',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text(
              'Les modules apparaissent une fois leur date de debut atteinte et approuves.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Selection du module
        const Text(
          '1. Selectionnez le module',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedModuleId,
          decoration: const InputDecoration(
            labelText: 'Module',
            prefixIcon: Icon(Icons.book_outlined),
            border: OutlineInputBorder(),
          ),
          items: _modules.map((m) {
            final title = m['title'] as String? ?? 'Module';
            final formation = m['formation_title'] as String? ?? '';
            return DropdownMenuItem(
              value: m['id'] as String,
              child: Text(
                '$title${formation.isNotEmpty ? " - $formation" : ""}',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (v) => setState(() => _selectedModuleId = v),
        ),
        const SizedBox(height: 24),

        // Scan du QR
        const Text(
          '2. Scannez le QR code de l\'apprenant',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _codeCtrl,
          decoration: InputDecoration(
            labelText: 'Code QR',
            hintText: 'QR-XXXXX...',
            prefixIcon: const Icon(Icons.qr_code),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.camera_alt),
              tooltip: 'Scanner avec la camera',
              onPressed: _openCameraScanner,
            ),
          ),
          onSubmitted: (_) => _scan(),
        ),
        const SizedBox(height: 16),

        // Bouton scanner
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _scanning ? null : _scan,
            icon: _scanning
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.qr_code_scanner),
            label: Text(_scanning ? 'Scan en cours...' : 'Pointer la presence'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Erreur
        if (_error != null)
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
                Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.danger))),
              ],
            ),
          ),

        // Resultat
        if (_lastResult != null) _buildResult(_lastResult!),
      ],
    );
  }

  Widget _buildResult(Map<String, dynamic> result) {
    final learner = result['learner'] as Map<String, dynamic>? ?? {};
    final formation = result['formation'] as Map<String, dynamic>? ?? {};
    final module = result['module'] as Map<String, dynamic>? ?? {};
    final progress = result['progress'] as int? ?? 0;
    final scannedCount = result['scanned_modules'] as int? ?? 0;
    final totalCount = result['total_modules'] as int? ?? 0;
    final completed = result['completed'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: completed
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.success.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                completed ? Icons.celebration : Icons.check_circle,
                color: AppColors.success,
                size: 28,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  completed
                      ? 'Formation terminee !'
                      : 'Presence pointee !',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          _row('Apprenant', learner['full_name'] as String? ?? '-'),
          _row('Formation', formation['title'] as String? ?? '-'),
          _row('Module', module['title'] as String? ?? '-'),
          _row('Progression', '$progress%'),
          _row('Modules scannes', '$scannedCount / $totalCount'),

          if (completed) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.mauve.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.workspace_premium, color: AppColors.mauve),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Un certificat a ete genere automatiquement pour cet apprenant.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mauve,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// =============================================================
// Page de scan camera
// =============================================================
class _CameraScanPage extends StatefulWidget {
  const _CameraScanPage();

  @override
  State<_CameraScanPage> createState() => _CameraScanPageState();
}

class _CameraScanPageState extends State<_CameraScanPage> {
  final _controller = MobileScannerController();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    _handled = true;
    Navigator.pop(context, code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scanner le QR code'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.mauve, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: Colors.black.withValues(alpha: 0.6),
              child: const Text(
                'Placez le QR code dans le cadre',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
