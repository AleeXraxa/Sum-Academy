class AdminPayment {
  final String id;
  final String studentName;
  final String studentEmail;
  final String status;
  final double amount;
  final String currency;
  final String method;
  final DateTime? createdAt;
  final String reference;
  final String courseTitle;
  final String className;
  final String receiptUrl;

  const AdminPayment({
    required this.id,
    required this.studentName,
    required this.studentEmail,
    required this.status,
    required this.amount,
    required this.currency,
    required this.method,
    required this.createdAt,
    required this.reference,
    required this.courseTitle,
    required this.className,
    required this.receiptUrl,
  });

  factory AdminPayment.fromJson(Map<String, dynamic> json) {
    final payment = _asMap(json['payment']);
    final doc = _asMap(json['doc']);
    final data = _asMap(json['data']);
    final base = <String, dynamic>{
      ...payment,
      ...doc,
      ...data,
      ...json,
    };
    final student = _asMap(json['student']);
    final user = _asMap(json['user']);
    final studentName = _stringOr(
      json['studentName'],
      _stringOr(student['fullName'], _stringOr(student['name'], '')),
    );
    final studentEmail = _stringOr(
      json['studentEmail'],
      _stringOr(student['email'], _stringOr(user['email'], '')),
    );
    final course = _asMap(json['course']);
    final classInfo = _asMap(json['class']);

    return AdminPayment(
      id: _stringOr(
        base['id'],
        _stringOr(
          base['_id'],
          _stringOr(
            base['paymentId'],
            _stringOr(
              payment['id'],
              _stringOr(payment['_id'], _stringOr(payment['paymentId'], '')),
            ),
          ),
        ),
      ),
      studentName: studentName.isNotEmpty ? studentName : 'Student',
      studentEmail: studentEmail,
      status: _stringOr(
        base['status'],
        _stringOr(base['paymentStatus'], _stringOr(base['state'], 'pending')),
      ),
      amount: _toDouble(
        base['amount'] ??
            base['paidAmount'] ??
            base['paymentAmount'] ??
            base['totalAmount'] ??
            base['receivedAmount'],
      ),
      currency: _stringOr(base['currency'], 'PKR'),
      method: _stringOr(
        base['method'],
        _stringOr(
          base['paymentMethod'],
          _stringOr(base['channel'], ''),
        ),
      ),
      createdAt: _toDate(
        base['createdAt'] ??
            base['paidAt'] ??
            base['date'] ??
            base['timestamp'],
      ),
      reference: _stringOr(
        base['reference'],
        _stringOr(base['refId'], _stringOr(base['transactionId'], '')),
      ),
      courseTitle: _stringOr(
        base['courseTitle'],
        _stringOr(course['title'], _stringOr(course['name'], '')),
      ),
      className: _stringOr(
        base['className'],
        _stringOr(classInfo['name'], _stringOr(classInfo['title'], '')),
      ),
      receiptUrl: _stringOr(
        base['receiptUrl'],
        _stringOr(base['receipt'], _stringOr(base['proof'], '')),
      ),
    );
  }

  AdminPayment copyWith({
    String? status,
  }) {
    return AdminPayment(
      id: id,
      studentName: studentName,
      studentEmail: studentEmail,
      status: status ?? this.status,
      amount: amount,
      currency: currency,
      method: method,
      createdAt: createdAt,
      reference: reference,
      courseTitle: courseTitle,
      className: className,
      receiptUrl: receiptUrl,
    );
  }
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

DateTime? _toDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  final parsed = DateTime.tryParse(value.toString());
  return parsed;
}
