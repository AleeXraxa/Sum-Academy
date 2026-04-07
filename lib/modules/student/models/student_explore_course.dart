class StudentExploreCourse {
  final String id;
  final String title;
  final String category;
  final String level;
  final String code;
  final String teacher;
  final double price;
  final double discount;
  final int enrolledCount;
  final int coursesCount;
  final int paidCourses;
  final String thumbnailUrl;
  final bool isEnrolled;
  final String status;
  final bool canEnroll;
  final bool canLearn;
  final bool isFullyEnrolled;
  final bool isPartiallyEnrolled;
  final double totalPrice;
  final double remainingPrice;
  final int spotsLeft;
  final int shiftsCount;
  final int daysToStart;
  final List<StudentExploreSubject> subjects;

  const StudentExploreCourse({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    required this.code,
    required this.teacher,
    required this.price,
    required this.discount,
    required this.enrolledCount,
    required this.coursesCount,
    required this.paidCourses,
    required this.thumbnailUrl,
    required this.isEnrolled,
    this.status = '',
    this.canEnroll = true,
    this.canLearn = false,
    this.isFullyEnrolled = false,
    this.isPartiallyEnrolled = false,
    this.totalPrice = 0,
    this.remainingPrice = 0,
    this.spotsLeft = 0,
    this.shiftsCount = 0,
    this.daysToStart = 0,
    this.subjects = const [],
  });

  StudentExploreCourse copyWith({
    String? id,
    String? title,
    String? category,
    String? level,
    String? code,
    String? teacher,
    double? price,
    double? discount,
    int? enrolledCount,
    int? coursesCount,
    int? paidCourses,
    String? thumbnailUrl,
    bool? isEnrolled,
    String? status,
    bool? canEnroll,
    bool? canLearn,
    bool? isFullyEnrolled,
    bool? isPartiallyEnrolled,
    double? totalPrice,
    double? remainingPrice,
    int? spotsLeft,
    int? shiftsCount,
    int? daysToStart,
    List<StudentExploreSubject>? subjects,
  }) {
    return StudentExploreCourse(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      level: level ?? this.level,
      code: code ?? this.code,
      teacher: teacher ?? this.teacher,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      enrolledCount: enrolledCount ?? this.enrolledCount,
      coursesCount: coursesCount ?? this.coursesCount,
      paidCourses: paidCourses ?? this.paidCourses,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      status: status ?? this.status,
      canEnroll: canEnroll ?? this.canEnroll,
      canLearn: canLearn ?? this.canLearn,
      isFullyEnrolled: isFullyEnrolled ?? this.isFullyEnrolled,
      isPartiallyEnrolled: isPartiallyEnrolled ?? this.isPartiallyEnrolled,
      totalPrice: totalPrice ?? this.totalPrice,
      remainingPrice: remainingPrice ?? this.remainingPrice,
      spotsLeft: spotsLeft ?? this.spotsLeft,
      shiftsCount: shiftsCount ?? this.shiftsCount,
      daysToStart: daysToStart ?? this.daysToStart,
      subjects: subjects ?? this.subjects,
    );
  }
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
    final list = _readList(data, const [
      'courses',
      'classes',
      'data',
      'items',
      'results',
    ]);
    if (list != null) {
      return parseExploreCourses(list);
    }
  }

  return const [];
}

