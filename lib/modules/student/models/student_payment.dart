class StudentPaymentSummary {
  final String id;
  final String title;
  final String method;
  final double amount;
  final String status;
  final DateTime? createdAt;

  const StudentPaymentSummary({
    required this.id,
    required this.title,
    required this.method,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  String get statusLabel {
    if (status.isEmpty) return 'pending';
    return status.replaceAll('_', ' ').trim();
  }

  factory StudentPaymentSummary.fromJson(Map<String, dynamic> json) {
    return StudentPaymentSummary(
      id: _readString(json, const ['id', '_id', 'paymentId']),
      title: _readString(
        json,
        const ['courseTitle', 'title', 'courseName', 'className', 'name'],
      ),
      method: _readString(
        json,
        const ['method', 'paymentMethod', 'gateway', 'channel'],
      ),
      amount: _readDouble(
        json,
        const ['amount', 'totalAmount', 'paidAmount', 'price'],
      ),
      status: _readString(json, const ['status', 'state']),
      createdAt: _readDate(json, const ['createdAt', 'date', 'paidAt']),
    );
  }
}

class StudentInstallmentPlan {
  final String id;
  final int numberOfInstallments;
  final double remainingAmount;
  final double totalAmount;
  final DateTime? nextDueDate;

  const StudentInstallmentPlan({
    required this.id,
    required this.numberOfInstallments,
    required this.remainingAmount,
    required this.totalAmount,
    required this.nextDueDate,
  });

  factory StudentInstallmentPlan.fromJson(Map<String, dynamic> json) {
    return StudentInstallmentPlan(
      id: _readString(json, const ['planId', 'id', '_id']),
      numberOfInstallments:
          _readInt(json, const ['numberOfInstallments', 'installments']),
      remainingAmount: _readDouble(
        json,
        const ['remainingAmount', 'balance', 'dueAmount'],
      ),
      totalAmount:
          _readDouble(json, const ['totalAmount', 'amount', 'price']),
      nextDueDate: _readDate(json, const ['nextDueDate', 'dueDate']),
    );
  }
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return '';
}

int _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    final parsed = int.tryParse(value.toString());
    if (parsed != null) return parsed;
  }
  return 0;
}

double _readDouble(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(value.toString());
    if (parsed != null) return parsed;
  }
  return 0;
}

DateTime? _readDate(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    if (value is DateTime) return value;
    final text = value.toString();
    if (text.trim().isEmpty) continue;
    final parsed = DateTime.tryParse(text);
    if (parsed != null) return parsed;
  }
  return null;
}
