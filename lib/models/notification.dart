// =============================================================
// ChefUnitPlus - Modle AppNotification
// Notifications affiches dans l'app (in-app)
// =============================================================


enum NotificationType {
  info,
  success,
  warning,
  error,
  payment,
  enrollment,
  validation,
  system,
}

extension NotificationTypeX on NotificationType {
  String get label => switch (this) {
        NotificationType.info => 'Information',
        NotificationType.success => 'Succs',
        NotificationType.warning => 'Avertissement',
        NotificationType.error => 'Erreur',
        NotificationType.payment => 'Paiement',
        NotificationType.enrollment => 'Inscription',
        NotificationType.validation => 'Validation',
        NotificationType.system => 'Systme',
      };
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final bool read;
  final String? actionRoute; // route  ouvrir au tap
  final Map<String, dynamic>? payload; // donnes additionnelles
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.type = NotificationType.info,
    this.read = false,
    this.actionRoute,
    this.payload,
    required this.createdAt,
  });

  // ===========================================================
  // Y FACTORIES
  // ===========================================================
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: json['title'] ?? '',
      body: json['body'] ?? json['message'] ?? '',
      type: _parseType(json['type']),
      read: json['read'] ?? false,
      actionRoute: json['actionRoute'],
      payload: json['payload'] as Map<String, dynamic>?,
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
    );
  }

  // ===========================================================
  // Y" S?RIALISATION
  // ===========================================================
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type.name,
        'read': read,
        if (actionRoute != null) 'actionRoute': actionRoute,
        if (payload != null) 'payload': payload,
        'createdAt': createdAt.toIso8601String(),
      };

  // ===========================================================
  // Y"< COPYWITH
  // ===========================================================
  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    bool? read,
    String? actionRoute,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      read: read ?? this.read,
      actionRoute: actionRoute ?? this.actionRoute,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ===========================================================
  // Y" GETTERS
  // ===========================================================
  bool get isUnread => !read;
  bool get hasAction => actionRoute != null && actionRoute!.isNotEmpty;

  /// Heure relative : "il y a 5 min"
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return ' l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays}j';
    return 'il y a plus d\'une semaine';
  }

  // ===========================================================
  // Y COMPARAISON
  // ===========================================================
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppNotification &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AppNotification(id: $id, title: $title, type: ${type.name}, read: $read)';

  // ===========================================================
  // Y HELPERS PRIV?S
  // ===========================================================
  static NotificationType _parseType(dynamic v) {
    if (v == null) return NotificationType.info;
    final name = v.toString().toLowerCase();
    return NotificationType.values.firstWhere(
      (t) => t.name == name,
      orElse: () => NotificationType.info,
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }
}