StudentExploreCourse _courseFromMap(Map<String, dynamic> map) {
  final title = _readString(map, const [
    'className',
    'classTitle',
    'batchName',
    'name',
    'title',
    'courseTitle',
  ]);
  final category = _readString(map, const [
    'category',
    'categoryName',
    'track',
    'program',
    'board',
  ]);
  final level = _readString(map, const ['level', 'difficulty', 'grade']);
  final code = _readString(map, const [
    'classCode',
    'batchCode',
    'code',
    'classRef',
    'reference',
  ]);
  final teacher = _readString(map, const [
    'teacher',
    'teacherName',
    'mentor',
    'instructor',
    'classTeacher',
  ]);
  final price = _readDouble(map, const [
    'price',
    'amount',
    'fee',
    'classFee',
    'totalFee',
  ]);
  final discount = _readDouble(map, const [
    'discount',
    'discountPercent',
    'discountPercentage',
  ]);
  final status = _readString(map, const ['classStatus', 'status', 'state']);
  final canEnrollRaw = _readBool(map, const ['canEnroll']);
  final normalizedStatus = status.trim().toLowerCase();
  final statusBlocksEnroll =
      normalizedStatus == 'full' || normalizedStatus == 'expired';
  final canEnroll = canEnrollRaw ?? (!statusBlocksEnroll);
  final canLearn = _readBool(map, const ['canLearn']) ?? false;
  final isFullyEnrolled =
      _readBool(map, const ['isFullyEnrolled', 'fullyEnrolled']) ?? false;
  final isPartiallyEnrolled =
      _readBool(map, const ['isPartiallyEnrolled', 'partiallyEnrolled']) ??
      false;
  final totalPrice = _readDouble(map, const [
    'totalPrice',
    'fullPrice',
    'totalFee',
    'classTotalFee',
  ]);
  final remainingPrice = _readDouble(map, const [
    'remainingPrice',
    'remainingAmount',
    'payableAmount',
    'remainingFee',
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
  final capacity = _readInt(map, const [
    'capacity',
    'seats',
    'studentLimit',
    'maxStudents',
  ]);
  final coursesCount = _readInt(map, const [
    'subjectsCount',
    'totalSubjects',
    'coursesCount',
    'totalCourses',
    'courseCount',
    'totalCourseCount',
  ]);
  final paidCourses = _readInt(map, const [
    'paidCourses',
    'paidCoursesCount',
    'purchasedCourses',
    'paidCount',
  ]);
  final rawCourses = _readList(map, const [
    'courses',
    'classCourses',
    'assignedSubjects',
    'subjects',
  ]);
  final subjects = _readSubjects(map);
  final purchasedCount = _resolvePurchasedSubjectsCount(map, subjects);
  final unpurchasedList = _readList(map, const [
    'unpurchasedSubjects',
    'remainingSubjects',
    'unpaidSubjects',
  ]);
  final computedCoursesCount = coursesCount > 0
      ? coursesCount
      : (subjects.isNotEmpty
            ? subjects.length
            : (unpurchasedList?.length ?? 0) + purchasedCount);
  final computedPaidCourses = paidCourses > 0 ? paidCourses : purchasedCount;
  final spotsLeft = _readInt(map, const ['spotsLeft', 'availableSpots']);
  final resolvedSpotsLeft = spotsLeft > 0
      ? spotsLeft
      : (capacity > 0 ? capacity - enrolledCount : 0);
  final shiftList = _readList(map, const [
    'shifts',
    'shiftList',
    'classShifts',
  ]);
  final shiftsCount = _readInt(map, const ['shiftsCount', 'shiftCount']);
  final daysToStart = _readInt(map, const [
    'daysToStart',
    'daysLeftToStart',
    'startInDays',
    'daysUntilStart',
  ]);
  final resolvedShiftsCount = shiftsCount > 0
      ? shiftsCount
      : (shiftList?.length ?? 0);
  final subjectsTotal = subjects.fold<double>(
    0,
    (sum, subject) =>
        sum +
        (subject.discountedPrice > 0 ? subject.discountedPrice : subject.price),
  );
  final resolvedTotalPrice = totalPrice > 0
      ? totalPrice
      : (price > 0
            ? price
            : (subjectsTotal > 0 ? subjectsTotal : remainingPrice));
  final unpurchasedTotal = subjects
      .where((subject) => !subject.alreadyPurchased)
      .fold<double>(
        0,
        (sum, subject) =>
            sum +
            (subject.discountedPrice > 0
                ? subject.discountedPrice
                : subject.price),
      );
  final resolvedRemainingPrice = remainingPrice > 0
      ? remainingPrice
      : (unpurchasedTotal > 0 ? unpurchasedTotal : resolvedTotalPrice);
  final isEnrolled = isFullyEnrolled || isPartiallyEnrolled
      ? true
      : _resolveIsEnrolled(map);

  return StudentExploreCourse(
    id: _readString(map, const ['id', '_id', 'courseId', 'classId', 'batchId']),
    title: title,
    category: category,
    level: level,
    code: code,
    teacher: teacher,
    price: resolvedTotalPrice,
    discount: discount,
    enrolledCount: enrolledCount,
    coursesCount: computedCoursesCount,
    paidCourses: computedPaidCourses,
    thumbnailUrl: thumbnailUrl,
    isEnrolled: isEnrolled,
    status: status,
    canEnroll: canEnroll,
    canLearn: canLearn,
    isFullyEnrolled: isFullyEnrolled,
    isPartiallyEnrolled: isPartiallyEnrolled,
    totalPrice: resolvedTotalPrice,
    remainingPrice: resolvedRemainingPrice,
    spotsLeft: resolvedSpotsLeft < 0 ? 0 : resolvedSpotsLeft,
    shiftsCount: resolvedShiftsCount,
    daysToStart: daysToStart,
    subjects: subjects,
  );
}

class StudentExploreSubject {
  final String id;
  final String title;
  final double price;
  final double discountPercent;
  final double discountedPrice;
  final bool alreadyPurchased;

  const StudentExploreSubject({
    required this.id,
    required this.title,
    required this.price,
    required this.discountPercent,
    required this.discountedPrice,
    required this.alreadyPurchased,
  });

  factory StudentExploreSubject.fromMap(Map<String, dynamic> map) {
    final price = _readDouble(map, const [
      'price',
      'originalPrice',
      'amount',
      'fee',
    ]);
    final discountPercent = _readDouble(map, const [
      'discountPercent',
      'discount',
      'discountPercentage',
    ]);
    final discountedPrice = _readDouble(map, const [
      'discountedPrice',
      'finalPrice',
      'salePrice',
      'priceAfterDiscount',
      'payableAmount',
    ]);
    final computedDiscounted = discountedPrice > 0
        ? discountedPrice
        : (discountPercent > 0 ? price * (1 - discountPercent / 100) : price);
    final alreadyPurchased =
        _readBool(map, const [
          'alreadyPurchased',
          'purchased',
          'isPurchased',
          'paid',
          'isPaid',
        ]) ??
        false;
    return StudentExploreSubject(
      id: _readString(map, const ['subjectId', 'courseId', 'id', '_id']),
      title: _readString(map, const [
        'title',
        'name',
        'subjectName',
        'courseName',
      ]),
      price: price,
      discountPercent: discountPercent,
      discountedPrice: computedDiscounted,
      alreadyPurchased: alreadyPurchased,
    );
  }
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
    'isClassEnrolled',
    'classEnrolled',
    'isPurchased',
    'purchased',
    'hasAccess',
    'accessGranted',
    'isAccessGranted',
    'hasClassAccess',
    'owned',
  ]);
  if (direct != null) return direct;

  final nested = _readNestedBool(map, const [
    'isEnrolled',
    'enrolled',
    'isClassEnrolled',
    'classEnrolled',
    'isPurchased',
    'purchased',
    'hasAccess',
    'accessGranted',
    'isAccessGranted',
    'hasClassAccess',
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

List<StudentExploreSubject> _readSubjects(Map<String, dynamic> map) {
  final raw = _readList(map, const [
    'assignedSubjects',
    'subjects',
    'courses',
    'classCourses',
  ]);
  if (raw == null) return const [];
  return raw
      .whereType<Map>()
      .map(
        (item) =>
            StudentExploreSubject.fromMap(Map<String, dynamic>.from(item)),
      )
      .where((item) => item.title.trim().isNotEmpty)
      .toList();
}

int _resolvePurchasedSubjectsCount(
  Map<String, dynamic> map,
  List<StudentExploreSubject> subjects,
) {
  final purchased = _readList(map, const [
    'purchasedSubjects',
    'paidSubjects',
    'paidCourses',
    'paidCoursesList',
  ]);
  if (purchased != null) return purchased.length;
  final count = _readInt(map, const [
    'purchasedSubjectsCount',
    'paidSubjectsCount',
  ]);
  if (count > 0) return count;
  if (subjects.isEmpty) return 0;
  return subjects.where((subject) => subject.alreadyPurchased).length;
}

int _readListCount(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is List) return value.length;
  return 0;
}
