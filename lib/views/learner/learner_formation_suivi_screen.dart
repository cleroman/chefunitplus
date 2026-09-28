// =============================================================
// ChefUnitPlus - LearnerFormationSuiviScreen
// Suivi de formation : presence + materiaux + questions
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../services/attendance_service.dart';
import '../../services/material_service.dart';
import '../../services/question_service.dart';

class LearnerFormationSuiviScreen extends StatefulWidget {
  final String formationId;
  final String formationTitle;

  const LearnerFormationSuiviScreen({
    super.key,
    required this.formationId,
    required this.formationTitle,
  });

  @override
  State<LearnerFormationSuiviScreen> createState() => _LearnerFormationSuiviScreenState();
}

class _LearnerFormationSuiviScreenState extends State<LearnerFormationSuiviScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _loading = true;
  String? _error;

  // Presence
  List<Map<String, dynamic>> _attendances = [];
  Map<String, dynamic> _stats = {};

  // Materiaux
  List<Map<String, dynamic>> _materials = [];
  List<Map<String, dynamic>> _modules = [];

  // Questions
  List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final attSvc = context.read<AttendanceService>();
      final matSvc = context.read<MaterialService>();
      final qSvc = context.read<QuestionService>();

      final att = await attSvc.listMy(formationId: widget.formationId);
      final stats = await attSvc.getStats(widget.formationId);
      final mats = await matSvc.listFormationMaterials(widget.formationId);
      final mods = await matSvc.listAvailableModules(widget.formationId);
      final qs = await qSvc.listMy();

      final filtered = qs.where((q) => q['formation_id'] == widget.formationId).toList();

      if (mounted) {
        setState(() {
          _attendances = att;
          _stats = stats;
          _materials = mats;
          _modules = mods;
          _questions = filtered;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.formationTitle, overflow: TextOverflow.ellipsis),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.check_circle_outline), text: 'Presence'),
            Tab(icon: Icon(Icons.folder_outlined), text: 'Formation'),
            Tab(icon: Icon(Icons.download_outlined), text: 'Modules'),
            Tab(icon: Icon(Icons.help_outline), text: 'Questions'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _buildPresenceTab(),
                    _buildFormationMaterialsTab(),
                    _buildModulesTab(),
                    _buildQuestionsTab(),
                  ],
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Reessayer')),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TAB 1 : PRESENCE
  // ============================================================
  Widget _buildPresenceTab() {
    return Column(
      children: [
        // Stats + bouton pointer
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _statBox(
                      '${_stats['present'] ?? 0}',
                      'Presences',
                      Icons.check_circle,
                      AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statBox(
                      '${_stats['total'] ?? 0}',
                      'Total',
                      Icons.event,
                      AppColors.mauve,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _checkIn,
                  icon: const Icon(Icons.touch_app),
                  label: const Text('Pointer ma presence'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Liste
        Expanded(
          child: _attendances.isEmpty
              ? const Center(
                  child: Text('Aucune presence pointee', style: TextStyle(color: AppColors.textMuted)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _attendances.length,
                  itemBuilder: (_, i) {
                    final a = _attendances[i];
                    return _attendanceCard(a);
                  },
                ),
        ),
      ],
    );
  }

  Widget _statBox(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _attendanceCard(Map<String, dynamic> a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a['session_date'] as String? ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Entree : ${_formatTime(a['check_in_time'])}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                if (a['check_out_time'] != null)
                  Text(
                    'Sortie : ${_formatTime(a['check_out_time'])}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(dynamic iso) {
    if (iso == null) return '--';
    try {
      final dt = DateTime.parse(iso.toString());
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '--';
    }
  }

  Future<void> _checkIn() async {
    final attSvc = context.read<AttendanceService>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      await attSvc.checkIn(formationId: widget.formationId);
      messenger.showSnackBar(
        const SnackBar(content: Text('Presence pointee'), backgroundColor: AppColors.success),
      );
      _load();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  // ============================================================
  // TAB 2 : FORMATION MATERIALS
  // ============================================================
  Widget _buildFormationMaterialsTab() {
    if (_materials.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text('Aucun materiel disponible', style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _materials.length,
      itemBuilder: (_, i) => _materialCard(_materials[i]),
    );
  }

  Widget _materialCard(Map<String, dynamic> m) {
    final type = m['type'] as String? ?? 'pdf';
    final icon = type == 'video' ? Icons.play_circle_outline : Icons.picture_as_pdf;
    final color = type == 'video' ? Colors.red : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m['title'] as String? ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (m['description'] != null)
                  Text(
                    m['description'] as String,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download, color: AppColors.mauve),
            onPressed: () => _download(m['file_url'] as String?),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 3 : MODULES
  // ============================================================
  Widget _buildModulesTab() {
    if (_modules.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download_done, size: 64, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text('Aucun module disponible', style: TextStyle(color: AppColors.textMuted)),
            SizedBox(height: 8),
            Text(
              'Les modules apparaitront selon leur date de dispensation',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _modules.length,
      itemBuilder: (_, i) => _moduleMaterialCard(_modules[i]),
    );
  }

  Widget _moduleMaterialCard(Map<String, dynamic> m) {
    final type = m['type'] as String? ?? 'pdf';
    final icon = type == 'video' ? Icons.play_circle_outline : Icons.picture_as_pdf;
    final color = type == 'video' ? Colors.red : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            m['module_title'] as String? ?? 'Module',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m['title'] as String? ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (m['release_date'] != null)
                      Text(
                        'Disponible depuis : ${m['release_date']}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.download, color: AppColors.mauve),
                onPressed: () => _download(m['file_url'] as String?),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _download(String? url) {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fichier non disponible'), backgroundColor: AppColors.warning),
      );
      return;
    }
    // Ouvre l'URL dans le navigateur
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Telechargement : $url'), backgroundColor: AppColors.mauve),
    );
  }

  // ============================================================
  // TAB 4 : QUESTIONS
  // ============================================================
  Widget _buildQuestionsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _askQuestion,
              icon: const Icon(Icons.add_comment),
              label: const Text('Poser une question'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mauve,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        Expanded(
          child: _questions.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.question_answer_outlined, size: 64, color: AppColors.textMuted),
                      SizedBox(height: 12),
                      Text('Aucune question posee', style: TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _questions.length,
                  itemBuilder: (_, i) => _questionCard(_questions[i]),
                ),
        ),
      ],
    );
  }

  Widget _questionCard(Map<String, dynamic> q) {
    final status = q['status'] as String? ?? 'open';
    final color = status == 'answered'
        ? AppColors.success
        : status == 'closed'
            ? AppColors.textMuted
            : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  q['title'] as String? ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status == 'answered' ? 'Repondu' : status == 'closed' ? 'Ferme' : 'Ouvert',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            q['content'] as String? ?? '',
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.chat_bubble_outline, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                '${q['answer_count'] ?? 0} reponse(s)',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _askQuestion() async {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Poser une question'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
              ),
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
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final title = titleCtrl.text.trim();
    final content = contentCtrl.text.trim();

    if (title.isEmpty || content.isEmpty) return;

    if (!mounted) return;

    final qSvc = context.read<QuestionService>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      await qSvc.create(
        formationId: widget.formationId,
        title: title,
        content: content,
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Question envoyee'), backgroundColor: AppColors.success),
      );
      _load();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: AppColors.danger),
      );
    }
  }
}