class AdminCourse {
  final String id;
  final String title;
  final String shortDescription;
  final String description;
  final String category;
  final String level;
  final double price;
  final double discount;
  final String status;
  final bool certificateEnabled;
  final String thumbnailUrl;
  final int subjectCount;
  final int teacherCount;
  final int enrolledCount;
  final bool isArchived;

  const AdminCourse({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.description,
    required this.category,
    required this.level,
    required this.price,
    required this.discount,
    required this.status,
    required this.certificateEnabled,
    required this.thumbnailUrl,
    required this.subjectCount,
    required this.teacherCount,
    required this.enrolledCount,
    required this.isArchived,
  });

  factory AdminCourse.fromJson(Map<String, dynamic> json) {
    final id = _readString(json, ['id', '_id', 'courseId']);
    final title = _readString(json, ['title', 'name']);
    final shortDescription = _readString(json, [
      'shortDescription',
      'shortDesc',
      'summary',
    ]);
    final description = _readString(json, ['description', 'fullDescription']);
    final category = _readString(json, ['category', 'categoryName']);
    final level = _readString(json, ['level', 'difficulty']);
    final price = _readDouble(json, ['price', 'amount', 'fee']);
    final discount = _readDouble(json, [
      'discount',
      'discountPercent',
      'discountPercentage',
    ]);
    final status = _readString(json, ['status'], fallback: 'Draft');
    final certificateEnabled = _readBool(json, [
      'certificateEnabled',
      'certificateOnCompletion',
      'certificate',
    ]);
    final thumbnailUrl = _readString(json, [
      'thumbnail',
      'thumbnailUrl',
      'image',
    ]);
    final isArchived = _readBool(json, ['archived', 'isArchived']);
    var subjectCount = _readInt(json, [
      'subjectsCount',
      'subjectCount',
      'totalSubjects',
    ]);
    var teacherCount = _readInt(json, [
      'teachersCount',
      'teacherCount',
      'totalTeachers',
    ]);
    var enrolledCount = _readInt(json, [
      'enrolledCount',
      'enrollmentCount',
      'enrollmentsCount',
      'enrollments',
      'totalEnrollments',
      'studentsCount',
      'studentCount',
      'totalStudents',
      'totalLearners',
      'enrolledStudents',
      'enrolledUsers',
      'enrolled',
    ]);
    subjectCount = _resolveSubjectCount(json, subjectCount);
    teacherCount = _resolveTeacherCount(json, teacherCount);
    enrolledCount = _resolveEnrollmentCount(json, enrolledCount);

    return AdminCourse(
      id: id,
      title: title,
      shortDescription: shortDescription,
      description: description,
      category: category,
      level: level,
      price: price,
      discount: discount,
      status: status,
      certificateEnabled: certificateEnabled,
      thumbnailUrl: thumbnailUrl,
      subjectCount: subjectCount,
      teacherCount: teacherCount,
      enrolledCount: enrolledCount,
      isArchived: isArchived,
    );
  }

  AdminCourse copyWith({
    String? id,
    String? title,
    String? shortDescription,
    String? description,
    String? category,
    String? level,
    double? price,
    double? discount,
    String? status,
    bool? certificateEnabled,
    String? thumbnailUrl,
    int? subjectCount,
    int? teacherCount,
    int? enrolledCount,
    bool? isArchived,
  }) {
    return AdminCourse(
      id: id ?? this.id,
      title: title ?? this.title,
      shortDescription: shortDescription ?? this.shortDescription,
      description: description ?? this.description,
      category: category ?? this.category,
      level: level ?? this.level,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      status: status ?? this.status,
      certificateEnabled: certificateEnabled ?? this.certificateEnabled,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      subjectCount: subjectCount ?? this.subjectCount,
      teacherCount: teacherCount ?? this.teacherCount,
      enrolledCount: enrolledCount ?? this.enrolledCount,
      isArchived: isArchived ?? this.isArchived,
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

bool _readBool(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
        return true;
      }
      if (normalized == 'false' || normalized == '0' || normalized == 'no') {
        return false;
      }
    }
  }
  return false;
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

int _resolveSubjectCount(Map<String, dynamic> json, int fallback) {
  if (fallback > 0) return fallback;
  final candidates = [
    json['subjects'],
    json['subjectList'],
    json['courseSubjects'],
    json['subjectsData'],
    json['subjectData'],
  ];
  for (final candidate in candidates) {
    final count = _countList(candidate);
    if (count > 0) return count;
  }
  return fallback;
}

int _resolveTeacherCount(Map<String, dynamic> json, int fallback) {
  if (fallback > 0) return fallback;
  final directLists = [
    json['teachers'],
    json['teacherList'],
    json['teacherIds'],
  ];
  for (final candidate in directLists) {
    final count = _countList(candidate);
    if (count > 0) return count;
  }
  final subjects = json['subjects'] ?? json['subjectList'];
  if (subjects is List) {
    final ids = <String>{};
    for (final item in subjects) {
      if (item is Map) {
        final teacherId =
            item['teacherId'] ??
            item['teacher_id'] ??
            item['teacher'] ??
            item['teacherUid'];
        if (teacherId != null) {
          ids.add(teacherId.toString());
        }
        final teacher = item['teacher'];
        if (teacher is Map) {
          final nestedId =
              teacher['id'] ??
              teacher['_id'] ??
              teacher['uid'] ??
              teacher['userId'];
          if (nestedId != null) {
            ids.add(nestedId.toString());
          }
        }
      }
    }
    if (ids.isNotEmpty) return ids.length;
  }
  return fallback;
}

int _resolveEnrollmentCount(Map<String, dynamic> json, int fallback) {
  if (fallback > 0) return fallback;
  final candidates = [
    json['enrolled'],
    json['students'],
    json['enrollments'],
    json['studentList'],
    json['learners'],
    json['enrolledStudents'],
    json['enrolledUsers'],
  ];
  for (final candidate in candidates) {
    final count = _countList(candidate);
    if (count > 0) return count;
  }
  final stats = json['stats'];
  if (stats is Map<String, dynamic>) {
    final count = _readInt(stats, [
      'enrolledCount',
      'enrollmentCount',
      'enrollmentsCount',
      'totalEnrollments',
      'studentsCount',
      'studentCount',
      'totalStudents',
      'totalLearners',
      'enrolledStudents',
      'enrolledUsers',
    ]);
    if (count > 0) return count;
  }
  final summary = json['summary'];
  if (summary is Map<String, dynamic>) {
    final count = _readInt(summary, [
      'enrolledCount',
      'enrollmentCount',
      'enrollmentsCount',
      'totalEnrollments',
      'studentsCount',
      'studentCount',
      'totalStudents',
      'totalLearners',
    ]);
    if (count > 0) return count;
  }
  final analytics = json['analytics'];
  if (analytics is Map<String, dynamic>) {
    final count = _readInt(analytics, [
      'enrolledCount',
      'enrollmentCount',
      'enrollmentsCount',
      'totalEnrollments',
      'studentsCount',
      'studentCount',
      'totalStudents',
      'totalLearners',
    ]);
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
