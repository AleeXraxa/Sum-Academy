class StudentCourse {
  final String id;
  final String title;
  final String teacher;
  final String category;
  final double progress;
  final String status;
  final String nextLecture;

  const StudentCourse({
    required this.id,
    required this.title,
    required this.teacher,
    required this.category,
    required this.progress,
    required this.status,
    required this.nextLecture,
  });

  bool get isCompleted =>
      progress >= 1 || status.toLowerCase().contains('complete');
}

List<StudentCourse> parseStudentCourses(dynamic data) {
  if (data is List) {
    return data
        .whereType<Map<String, dynamic>>()
        .map(_courseFromMap)
        .where((course) => course.title.trim().isNotEmpty)
        .toList();
  }

  if (data is Map<String, dynamic>) {
    final list = _readList(data, const [
      'courses',
      'data',
      'items',
      'enrolledCourses',
      'myCourses',
    ]);
    if (list != null) {
      return parseStudentCourses(list);
    }
  }

  return const [];
}

StudentCourse _courseFromMap(Map<String, dynamic> map) {
  final title = _readString(map, const ['title', 'name', 'courseTitle']);
  final teacher = _readString(
    map,
    const ['teacher', 'teacherName', 'instructor', 'mentor'],
  );
  final category = _readString(map, const ['category', 'subject', 'track']);
  final status = _readString(map, const ['status', 'state', 'courseStatus']);
  final nextLecture = _readString(
    map,
    const ['nextLecture', 'nextLesson', 'nextActivity', 'nextContent'],
  );
  final progress = _normalizeProgress(
    _readDouble(
      map,
      const ['progress', 'completion', 'completionPercent', 'progressPercent'],
    ),
  );

  return StudentCourse(
    id: _readString(map, const ['id', '_id', 'courseId']),
    title: title,
    teacher: teacher,
    category: category,
    progress: progress,
    status: status,
    nextLecture:
        nextLecture.isEmpty ? 'Resume from your last activity' : nextLecture,
  );
}

String _readString(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return '';
}

double _readDouble(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value == null) continue;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.replaceAll(',', '').trim());
      if (parsed != null) return parsed;
    }
  }
  return 0;
}

double _normalizeProgress(double value) {
  if (value <= 0) return 0;
  if (value <= 1) return value;
  return (value / 100).clamp(0.0, 1.0);
}

List<dynamic>? _readList(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is List) return value;
  }
  return null;
}
