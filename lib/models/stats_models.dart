// =============================================================
// ChefUnitPlus - Stats Models
// Modeles pour les statistiques avec tracabilite de la source
// =============================================================

class StatItem {
  final String label;
  final num value;
  final String source; // Table SQL ou endpoint
  final String? icon;
  final String? color;

  const StatItem({
    required this.label,
    required this.value,
    required this.source,
    this.icon,
    this.color,
  });

  factory StatItem.fromJson(Map<String, dynamic> json) {
    return StatItem(
      label: json['label'] as String? ?? '',
      value: json['value'] as num? ?? 0,
      source: json['source'] as String? ?? 'inconnue',
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'value': value,
        'source': source,
        'icon': icon,
        'color': color,
      };
}

class AdminStats {
  final Map<String, StatItem> users;
  final Map<String, StatItem> formations;
  final Map<String, StatItem> enrollments;
  final Map<String, StatItem> payments;
  final Map<String, StatItem> modules;
  final Map<String, StatItem> questions;
  final Map<String, StatItem> attendances;
  final Map<String, StatItem> revenue;

  const AdminStats({
    required this.users,
    required this.formations,
    required this.enrollments,
    required this.payments,
    required this.modules,
    required this.questions,
    required this.attendances,
    required this.revenue,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    Map<String, StatItem> parseGroup(String key) {
      final group = json[key] as Map<String, dynamic>? ?? {};
      final source = group['source'] as String? ?? key;
      return group.map((k, v) {
        if (k == 'source') return MapEntry(k, StatItem(label: k, value: 0, source: source));
        return MapEntry(
          k,
          StatItem(
            label: k,
            value: v is num ? v : 0,
            source: source,
          ),
        );
      });
    }

    return AdminStats(
      users: parseGroup('users'),
      formations: parseGroup('formations'),
      enrollments: parseGroup('enrollments'),
      payments: parseGroup('payments'),
      modules: parseGroup('modules'),
      questions: parseGroup('questions'),
      attendances: parseGroup('attendances'),
      revenue: parseGroup('revenue'),
    );
  }
}

class LearnerStats {
  final Map<String, StatItem> formations;
  final Map<String, StatItem> presences;
  final Map<String, StatItem> questions;
  final Map<String, StatItem> paiements;

  const LearnerStats({
    required this.formations,
    required this.presences,
    required this.questions,
    required this.paiements,
  });

  factory LearnerStats.fromJson(Map<String, dynamic> json) {
    Map<String, StatItem> parseGroup(String key) {
      final group = json[key] as Map<String, dynamic>? ?? {};
      final source = group['source'] as String? ?? key;
      return group.map((k, v) {
        if (k == 'source') return MapEntry(k, StatItem(label: k, value: 0, source: source));
        return MapEntry(
          k,
          StatItem(
            label: k,
            value: v is num ? v : 0,
            source: source,
          ),
        );
      });
    }

    return LearnerStats(
      formations: parseGroup('formations'),
      presences: parseGroup('presences'),
      questions: parseGroup('questions'),
      paiements: parseGroup('paiements'),
    );
  }
}

class TrainerStats {
  final Map<String, StatItem> modules;
  final Map<String, StatItem> formations;
  final Map<String, StatItem> questions;
  final Map<String, StatItem> apprenants;

  const TrainerStats({
    required this.modules,
    required this.formations,
    required this.questions,
    required this.apprenants,
  });

  factory TrainerStats.fromJson(Map<String, dynamic> json) {
    Map<String, StatItem> parseGroup(String key) {
      final group = json[key] as Map<String, dynamic>? ?? {};
      final source = group['source'] as String? ?? key;
      return group.map((k, v) {
        if (k == 'source') return MapEntry(k, StatItem(label: k, value: 0, source: source));
        return MapEntry(
          k,
          StatItem(
            label: k,
            value: v is num ? v : 0,
            source: source,
          ),
        );
      });
    }

    return TrainerStats(
      modules: parseGroup('modules'),
      formations: parseGroup('formations'),
      questions: parseGroup('questions'),
      apprenants: parseGroup('apprenants'),
    );
  }
}