// =============================================================
// ChefUnitPlus - Modele Enrollment + EnrollmentStatus
// =============================================================

import 'package:flutter/material.dart';

// ============================================================
// ENUM : Statut d'enrollment (avec TOUTES les constantes)
// ============================================================
enum EnrollmentStatus {
  pendingPayment,
  pendingDirector,
  approved,
  rejected,
  failed,
  cancelled,
  completed,
  unknown;

  static EnrollmentStatus fromString(String? status) {
    switch (status) {
      case 'pending_payment':
        return EnrollmentStatus.pendingPayment;
      case 'pending_director':
        return EnrollmentStatus.pendingDirector;
      case 'approved':
        return EnrollmentStatus.approved;
      case 'rejected':
        return EnrollmentStatus.rejected;
      case 'failed':
        return EnrollmentStatus.failed;
      case 'cancelled':
        return EnrollmentStatus.cancelled;
      case 'completed':
        return EnrollmentStatus.completed;
      default:
        return EnrollmentStatus.unknown;
    }
  }

  String get label {
    switch (this) {
      case EnrollmentStatus.pendingPayment:
        return 'En attente de paiement';
      case EnrollmentStatus.pendingDirector:
        return 'En attente de validation';
      case EnrollmentStatus.approved:
        return 'Approuve';
      case EnrollmentStatus.rejected:
        return 'Refuse';
      case EnrollmentStatus.failed:
        return 'Echoue';
      case EnrollmentStatus.cancelled:
        return 'Annule';
      case EnrollmentStatus.completed:
        return 'Termine';
      case EnrollmentStatus.unknown:
        return 'Inconnu';
    }
  }

  Color get color {
    switch (this) {
      case EnrollmentStatus.pendingPayment:
      case EnrollmentStatus.pendingDirector:
        return const Color(0xFFF59E0B);
      case EnrollmentStatus.approved:
      case EnrollmentStatus.completed:
        return const Color(0xFF10B981);
      case EnrollmentStatus.rejected:
      case EnrollmentStatus.failed:
      case EnrollmentStatus.cancelled:
        return const Color(0xFFEF4444);
      case EnrollmentStatus.unknown:
        return const Color(0xFF6B7280);
    }
  }

  IconData get icon {
    switch (this) {
      case EnrollmentStatus.pendingPayment:
        return Icons.hourglass_empty;
      case EnrollmentStatus.pendingDirector:
        return Icons.pending_actions;
      case EnrollmentStatus.approved:
        return Icons.check_circle_outline;
      case EnrollmentStatus.rejected:
        return Icons.cancel_outlined;
      case EnrollmentStatus.failed:
        return Icons.error_outline;
      case EnrollmentStatus.cancelled:
        return Icons.block;
      case EnrollmentStatus.completed:
        return Icons.emoji_events_outlined;
      case EnrollmentStatus.unknown:
        return Icons.help_outline;
    }
  }
}

// ============================================================
// MODELE : Enrollment (proprietes NON-NULLABLES avec defauts)
// ============================================================
class Enrollment {
  final String id;
  final String learnerId;
  final String learnerName;
  final String learnerEmail;
  final String formationId;
  final String formationTitle;
  final String status;
  final double amountPaid;
  final String paymentRef;
  final String phone;
  final String accountName;
  final String requestedAt;
  final String paidAt;
  final String validatedAt;
  final String validatedBy;
  final String receiptNumber;
  final String directorComment;
  final int progressPercent;

  Enrollment({
    required this.id,
    this.learnerId = '',
    this.learnerName = '',
    this.learnerEmail = '',
    required this.formationId,
    this.formationTitle = '',
    this.status = 'pending_payment',
    this.amountPaid = 0,
    this.paymentRef = '',
    this.phone = '',
    this.accountName = '',
    this.requestedAt = '',
    this.paidAt = '',
    this.validatedAt = '',
    this.validatedBy = '',
    this.receiptNumber = '',
    this.directorComment = '',
    this.progressPercent = 0,
  });

  factory Enrollment.fromMap(Map<String, dynamic> map) {
    return Enrollment(
      id: map['id']?.toString() ?? '',
      learnerId: map['learner_id']?.toString() ?? '',
      learnerName: map['learner_name']?.toString() ?? '',
      learnerEmail: map['learner_email']?.toString() ?? '',
      formationId: map['formation_id']?.toString() ?? '',
      formationTitle:
          (map['formation_title_full'] ?? map['formation_title'])?.toString() ?? '',
      status: map['status']?.toString() ?? 'pending_payment',
      amountPaid: (map['amount_paid'] as num?)?.toDouble() ?? 0,
      paymentRef: map['payment_ref']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      accountName: map['account_name']?.toString() ?? '',
      requestedAt: map['requested_at']?.toString() ?? '',
      paidAt: map['paid_at']?.toString() ?? '',
      validatedAt: map['validated_at']?.toString() ?? '',
      validatedBy: map['validated_by']?.toString() ?? '',
      receiptNumber: map['receipt_number']?.toString() ?? '',
      directorComment: map['director_comment']?.toString() ?? '',
      progressPercent: (map['progress_percent'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'learner_id': learnerId,
        'learner_name': learnerName,
        'learner_email': learnerEmail,
        'formation_id': formationId,
        'formation_title': formationTitle,
        'status': status,
        'amount_paid': amountPaid,
        'payment_ref': paymentRef,
        'phone': phone,
        'account_name': accountName,
        'requested_at': requestedAt,
        'paid_at': paidAt,
        'validated_at': validatedAt,
        'validated_by': validatedBy,
        'receipt_number': receiptNumber,
        'director_comment': directorComment,
        'progress_percent': progressPercent,
      };

  // ============================================================
  // GETTERS BOOLEENS
  // ============================================================
  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending_payment';
  bool get isRejected => status == 'rejected';
  bool get isCompleted => status == 'completed' || progressPercent >= 100;
  bool get isPaid => paidAt.isNotEmpty;
  bool get isAwaiting => isPending && isPaid;

  // ============================================================
  // GETTERS DATES (retournent DateTime NON-NULLABLE avec defaut)
  // ============================================================
  DateTime get requestedDate => _parseDate(requestedAt);
  DateTime get paidDate => _parseDate(paidAt);
  DateTime get validatedDate => _parseDate(validatedAt);
  DateTime get approvedAt => validatedDate;

  static DateTime _parseDate(String iso) {
    if (iso.isEmpty) return DateTime.now();
    try {
      return DateTime.parse(iso);
    } catch (_) {
      return DateTime.now();
    }
  }

  // ============================================================
  // GETTERS AFFICHAGE
  // ============================================================
  String get amountLabel => '${amountPaid.toStringAsFixed(0)} USD';
  String get statusLabel => statusEnum.label;
  EnrollmentStatus get statusEnum => EnrollmentStatus.fromString(status);
  String get progressLabel => '$progressPercent%';

  String get learnerInitials {
    if (learnerName.isEmpty) return '?';
    final parts = learnerName.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  String get shortId => id.length > 8 ? id.substring(0, 8) : id;

  @override
  String toString() => 'Enrollment($id, $status, $amountPaid)';
}