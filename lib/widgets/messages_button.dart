// =============================================================
// ChefUnitPlus - MessagesButton (badge avec compteur)
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../services/message_service.dart';
import '../views/shared/messages_screen.dart';

class MessagesButton extends StatefulWidget {
  const MessagesButton({super.key});

  @override
  State<MessagesButton> createState() => _MessagesButtonState();
}

class _MessagesButtonState extends State<MessagesButton> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageService>().loadMy();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageService>(
      builder: (context, svc, _) {
        final count = svc.unreadCount;
        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.mail_outline, color: Colors.white),
              tooltip: 'Messages',
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const MessagesScreen(),
                ));
                if (mounted) svc.loadMy();
              },
            ),
            if (count > 0)
              Positioned(
                right: 6, top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}