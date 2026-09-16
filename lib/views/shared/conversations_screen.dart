import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../controllers/chat_controller.dart';
import '../../models/message.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatController>().loadConversations(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ChatController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      body: ctrl.isLoading && ctrl.conversations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ctrl.conversations.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: () =>
                      ctrl.loadConversations(refresh: true),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: ctrl.conversations.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) =>
                        _buildConversationTile(ctrl.conversations[i]),
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.mauve.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 60,
                color: AppColors.mauve,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucune conversation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'La messagerie sera bientot disponible avec vos contacts.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationTile(Conversation conv) {
    return ListTile(
      onTap: () => _openChat(conv),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.mauve.withValues(alpha: 0.15),
            child: Text(
              conv.initials,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.mauveDark,
              ),
            ),
          ),
          if (conv.unreadCount > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${conv.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        conv.participantName,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        conv.lastMessagePreview,
        style: TextStyle(
          fontSize: 12,
          color: conv.unreadCount > 0
              ? AppColors.textPrimary
              : AppColors.textMuted,
          fontWeight:
              conv.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        conv.lastMessageTime,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  void _openChat(Conversation conv) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(conversation: conv),
      ),
    ).then((_) {
      if (mounted) {
        context.read<ChatController>().loadConversations(refresh: true);
      }
    });
  }
}