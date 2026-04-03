class StudentExploreCourse {
  final String id;
  final String title;
  final String category;
  final String level;
  final double price;
  final double discount;
  final int enrolledCount;
  final String thumbnailUrl;
  final bool isEnrolled;

  const StudentExploreCourse({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    required this.price,
    required this.discount,
    required this.enrolledCount,
    required this.thumbnailUrl,
    required this.isEnrolled,
  });
}

List<StudentExploreCourse> parseExploreCourses(dynamic data) {
  if (data is List) {
    return data
        .whereType<Map<String, dynamic>>()
        .map(_courseFromMap)
        .where((course) => course.title.trim().isNotEmpty)
        .toList();
  }

  if (data is Map<String, dynamic>) {
    final list = _readList(data, const ['courses', 'data', 'items', 'results']);
    if (list != null) {
      return parseExploreCourses(list);
    }
  }

  return const [];
}

StudentExploreCourse _courseFromMap(Map<String, dynamic> map) {
  final title = _readString(map, const ['title', 'name', 'courseTitle']);
  final category = _readString(map, const ['category', 'categoryName']);
  final level = _readString(map, const ['level', 'difficulty']);
  final price = _readDouble(map, const ['price', 'amount', 'fee']);
  final discount = _readDouble(map, const [
    'discount',
    'discountPercent',
    'discountPercentage',
  ]);
  final thumbnailUrl = _readString(map, const [
    'thumbnail',
    'thumbnailUrl',
    'image',
  ]);
  final enrolledCount = _readInt(map, const [
    'enrolledCount',
    'enrollmentCount',
    'enrollments',
    'studentsCount',
    'studentCount',
    'totalStudents',
  ]);
  final isEnrolled = _resolveIsEnrolled(map);

  return StudentExploreCourse(
    id: _readString(map, const ['id', '_id', 'courseId']),
    title: title,
    category: category,
    level: level,
    price: price,
    discount: discount,
    enrolledCount: enrolledCount,
    thumbnailUrl: thumbnailUrl,
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
    final parsed = double.tryParse(value.toString());
    if (parsed != null) return parsed;
  }
  return 0;
}

int _readInt(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value == null) continue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    final parsed = int.tryParse(value.toString());
    if (parsed != null) return parsed;
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

bool _resolveIsEnrolled(Map<String, dynamic> map) {
  final direct = _readBool(map, const [
    'isEnrolled',
    'enrolled',
    'isPurchased',
    'purchased',
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

  final progress = _readNestedDouble(map, const [
    'progress',
    'completion',
    'completionPercent',
    'progressPercent',
  ]);
  if (progress != null && progress > 0) return true;

  return false;
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

List<dynamic>? _readList(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is List) return value;
  }
  return null;
}
