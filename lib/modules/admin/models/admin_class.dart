class AdminClass {
  final String id;
  final String name;
  final String code;
  final String description;
  final String status;
  final int capacity;
  final int enrolledCount;
  final int courseCount;
  final int shiftCount;
  final DateTime? startDate;
  final DateTime? endDate;

  const AdminClass({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.status,
    required this.capacity,
    required this.enrolledCount,
    required this.courseCount,
    required this.shiftCount,
    required this.startDate,
    required this.endDate,
  });

  factory AdminClass.fromJson(Map<String, dynamic> json) {
    final id = _readString(json, ['id', '_id', 'classId']);
    final name = _readString(json, ['name', 'title', 'className']);
    final code = _readString(json, [
      'batchCode',
      'code',
      'classCode',
      'slug',
    ]);
    final description = _readString(json, [
      'description',
      'desc',
      'details',
      'summary',
    ]);
    final status = _readString(json, ['status', 'state'], fallback: 'active');
    final capacity = _readInt(json, [
      'capacity',
      'maxStudents',
      'studentLimit',
      'limit',
      'seats',
      'totalSeats',
    ]);
    var enrolled = _readInt(json, [
      'enrolledCount',
      'studentsCount',
      'studentCount',
      'enrolledStudents',
      'totalEnrolled',
    ]);
    enrolled = _resolveCountFromList(json, [
      'students',
      'enrollments',
      'studentList',
      'classStudents',
      'members',
    ], enrolled);

    var courseCount = _readInt(json, [
      'coursesCount',
      'courseCount',
      'totalCourses',
    ]);
    courseCount = _resolveCountFromList(
      json,
      ['courses', 'courseList', 'classCourses'],
      courseCount,
    );

    var shiftCount = _readInt(json, [
      'shiftsCount',
      'shiftCount',
      'totalShifts',
    ]);
    shiftCount = _resolveCountFromList(
      json,
      ['shifts', 'shiftList', 'classShifts'],
      shiftCount,
    );

    final startDate = _readDate(json, [
      'startDate',
      'start',
      'startsAt',
      'startAt',
      'startOn',
    ]);
    final endDate = _readDate(json, [
      'endDate',
      'end',
      'endsAt',
      'endAt',
      'endOn',
    ]);

    return AdminClass(
      id: id,
      name: name,
      code: code,
      description: description,
      status: status,
      capacity: capacity,
      enrolledCount: enrolled,
      courseCount: courseCount,
      shiftCount: shiftCount,
      startDate: startDate,
      endDate: endDate,
    );
  }

  AdminClass copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    String? status,
    int? capacity,
    int? enrolledCount,
    int? courseCount,
    int? shiftCount,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return AdminClass(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      status: status ?? this.status,
      capacity: capacity ?? this.capacity,
      enrolledCount: enrolledCount ?? this.enrolledCount,
      courseCount: courseCount ?? this.courseCount,
      shiftCount: shiftCount ?? this.shiftCount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

String _readString(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return fallback;
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

DateTime? _readDate(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    final parsed = _parseDate(value);
    if (parsed != null) return parsed;
  }
  return null;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) {
    final ms = value > 1000000000000 ? value : value * 1000;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }
  if (value is double) {
    final ms = value > 1000000000000 ? value.toInt() : (value * 1000).toInt();
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed;
  }
  if (value is Map) {
    final seconds = value['seconds'] ?? value['_seconds'];
    if (seconds is int) {
      return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    }
    if (seconds is double) {
      return DateTime.fromMillisecondsSinceEpoch(
        (seconds * 1000).toInt(),
      );
    }
  }
  return null;
}

int _resolveCountFromList(
  Map<String, dynamic> json,
  List<String> keys,
  int fallback,
) {
  if (fallback > 0) return fallback;
  for (final key in keys) {
    final value = json[key];
    final count = _countList(value);
    if (count > 0) return count;
  }
  return fallback;
}

int _countList(dynamic value) {
  if (value is List) return value.length;
  if (value is Map) {
    final data = value['data'];
    if (data is List) return data.length;
  }
  return 0;
}
