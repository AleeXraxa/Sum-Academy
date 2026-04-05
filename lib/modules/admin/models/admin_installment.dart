class AdminInstallmentPlan {
  final String planId;
  final String studentName;
  final String studentEmail;
  final double totalAmount;
  final double remainingAmount;
  final int numberOfInstallments;
  final int paidInstallments;
  final String status;
  final DateTime? startDate;
  final DateTime? nextDueDate;
  final String courseTitle;
  final String className;

  const AdminInstallmentPlan({
    required this.planId,
    required this.studentName,
    required this.studentEmail,
    required this.totalAmount,
    required this.remainingAmount,
    required this.numberOfInstallments,
    required this.paidInstallments,
    required this.status,
    required this.startDate,
    required this.nextDueDate,
    required this.courseTitle,
    required this.className,
  });

  factory AdminInstallmentPlan.fromJson(Map<String, dynamic> json) {
    final student = _asMap(json['student']);
    final course = _asMap(json['course']);
    final classInfo = _asMap(json['class']);
    return AdminInstallmentPlan(
      planId: _stringOr(json['planId'],
          _stringOr(json['id'], _stringOr(json['_id'], ''))),
      studentName: _stringOr(
        json['studentName'],
        _stringOr(student['fullName'], _stringOr(student['name'], 'Student')),
      ),
      studentEmail: _stringOr(
        json['studentEmail'],
        _stringOr(student['email'], ''),
      ),
      totalAmount: _toDouble(
        json['totalAmount'] ??
            json['amount'] ??
            json['payableAmount'] ??
            json['planAmount'],
      ),
      remainingAmount: _toDouble(
        json['remainingAmount'] ??
            json['remaining'] ??
            json['dueAmount'] ??
            json['balance'],
      ),
      numberOfInstallments: _toInt(
        json['numberOfInstallments'] ??
            json['installmentCount'] ??
            json['totalInstallments'],
      ),
      paidInstallments: _toInt(
        json['paidInstallments'] ??
            json['paidCount'] ??
            json['completedInstallments'],
      ),
      status: _stringOr(
        json['status'],
        _stringOr(json['planStatus'], 'pending'),
      ),
      startDate: _toDate(json['startDate'] ?? json['createdAt']),
      nextDueDate: _toDate(
        json['nextDueDate'] ??
            json['nextInstallmentDate'] ??
            json['dueDate'],
      ),
      courseTitle: _stringOr(
        json['courseTitle'],
        _stringOr(course['title'], ''),
      ),
      className: _stringOr(
        json['className'],
        _stringOr(classInfo['name'], ''),
      ),
    );
  }
}

class InstallmentItem {
  final int number;
  final double amount;
  final String status;
  final DateTime? dueDate;
  final DateTime? paidAt;

  const InstallmentItem({
    required this.number,
    required this.amount,
    required this.status,
    required this.dueDate,
    required this.paidAt,
  });

  factory InstallmentItem.fromJson(Map<String, dynamic> json) {
    return InstallmentItem(
      number: _toInt(json['number'] ?? json['index'] ?? json['installmentNo']),
      amount: _toDouble(json['amount'] ?? json['dueAmount']),
      status: _stringOr(json['status'], 'pending'),
      dueDate: _toDate(json['dueDate']),
      paidAt: _toDate(json['paidAt']),
    );
  }

  bool get isPaid =>
      status.toLowerCase().contains('paid') ||
      status.toLowerCase().contains('complete');
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return const {};
}

String _stringOr(dynamic value, String fallback) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

DateTime? _toDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  final parsed = DateTime.tryParse(value.toString());
  return parsed;
}
