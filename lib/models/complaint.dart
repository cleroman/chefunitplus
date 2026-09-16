// =============================================================
// ChefUnitPlus - Modèle Complaint
// =============================================================

enum ComplaintPriority {
  low,
  normal,
  high,
  urgent,
}

extension ComplaintPriorityX on ComplaintPriority {
  String get label => switch (this) {
        ComplaintPriority.low => 'Basse',
        ComplaintPriority.normal => 'Normale',
        ComplaintPriority.high => 'Haute',
        ComplaintPriority.urgent => 'Urgente',
      };
}

enum ComplaintStatus {
  pending,
  inProgress,
  resolved,
  rejected,
}

extension ComplaintStatusX on ComplaintStatus {
  String get label => switch (this) {
        ComplaintStatus.pending => 'En attente',
        ComplaintStatus.inProgress => 'En cours',
        ComplaintStatus.resolved => 'Résolue',
        ComplaintStatus.rejected => 'Rejetée',
      };
}

class Complaint {
  final String id;
  final String userId;
  final String userName;
  final String subject;
  final String description;
  final ComplaintPriority priority;
  final ComplaintStatus status;
  final String? response;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const Complaint({
    required this.id,
    required this.userId,
    required this.userName,
    required this.subject,
    required this.description,
    this.priority = ComplaintPriority.normal,
    this.status = ComplaintStatus.pending,
    this.response,
    required this.createdAt,
    this.resolvedAt,
  });

  // ============ GETTERS UTILISÉS PAR LE CONTROLLER ============
  bool get isOpen =>
      status == ComplaintStatus.pending || status == ComplaintStatus.inProgress;

  bool get isPending => status == ComplaintStatus.pending;

  bool get isResolved => status == ComplaintStatus.resolved;

  bool get isRejected => status == ComplaintStatus.rejected;

  bool get hasResponse => response != null && response!.trim().isNotEmpty;

  // ============ FROM JSON ============
  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      userName: json['userName'] ?? '',
      subject: json['subject'] ?? '',
      description: json['description'] ?? json['message'] ?? '',
      priority: _parsePriority(json['priority']),
      status: _parseStatus(json['status']),
      response: json['response']?.toString(),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      resolvedAt: _parseDate(json['resolvedAt']),
    );
  }

  // ============ TO JSON ============
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'subject': subject,
        'description': description,
        'priority': priority.name,
        'status': status.name,
        if (response != null) 'response': response,
        'createdAt': createdAt.toIso8601String(),
        if (resolvedAt != null) 'resolvedAt': resolvedAt!.toIso8601String(),
      };

  // ============ COPYWITH ============
  Complaint copyWith({
    String? subject,
    String? description,
    ComplaintPriority? priority,
    ComplaintStatus? status,
    String? response,
    DateTime? resolvedAt,
  }) {
    return Complaint(
      id: id,
      userId: userId,
      userName: userName,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      response: response ?? this.response,
      createdAt: createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  // ============ HELPERS ============
  static ComplaintPriority _parsePriority(dynamic v) {
    if (v == null) return ComplaintPriority.normal;
    final name = v.toString().toLowerCase();
    final normalized = name == 'medium' ? 'normal' : name;
    return ComplaintPriority.values.firstWhere(
      (p) => p.name.toLowerCase() == normalized,
      orElse: () => ComplaintPriority.normal,
    );
  }

  static ComplaintStatus _parseStatus(dynamic v) {
    if (v == null) return ComplaintStatus.pending;
    final name = v.toString().toLowerCase();
    return ComplaintStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == name,
      orElse: () => ComplaintStatus.pending,
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }
}
