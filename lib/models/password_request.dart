// ChefUnitPlus - Modele PasswordRequest
class PasswordRequest {
  final String id;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String? reason;
  final String status; // pending, approved, rejected
  final String? processorName;
  final DateTime? processedAt;
  final DateTime createdAt;

  const PasswordRequest({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    this.reason,
    this.status = 'pending',
    this.processorName,
    this.processedAt,
    required this.createdAt,
  });

  factory PasswordRequest.fromJson(Map<String, dynamic> j) => PasswordRequest(
    id: (j['id'] ?? '').toString(),
    userId: (j['user_id'] ?? '').toString(),
    userName: j['user_name'],
    userEmail: j['user_email'],
    reason: j['reason'],
    status: j['status'] ?? 'pending',
    processorName: j['processor_name'],
    processedAt: j['processed_at'] != null
        ? DateTime.tryParse(j['processed_at'].toString())
        : null,
    createdAt: j['created_at'] != null
        ? DateTime.parse(j['created_at'].toString())
        : DateTime.now(),
  );

  bool get isPending => status == 'pending';
}