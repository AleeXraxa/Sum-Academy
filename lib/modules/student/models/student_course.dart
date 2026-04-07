class StudentCourse {
  final String id;
  final String title;
  final String teacher;
  final String category;
  final double progress;
  final String status;
  final String nextLecture;
  final String thumbnailUrl;
  final String classId;
  final String className;
  final String classCode;
  final String classTeacher;
  final int classTotalCourses;
  final int classPaidCourses;
  final bool isEnrolled;

  const StudentCourse({
    required this.id,
    required this.title,
    required this.teacher,
    required this.category,
    required this.progress,
    required this.status,
    required this.nextLecture,
    this.thumbnailUrl = '',
    this.classId = '',
    this.className = '',
    this.classCode = '',
    this.classTeacher = '',
    this.classTotalCourses = 0,
    this.classPaidCourses = 0,
    this.isEnrolled = true,
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
      'classes',
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
  var thumbnailUrl = _readString(map, const [
    'thumbnail',
    'thumbnailUrl',
    'image',
    'cover',
    'banner',
  ]);
  final classMap = _readNestedMap(map, const [
    'class',
    'batch',
    'cohort',
    'group',
  ]);
  final classId = _readFirstString([
    _readString(map, const ['classId', 'class_id', 'batchId', 'cohortId']),
    if (classMap != null)
      _readString(
        classMap,
        const ['id', '_id', 'classId', 'batchId', 'cohortId'],
      ),
  ]);
  final className = _readFirstString([
    _readString(
      map,
      const ['className', 'classTitle', 'batchName', 'cohortName', 'groupName'],
    ),
    if (classMap != null)
      _readString(
        classMap,
        const ['name', 'title', 'className', 'batchName'],
      ),
  ]);
  final classCode = _readFirstString([
    _readString(map, const ['classCode', 'batchCode', 'code', 'classRef']),
    if (classMap != null)
      _readString(
        classMap,
        const ['classCode', 'batchCode', 'code', 'classRef'],
      ),
  ]);
  final classTeacher = _readFirstString([
    _readString(
      map,
      const ['classTeacher', 'classInstructor', 'classMentor'],
    ),
    if (classMap != null)
      _readString(
        classMap,
        const ['teacher', 'teacherName', 'instructor', 'mentor'],
      ),
  ]);
  if (thumbnailUrl.isEmpty && classMap != null) {
    thumbnailUrl = _readString(classMap, const [
      'thumbnail',
      'thumbnailUrl',
      'image',
      'cover',
      'banner',
    ]);
  }
  final classTotalCourses = _readFirstInt([
    _readInt(
      map,
      const [
        'totalSubjects',
        'subjectsCount',
        'totalCourses',
        'classCoursesCount',
        'coursesCount',
        'totalCourseCount',
      ],
    ),
    if (classMap != null)
      _readInt(
        classMap,
        const [
          'totalSubjects',
          'subjectsCount',
          'totalCourses',
          'classCoursesCount',
          'coursesCount',
          'totalCourseCount',
        ],
      ),
  ]);
  final classPaidCourses = _readFirstInt([
    _readInt(
      map,
      const [
        'paidSubjects',
        'paidSubjectsCount',
        'purchasedSubjects',
        'paidCourses',
        'paidCoursesCount',
        'purchasedCourses',
        'paidCount',
      ],
    ),
    if (classMap != null)
      _readInt(
        classMap,
        const [
          'paidSubjects',
          'paidSubjectsCount',
          'purchasedSubjects',
          'paidCourses',
          'paidCoursesCount',
          'purchasedCourses',
          'paidCount',
        ],
      ),
  ]);
  final isEnrolled = _resolveIsEnrolled(map);

  return StudentCourse(
    id: _readString(map, const ['courseId', 'course_id', 'id', '_id']),
    title: title,
    teacher: teacher,
    category: category,
    progress: progress,
    status: status,
    nextLecture:
        nextLecture.isEmpty ? 'Resume from your last activity' : nextLecture,
    thumbnailUrl: thumbnailUrl,
    classId: classId,
    className: className,
    classCode: classCode,
    classTeacher: classTeacher,
    classTotalCourses: classTotalCourses,
    classPaidCourses: classPaidCourses,
    isEnrolled: isEnrolled,
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

bool? _readBool(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value == null) continue;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.trim().toLowerCase();
      if (lower == 'true' || lower == 'yes' || lower == '1') return true;
      if (lower == 'false' || lower == 'no' || lower == '0') return false;
    }
  }
  return null;
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

Map<String, dynamic>? _readNestedMap(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
  }
  return null;
}

String _readFirstString(List<String> values) {
  for (final value in values) {
    if (value.trim().isNotEmpty) return value;
  }
  return '';
}

int _readFirstInt(List<int> values) {
  for (final value in values) {
    if (value > 0) return value;
  }
  return 0;
}

int _readInt(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value == null) continue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value.replaceAll(',', '').trim());
      if (parsed != null) return parsed;
    }
  }
  return 0;
}

bool _resolveIsEnrolled(Map<String, dynamic> map) {
  final direct = _readBool(map, const [
    'isEnrolled',
    'enrolled',
    'isPurchased',
    'purchased',
    'isPaid',
    'paid',
    'hasAccess',
    'accessGranted',
    'isAccessGranted',
    'owned',
  ]);
  if (direct != null) return direct;

  final nested = _readNestedBool(map, const [
    'isEnrolled',
    'enrolled',
    'isPurchased',
    'purchased',
    'isPaid',
    'paid',
    'hasAccess',
    'accessGranted',
    'isAccessGranted',
    'owned',
  ]);
  if (nested != null) return nested;

  final status = _readNestedString(map, const [
    'enrollmentStatus',
    'accessStatus',
    'userStatus',
    'status',
  ]);
  if (status.isNotEmpty) {
    final normalized = status.toLowerCase();
    const positive = [
      'active',
      'enrolled',
      'completed',
      'in_progress',
      'in-progress',
      'started',
      'paid',
      'purchased',
      'access_granted',
      'access-granted',
      'approved',
    ];
    const negative = [
      'inactive',
      'not_enrolled',
      'not-enrolled',
      'pending',
      'blocked',
      'unpaid',
    ];
    if (positive.contains(normalized)) return true;
    if (negative.contains(normalized)) return false;
  }

  final progressValue = _readNestedDouble(map, const [
    'progress',
    'completion',
    'completionPercent',
    'progressPercent',
  ]);
  if (progressValue != null && progressValue > 0) return true;

  return true;
}

bool? _readNestedBool(Map<String, dynamic> map, List<String> keys) {
  for (final entry in map.entries) {
    final value = entry.value;
    if (value is Map<String, dynamic>) {
      final direct = _readBool(value, keys);
      if (direct != null) return direct;
      final nested = _readNestedBool(value, keys);
      if (nested != null) return nested;
    }
  }
  return null;
}

double? _readNestedDouble(Map<String, dynamic> map, List<String> keys) {
  for (final entry in map.entries) {
    final value = entry.value;
    if (value is Map<String, dynamic>) {
      final direct = _readDouble(value, keys);
      if (direct > 0) return direct;
      final nested = _readNestedDouble(value, keys);
      if (nested != null) return nested;
    }
  }
  return null;
}

String _readNestedString(Map<String, dynamic> map, List<String> keys) {
  for (final entry in map.entries) {
    final value = entry.value;
    if (value is Map<String, dynamic>) {
      final direct = _readString(value, keys);
      if (direct.isNotEmpty) return direct;
      final nested = _readNestedString(value, keys);
      if (nested.isNotEmpty) return nested;
    }
  }
  return '';
}
