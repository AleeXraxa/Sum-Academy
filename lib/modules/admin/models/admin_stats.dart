class AdminStatsPayload {
  final int totalStudents;
  final int activeCourses;
  final int enrollmentsToday;
  final num totalRevenue;

  const AdminStatsPayload({
    required this.totalStudents,
    required this.activeCourses,
    required this.enrollmentsToday,
    required this.totalRevenue,
  });

  factory AdminStatsPayload.empty() => const AdminStatsPayload(
    totalStudents: 0,
    activeCourses: 0,
    enrollmentsToday: 0,
    totalRevenue: 0,
  );

  factory AdminStatsPayload.fromAny(dynamic data) {
    if (data is Map<String, dynamic>) {
      final resolved = _resolveStatsMap(data);
      return AdminStatsPayload(
        totalStudents: _readInt(resolved, const [
          'totalStudents',
          'students',
          'studentsCount',
          'studentCount',
          'totalStudent',
        ]),
        activeCourses: _readInt(resolved, const [
          'activeCourses',
          'courses',
          'coursesCount',
          'totalCourses',
          'activeCourseCount',
        ]),
        enrollmentsToday: _readInt(resolved, const [
          'enrollmentsToday',
          'todayEnrollments',
          'newEnrollments',
          'dailyEnrollments',
          'enrollments',
        ]),
        totalRevenue: _readNum(resolved, const [
          'totalRevenue',
          'revenue',
          'revenuePkr',
          'totalRevenuePkr',
          'totalRevenuePKR',
        ]),
      );
    }

    return AdminStatsPayload.empty();
  }
}

Map<String, dynamic> _resolveStatsMap(Map<String, dynamic> data) {
  final nestedKeys = ['stats', 'overview', 'summary', 'data'];
  for (final key in nestedKeys) {
    final value = data[key];
    if (value is Map<String, dynamic>) {
      return value;
    }
  }
  return data;
}

int _readInt(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = data[key];
    final parsed = _parseInt(value);
    if (parsed != null) {
      return parsed;
    }
  }
  return 0;
}

num _readNum(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = data[key];
    final parsed = _parseNum(value);
    if (parsed != null) {
      return parsed;
    }
  }
  return 0;
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final cleaned = value.replaceAll(',', '').trim();
    return int.tryParse(cleaned);
  }
  if (value is Map) {
    final nestedKeys = ['total', 'count', 'value'];
    for (final key in nestedKeys) {
      final nested = _parseInt(value[key]);
      if (nested != null) return nested;
    }
  }
  return null;
}

num? _parseNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) {
    final cleaned = value.replaceAll(',', '').trim();
    return num.tryParse(cleaned);
  }
  if (value is Map) {
    final nestedKeys = ['total', 'amount', 'value'];
    for (final key in nestedKeys) {
      final nested = _parseNum(value[key]);
      if (nested != null) return nested;
    }
  }
  return null;
}
