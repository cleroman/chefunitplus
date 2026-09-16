enum FormationType { woodBadge, campEcole, training, formationFormateurs, formationFormateursAdjoints }

extension FormationTypeX on FormationType {
  String get label => switch (this) {
        FormationType.woodBadge => 'Wood Badge',
        FormationType.campEcole => 'Camp Ecole',
        FormationType.training => 'Training',
        FormationType.formationFormateurs => 'Formation des Formateurs',
        FormationType.formationFormateursAdjoints => 'Formation des Formateurs Adjoints',
      };

  String get value => switch (this) {
        FormationType.woodBadge => 'wood_badge',
        FormationType.campEcole => 'camp_ecole',
        FormationType.training => 'training',
        FormationType.formationFormateurs => 'formation_formateurs',
        FormationType.formationFormateursAdjoints => 'formation_formateurs_adjoints',
      };

  static FormationType fromValue(String? v) {
    for (final t in FormationType.values) {
      if (t.value == v) return t;
    }
    return FormationType.training;
  }
}

class Formation {
  final String id;
  final String title;
  final String description;
  final double price;
  final String currency;
  final String? coverImage;
  final String directorId;
  final String? directorName;
  final String? trainerId;
  final String? trainerName;
  final FormationType type;
  final DateTime? startDate;
  final DateTime? endDate;
  final int totalHours;
  final String? pdfPath;
  final String? ficheTechniquePath;
  final int maxParticipants;
  final bool isPublished;
  final int enrolledCount;
  final int moduleCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Formation({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.currency = 'USD',
    this.coverImage,
    required this.directorId,
    this.directorName,
    this.trainerId,
    this.trainerName,
    this.type = FormationType.training,
    this.startDate,
    this.endDate,
    this.totalHours = 0,
    this.pdfPath,
    this.ficheTechniquePath,
    this.maxParticipants = 0,
    this.isPublished = false,
    this.enrolledCount = 0,
    this.moduleCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory Formation.fromJson(Map<String, dynamic> j) => Formation(
        id: (j['id'] ?? j['_id'] ?? '').toString(),
        title: j['title'] ?? '',
        description: j['description'] ?? '',
        price: _parseDouble(j['price']),
        currency: j['currency'] ?? 'USD',
        coverImage: j['coverImage'] ?? j['cover_image'],
        directorId: (j['directorId'] ?? j['director_id'] ?? '').toString(),
        directorName: j['directorName'] ?? j['director_name'],
        trainerId: j['trainerId']?.toString() ?? j['trainer_id']?.toString(),
        trainerName: j['trainerName'] ?? j['trainer_name'],
        type: FormationTypeX.fromValue(j['type'] as String?),
        startDate: _parseDate(j['startDate'] ?? j['start_date']),
        endDate: _parseDate(j['endDate'] ?? j['end_date']),
        totalHours: j['totalHours'] ?? j['total_hours'] ?? 0,
        pdfPath: j['pdfPath'] ?? j['pdf_path'],
        ficheTechniquePath: j['ficheTechniquePath'] ?? j['fiche_technique_path'],
        maxParticipants: j['maxParticipants'] ?? j['max_participants'] ?? 0,
        isPublished: j['isPublished'] ?? j['is_published'] ?? false,
        enrolledCount: j['enrolledCount'] ?? j['enrolled_count'] ?? 0,
        moduleCount: j['moduleCount'] ?? j['module_count'] ?? 0,
        createdAt: _parseDate(j['createdAt'] ?? j['created_at']),
        updatedAt: _parseDate(j['updatedAt'] ?? j['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'currency': currency,
        'directorId': directorId,
        'type': type.value,
        if (startDate != null) 'startDate': _d(startDate!),
        if (endDate != null) 'endDate': _d(endDate!),
      };

  // Getters
  String get priceLabel => '\$${price.toStringAsFixed(2)} $currency';
  bool get hasPdf => pdfPath != null && pdfPath!.isNotEmpty;
  bool get hasFiche => ficheTechniquePath != null && ficheTechniquePath!.isNotEmpty;
  bool get hasTrainer => trainerId != null;
  bool get hasSchedule => startDate != null && endDate != null;

  String get durationLabel {
    if (totalHours == 0) return 'Duree non definie';
    return '${totalHours}h';
  }

  String get scheduleLabel {
    if (!hasSchedule) return 'Dates non definies';
    return '${_d(startDate!)} → ${_d(endDate!)}';
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  static String _d(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Formation && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}