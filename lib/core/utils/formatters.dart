// =============================================================
// ChefUnitPlus - Formatage des montants, dates, textes
// =============================================================

import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String money(double amount, {String currency = 'USD'}) {
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    return '${formatter.format(amount)} $currency';
  }

  static String amount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    return formatter.format(amount);
  }

  static String moneyCompact(double amount, {String currency = 'USD'}) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return '${formatter.format(amount)} $currency';
  }

  static String moneyCDF(double amount) => money(amount, currency: 'CDF');

  static String date(DateTime date) =>
      DateFormat('d MMMM yyyy', 'fr_FR').format(date);

  static String dateShort(DateTime date) =>
      DateFormat('dd/MM/yyyy').format(date);

  static String dateTime(DateTime date) =>
      '${dateShort(date)} a ${time(date)}';

  static String time(DateTime date) => DateFormat('HH:mm').format(date);

  static String weekdayDate(DateTime date) =>
      DateFormat('EEEE d MMMM', 'fr_FR').format(date);

  static String relative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'a l instant';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return 'il y a $m minute${m > 1 ? 's' : ''}';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return 'il y a $h heure${h > 1 ? 's' : ''}';
    }
    if (diff.inDays < 7) {
      final d = diff.inDays;
      return 'il y a $d jour${d > 1 ? 's' : ''}';
    }
    if (diff.inDays < 30) {
      final w = (diff.inDays / 7).floor();
      return 'il y a $w semaine${w > 1 ? 's' : ''}';
    }
    if (diff.inDays < 365) {
      final mo = (diff.inDays / 30).floor();
      return 'il y a $mo mois';
    }
    final y = (diff.inDays / 365).floor();
    return 'il y a $y an${y > 1 ? 's' : ''}';
  }

  static String duration(int minutes) {
    if (minutes < 60) return '${minutes}min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}min';
  }

  static String durationFromSeconds(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    final parts = <String>[];
    if (h > 0) parts.add('${h}h');
    if (m > 0) parts.add(m.toString().padLeft(2, '0'));
    parts.add(s.toString().padLeft(2, '0'));
    return parts.join(' ');
  }

  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String titleCase(String text) {
    return text
        .split(' ')
        .map((w) => w.isEmpty ? w : capitalize(w))
        .join(' ');
  }

  static String initials(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    final first = parts.first;
    final last = parts.last;
    if (first.isEmpty || last.isEmpty) return '?';
    return '${first[0]}${last[0]}'.toUpperCase();
  }

  static String phoneNumber(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'\D'), '');
    if (cleaned.startsWith('243') && cleaned.length >= 12) {
      final body = cleaned.substring(3);
      return '+243 ${body.substring(0, 2)} ${body.substring(2, 5)} '
          '${body.substring(5, 7)} ${body.substring(7)}';
    }
    if (cleaned.startsWith('0') && cleaned.length >= 10) {
      return '${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} '
          '${cleaned.substring(6, 8)} ${cleaned.substring(8)}';
    }
    return raw;
  }

  static String percent(double value, {int decimals = 0}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  static String progress(int current, int total) {
    if (total == 0) return '0/0';
    final pct = (current / total * 100).round();
    return '$current/$total ($pct%)';
  }

  static String shortRef(String ref, {int prefixLen = 4, int suffixLen = 3}) {
    if (ref.length <= prefixLen + suffixLen + 3) return ref;
    return '${ref.substring(0, prefixLen)}...'
        '${ref.substring(ref.length - suffixLen)}';
  }

  static String generateRef() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return 'REF-${now.toString().substring(5)}';
  }
}