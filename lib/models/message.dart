// ChefUnitPlus - Modeles Chat
class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        conversationId: (json['conversationId'] ?? json['conversation_id'] ?? '')
            .toString(),
        senderId: (json['senderId'] ?? json['sender_id'] ?? '').toString(),
        senderName: json['senderName'] ?? json['sender_name'] ?? 'Utilisateur',
        content: json['content'] ?? '',
        createdAt:
            _parseDate(json['createdAt'] ?? json['created_at']) ?? DateTime.now(),
        isRead: json['isRead'] ?? json['is_read'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'senderId': senderId,
        'senderName': senderName,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
      };

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }
}

class Conversation {
  final String id;
  final String participantId;
  final String participantName;
  final String? participantRole;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.participantRole,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        participantId: (json['participantId'] ?? json['participant_id'] ?? '')
            .toString(),
        participantName:
            json['participantName'] ?? json['participant_name'] ?? 'Contact',
        participantRole: json['participantRole'] ?? json['participant_role'],
        lastMessage: json['lastMessage'] ?? json['last_message'],
        lastMessageAt:
            _parseDate(json['lastMessageAt'] ?? json['last_message_at']),
        unreadCount: json['unreadCount'] ?? json['unread_count'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'participantId': participantId,
        'participantName': participantName,
        'participantRole': participantRole,
        'lastMessage': lastMessage,
        'lastMessageAt': lastMessageAt?.toIso8601String(),
        'unreadCount': unreadCount,
      };

  String get initials {
    if (participantName.trim().isEmpty) return '?';
    final parts = participantName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  String get lastMessagePreview {
    if (lastMessage == null || lastMessage!.isEmpty) return 'Aucun message';
    return lastMessage!.length > 50
        ? '${lastMessage!.substring(0, 50)}...'
        : lastMessage!;
  }

  String get lastMessageTime {
    if (lastMessageAt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(lastMessageAt!);
    if (diff.inMinutes < 1) return 'maintenant';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}j';
    return '${lastMessageAt!.day}/${lastMessageAt!.month}';
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }
}