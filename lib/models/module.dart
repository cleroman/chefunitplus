enum ModuleStatus { pending, approved, rejected }

extension ModuleStatusX on ModuleStatus {
  String get label => switch (this) {
        ModuleStatus.pending => 'En attente',
        ModuleStatus.approved => 'Valide',
        ModuleStatus.rejected => 'Refuse',
      };

  String get value => switch (this) {
        ModuleStatus.pending => 'pending',
        ModuleStatus.approved => 'approved',
        ModuleStatus.rejected => 'rejected',
      };

  static ModuleStatus fromValue(String? v) {
    switch (v) {
      case 'pending': return ModuleStatus.pending;
      case 'approved': return ModuleStatus.approved;
      case 'rejected': return ModuleStatus.rejected;
      default: return ModuleStatus.approved;
    }
  }
}

class Module {
  final String id;
  final String formationId;
  final String? formationTitle;
  final String title;
  final String? description;
  final String? trainerId;
  final String? trainerName;
  final String? createdBy;
  final String? createdByName;
  final String? approvedBy;
  final String? approvedByName;
  final String? directorComment;
  final ModuleStatus status;
  final int order;
  final int hours;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? pdfPath;
  final int lessonCount;
  final DateTime? createdAt;
  final DateTime? approvedAt;

  const Module({
    required this.id,
    required this.formationId,
    this.formationTitle,
    required this.title,
    this.description,
    this.trainerId,
    this.trainerName,
    this.createdBy,
    this.createdByName,
    this.approvedBy,
    this.approvedByName,
    this.directorComment,
    this.status = ModuleStatus.approved,
    this.order = 0,
    this.hours = 0,
    this.startDate,
    this.endDate,
    this.pdfPath,
    this.lessonCount = 0,
    this.createdAt,
    this.approvedAt,
  });

  factory Module.fromJson(Map<String, dynamic> j) => Module(
        id: (j['id'] ?? j['_id'] ?? '').toString(),
        formationId: (j['formationId'] ?? j['formation_id'] ?? '').toString(),
        formationTitle: j['formationTitle'] ?? j['formation_title'],
        title: j['title'] ?? '',
        description: j['description'],
        trainerId: j['trainerId']?.toString() ?? j['trainer_id']?.toString(),
        trainerName: j['trainerName'] ?? j['trainer_name'],
        createdBy: j['createdBy']?.toString() ?? j['created_by']?.toString(),
        createdByName: j['createdByName'] ?? j['created_by_name'],
        approvedBy: j['approvedBy']?.toString() ?? j['approved_by']?.toString(),
        approvedByName: j['approvedByName'] ?? j['approved_by_name'],
        directorComment: j['directorComment'] ?? j['director_comment'],
        status: ModuleStatusX.fromValue(j['status'] as String?),
        order: j['order'] ?? 0,
        hours: j['hours'] ?? 0,
        startDate: _parseDate(j['startDate'] ?? j['start_date']),
        endDate: _parseDate(j['endDate'] ?? j['end_date']),
        pdfPath: j['pdfPath'] ?? j['pdf_path'],
        lessonCount: j['lessonCount'] ?? j['lesson_count'] ?? 0,
        createdAt: _parseDate(j['createdAt'] ?? j['created_at']),
        approvedAt: _parseDate(j['approvedAt'] ?? j['approved_at']),
      );

  // ============================================================
  // GETTERS
  // ============================================================
  bool get isPending => status == ModuleStatus.pending;
  bool get isApproved => status == ModuleStatus.approved;
  bool get isRejected => status == ModuleStatus.rejected;
  bool get hasTrainer => trainerId != null;
  bool get hasPdf => pdfPath != null && pdfPath!.isNotEmpty;
  bool get hasSchedule => startDate != null && endDate != null;
  bool get hasHours => hours > 0;

  String get hoursLabel => hours > 0 ? '${hours}h' : 'Non defini';

  String get durationLabel => hoursLabel;

  String get scheduleLabel {
    if (!hasSchedule) return 'Dates non definies';
    return '${_fmt(startDate!)} → ${_fmt(endDate!)}';
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Module && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}