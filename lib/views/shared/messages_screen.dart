// =============================================================
// ChefUnitPlus - MessagesScreen
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../services/message_service.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final svc = context.read<MessageService>();
      svc.loadMy();
      svc.loadSent();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'A l\'instant';
      if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
      if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Nouveau message',
            onPressed: () => _showNewMessageDialog(),
          ),
          Consumer<MessageService>(
            builder: (context, svc, _) {
              if (svc.unreadCount == 0) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.done_all),
                tooltip: 'Tout marquer comme lu',
                onPressed: () => svc.markAllAsRead(),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Recus', icon: Icon(Icons.inbox)),
            Tab(text: 'Envoyes', icon: Icon(Icons.send)),
          ],
        ),
      ),
      body: Consumer<MessageService>(
        builder: (context, svc, _) {
          if (svc.loading && svc.myMessages.isEmpty && svc.sentMessages.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            controller: _tabCtrl,
            children: [
              _buildList(svc.myMessages, svc, received: true),
              _buildList(svc.sentMessages, svc, received: false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> list, MessageService svc, {required bool received}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(received ? Icons.inbox_outlined : Icons.send_outlined, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(received ? 'Aucun message recu' : 'Aucun message envoye',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => received ? svc.loadMy() : svc.loadSent(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: list.length,
        itemBuilder: (_, i) => _buildCard(list[i], svc, received: received),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> msg, MessageService svc, {required bool received}) {
    final isRead = msg['is_read'] == 1;
    final name = received ? (msg['sender_name']?.toString() ?? 'Inconnu') : (msg['receiver_name']?.toString() ?? 'Inconnu');
    final role = received ? (msg['sender_role']?.toString() ?? '') : (msg['receiver_role']?.toString() ?? '');
    final content = msg['content']?.toString() ?? '';
    final subject = msg['subject']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: (isRead || !received) ? Colors.white : AppColors.mauve.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isRead || !received) ? Colors.grey.shade200 : AppColors.mauve.withValues(alpha: 0.3),
          width: (isRead || !received) ? 1 : 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (received && !isRead) svc.markAsRead(msg['id'] as String);
            _showDetail(msg, received: received);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.mauve.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(received ? Icons.person : Icons.send, color: AppColors.mauve, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: (isRead || !received) ? FontWeight.w600 : FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (!isRead && received)
                            Container(width: 8, height: 8,
                              decoration: const BoxDecoration(color: AppColors.mauve, shape: BoxShape.circle)),
                        ],
                      ),
                      if (role.isNotEmpty)
                        Text('@$role', style: const TextStyle(fontSize: 10, color: AppColors.mauve)),
                      if (subject.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(subject, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                      const SizedBox(height: 4),
                      Text(content, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4)),
                      const SizedBox(height: 6),
                      Text(_formatDate(msg['created_at']?.toString()),
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetail(Map<String, dynamic> msg, {required bool received}) {
    final name = received ? (msg['sender_name']?.toString() ?? 'Message') : (msg['receiver_name']?.toString() ?? 'Message');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (msg['subject'] != null && msg['subject'].toString().isNotEmpty)
                Text(msg['subject'].toString(), style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(msg['content']?.toString() ?? ''),
              const SizedBox(height: 12),
              Text(_formatDate(msg['created_at']?.toString()),
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ),
        actions: [
          if (received)
            TextButton.icon(
              onPressed: () { Navigator.pop(context); _showReplyDialog(msg); },
              icon: const Icon(Icons.reply),
              label: const Text('Repondre'),
            ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
        ],
      ),
    );
  }

  void _showReplyDialog(Map<String, dynamic> msg) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Repondre a ${msg['sender_name']}'),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Votre message...', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              final svc = context.read<MessageService>();
              final messenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(ctx);
              final ok = await svc.send(receiverId: msg['sender_id'] as String, content: ctrl.text.trim());
              nav.pop();
              messenger.showSnackBar(SnackBar(
                content: Text(ok ? 'Message envoye' : 'Erreur'),
                backgroundColor: ok ? AppColors.success : AppColors.danger,
              ));
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  void _showNewMessageDialog() async {
    final svc = context.read<MessageService>();
    await svc.loadContacts();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => _NewMessageDialog(contacts: svc.contacts),
    );
  }
}

// ============================================================
// DIALOG NOUVEAU MESSAGE
// ============================================================
class _NewMessageDialog extends StatefulWidget {
  final List<Map<String, dynamic>> contacts;
  const _NewMessageDialog({required this.contacts});

  @override
  State<_NewMessageDialog> createState() => _NewMessageDialogState();
}

class _NewMessageDialogState extends State<_NewMessageDialog> {
  String? _selectedId;
  final _subjectCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouveau message'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Destinataire', border: OutlineInputBorder()),
                items: widget.contacts.map((c) => DropdownMenuItem<String>(
                  value: c['id'] as String,
                  child: Text('${c['full_name']} (@${c['role']})', overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (v) => setState(() => _selectedId = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _subjectCtrl,
                decoration: const InputDecoration(labelText: 'Sujet (optionnel)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contentCtrl,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Votre message...', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        ElevatedButton(
          onPressed: () async {
            if (_selectedId == null || _contentCtrl.text.trim().isEmpty) return;
            final svc = context.read<MessageService>();
            final messenger = ScaffoldMessenger.of(context);
            final nav = Navigator.of(context);
            final ok = await svc.send(
              receiverId: _selectedId!,
              content: _contentCtrl.text.trim(),
              subject: _subjectCtrl.text.trim(),
            );
            nav.pop();
            messenger.showSnackBar(SnackBar(
              content: Text(ok ? 'Message envoye' : 'Erreur'),
              backgroundColor: ok ? AppColors.success : AppColors.danger,
            ));
          },
          child: const Text('Envoyer'),
        ),
      ],
    );
  }
}