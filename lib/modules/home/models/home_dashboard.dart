import 'dart:ui';

import 'package:sum_academy/modules/home/models/course.dart';
import 'package:sum_academy/modules/home/models/live_session.dart';
import 'package:sum_academy/modules/student/models/student_course.dart';

class HomeDashboard {
  final String learnerName;
  final int enrolledCourses;
  final int completedCourses;
  final int certificatesEarned;
  final double attendancePercent;
  final int learningHours;
  final int learningStreakDays;
  final int learningDays;
  final DateTime? lastLoginAt;
  final bool isProfileComplete;
  final ActiveCourseInfo? activeCourse;
  final double weeklyGoalHours;
  final double weeklyProgressHours;
  final Course continueCourse;
  final List<Course> recentCourses;
  final List<LiveSession> liveSessions;
  final List<String> categories;
  final List<int> highlightedCategoryIndexes;

  const HomeDashboard({
    required this.learnerName,
    required this.enrolledCourses,
    required this.completedCourses,
    required this.certificatesEarned,
    required this.attendancePercent,
    required this.learningHours,
    required this.learningStreakDays,
    required this.learningDays,
    required this.lastLoginAt,
    required this.isProfileComplete,
    required this.activeCourse,
    required this.weeklyGoalHours,
    required this.weeklyProgressHours,
    required this.continueCourse,
    required this.recentCourses,
    required this.liveSessions,
    required this.categories,
    required this.highlightedCategoryIndexes,
  });

  factory HomeDashboard.empty() {
    return HomeDashboard(
      learnerName: '',
      enrolledCourses: 0,
      completedCourses: 0,
      certificatesEarned: 0,
      attendancePercent: 0,
      learningHours: 0,
      learningStreakDays: 0,
      learningDays: 0,
      lastLoginAt: null,
      isProfileComplete: true,
      activeCourse: null,
      weeklyGoalHours: 0,
      weeklyProgressHours: 0,
      continueCourse: Course(
        title: '',
        subtitle: '',
        duration: '',
        progress: 0,
        accent: Color(0x00000000),
        tags: const [],
      ),
      recentCourses: const [],
      liveSessions: const [],
      categories: const [],
      highlightedCategoryIndexes: const [],
    );
  }

  factory HomeDashboard.fromAny(dynamic data) {
    if (data is Map<String, dynamic>) {
      final name = _readString(data, const [
        'learnerName',
        'fullName',
        'name',
        'studentName',
        'userName',
        'displayName',
      ]);
      final learningStreakDays = _readInt(data, const [
        'learningStreakDays',
        'streakDays',
        'learningStreak',
        'streak',
      ]);
      final learningDays = _readInt(data, const [
        'learningDays',
        'daysLearned',
        'totalLearningDays',
        'learningDayCount',
      ]);
      final lastLoginAt = _readDateTime(data, const [
        'lastLoginAt',
        'lastLogin',
        'lastLoginDate',
        'lastLoginOn',
        'lastLoginTime',
      ]);
      final completion = _readDouble(data, const [
        'profileCompletion',
        'profileCompletionPercent',
        'profilePercent',
      ]);
      final profileCompleteFlag = _readBool(data, const [
        'profileComplete',
        'isProfileComplete',
        'profileCompleted',
        'setupDone',
        'profileSetupDone',
      ]);
      final isProfileComplete =
          profileCompleteFlag ??
          (completion == null ? true : completion >= 100);
      final activeCourse = _readActiveCourse(data);
      final recentCourses = _readCourses(data);

      return HomeDashboard(
        learnerName: name,
        enrolledCourses: _readInt(data, const [
          'enrolledCourses',
          'coursesEnrolled',
          'totalCourses',
          'courses',
          'enrolled',
        ]),
        completedCourses: _readInt(data, const [
          'completedCourses',
          'coursesCompleted',
          'completedCourseCount',
          'completed',
        ]),
        certificatesEarned: _readInt(data, const [
          'certificatesEarned',
          'certificateCount',
          'certificates',
        ]),
        attendancePercent: _readDouble(data, const [
          'attendancePercent',
          'attendance',
          'attendancePercentage',
        ]),
        learningHours: _readInt(data, const [
          'learningHours',
          'hoursLearned',
          'totalHours',
        ]),
        learningStreakDays: learningStreakDays,
        learningDays: learningDays > 0 ? learningDays : learningStreakDays,
        lastLoginAt: lastLoginAt,
        isProfileComplete: isProfileComplete,
        activeCourse: activeCourse,
        weeklyGoalHours: _readDouble(data, const [
          'weeklyGoalHours',
          'weeklyGoal',
          'goalHours',
        ]),
        weeklyProgressHours: _readDouble(data, const [
          'weeklyProgressHours',
          'weeklyProgress',
          'progressHours',
        ]),
        continueCourse: Course(
          title: '',
          subtitle: '',
          duration: '',
          progress: 0,
          accent: const Color(0x00000000),
          tags: const [],
        ),
        recentCourses: recentCourses,
        liveSessions: const [],
        categories: const [],
        highlightedCategoryIndexes: const [],
      );
    }

    return HomeDashboard.empty();
  }

  factory HomeDashboard.fromApi({
    required Map<String, dynamic> dashboard,
    List<dynamic> courses = const [],
    List<dynamic> certificates = const [],
    Map<String, dynamic> attendance = const {},
  }) {
    final merged = <String, dynamic>{
      ...dashboard,
      'courses': courses,
    };

    final base = HomeDashboard.fromAny(merged);
    final snapshots = _parseCourseSnapshots(courses);

    final enrolledCount =
        snapshots.isNotEmpty ? snapshots.length : base.enrolledCourses;
    final completedCount = snapshots.isNotEmpty
        ? snapshots.where((snap) => snap.isCompleted).length
        : base.completedCourses;
    final certCount = certificates.isNotEmpty
        ? _countList(certificates)
        : base.certificatesEarned;

    final attendancePercent = _resolveAttendancePercent(
      attendance,
      base.attendancePercent,
    );

    final activeCourse = _resolveActiveCourse(snapshots, base.activeCourse);
    final recentCourses =
        snapshots.isNotEmpty ? _buildRecentCourses(snapshots) : base.recentCourses;

    final resolvedName = base.learnerName.isNotEmpty
        ? base.learnerName
        : _readString(dashboard, const [
            'fullName',
            'name',
            'studentName',
            'displayName',
          ]);

    return HomeDashboard(
      learnerName: resolvedName,
      enrolledCourses: enrolledCount,
      completedCourses: completedCount,
      certificatesEarned: certCount,
      attendancePercent: attendancePercent,
      learningHours: base.learningHours,
      learningStreakDays: base.learningStreakDays,
      learningDays: base.learningDays,
      lastLoginAt: base.lastLoginAt,
      isProfileComplete: base.isProfileComplete,
      activeCourse: activeCourse,
      weeklyGoalHours: base.weeklyGoalHours,
      weeklyProgressHours: base.weeklyProgressHours,
      continueCourse: base.continueCourse,
      recentCourses: recentCourses,
      liveSessions: base.liveSessions,
      categories: base.categories,
      highlightedCategoryIndexes: base.highlightedCategoryIndexes,
    );
  }
}

class ActiveCourseInfo {
  final String title;
  final String teacher;
  final double progress;
  final String nextLecture;

  const ActiveCourseInfo({
    required this.title,
    required this.teacher,
    required this.progress,
    required this.nextLecture,
  });

  bool get isEmpty => title.trim().isEmpty;
}

class _CourseSnapshot {
  final String title;
  final String teacher;
  final String category;
  final double progress;
  final String status;
  final String nextLecture;

  const _CourseSnapshot({
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

String _readString(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = _readNestedValue(data, key);
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) {
      return text;
    }
  }
  return '';
}

bool? _readBool(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = _readNestedValue(data, key);
    final parsed = _parseBool(value);
    if (parsed != null) {
      return parsed;
    }
  }
  return null;
}

int _readInt(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = _readNestedValue(data, key);
    final parsed = _parseInt(value);
    if (parsed != null) {
      return parsed;
    }
  }
  return 0;
}

double _readDouble(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = _readNestedValue(data, key);
    final parsed = _parseDouble(value);
    if (parsed != null) {
      return parsed;
    }
  }
  return 0;
}

DateTime? _readDateTime(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = _readNestedValue(data, key);
    final parsed = _parseDateTime(value);
    if (parsed != null) {
      return parsed;
    }
  }
  return null;
}

dynamic _readNestedValue(Map<String, dynamic> data, String key) {
  if (data.containsKey(key)) {
    return data[key];
  }
  const nestedKeys = [
    'data',
    'dashboard',
    'summary',
    'stats',
    'profile',
    'student',
    'user',
  ];
  for (final nestedKey in nestedKeys) {
    final nested = data[nestedKey];
    if (nested is Map<String, dynamic> && nested.containsKey(key)) {
      return nested[key];
    }
  }
  return null;
}

ActiveCourseInfo? _readActiveCourse(Map<String, dynamic> data) {
  final map = _readMapForKeys(data, const [
    'activeCourse',
    'currentCourse',
    'continueCourse',
    'course',
  ]);

  if (map != null) {
    return _parseActiveCourse(map);
  }

  final title = _readString(data, const [
    'activeCourseTitle',
    'currentCourseTitle',
    'continueCourseTitle',
  ]);
  if (title.trim().isEmpty) {
    return null;
  }

  return _parseActiveCourse(data);
}

Map<String, dynamic>? _readMapForKeys(
  Map<String, dynamic> data,
  List<String> keys,
) {
  for (final key in keys) {
    final value = _readNestedValue(data, key);
    if (value is Map<String, dynamic>) {
      return value;
    }
  }
  return null;
}

ActiveCourseInfo _parseActiveCourse(Map<String, dynamic> source) {
  final title = _readString(source, const ['title', 'courseTitle', 'name']);
  final teacher = _readString(source, const [
    'teacher',
    'teacherName',
    'instructor',
    'instructorName',
    'mentor',
  ]);
  final nextLecture = _readString(source, const [
    'nextLecture',
    'nextLesson',
    'nextLectureTitle',
    'nextLessonTitle',
    'nextActivity',
    'nextContent',
  ]);
  final progressRaw = _readDouble(source, const [
    'progress',
    'completion',
    'completionPercent',
    'progressPercent',
    'percentComplete',
  ]);
  final progress = _normalizeProgress(progressRaw);

  return ActiveCourseInfo(
    title: title,
    teacher: teacher,
    progress: progress,
    nextLecture: nextLecture.isEmpty
        ? 'Resume from your last activity'
        : nextLecture,
  );
}

double _normalizeProgress(double value) {
  if (value <= 0) return 0;
  if (value <= 1) return value;
  return (value / 100).clamp(0.0, 1.0);
}

List<Course> _readCourses(Map<String, dynamic> data) {
  final list = _readListForKeys(data, const [
    'recentCourses',
    'myCourses',
    'courses',
    'enrolledCourses',
    'activeCourses',
  ]);
  if (list == null) {
    return const [];
  }
  return _parseCourseList(list);
}

List<dynamic>? _readListForKeys(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = _readNestedValue(data, key);
    if (value is List) {
      return value;
    }
  }
  return null;
}

List<Course> _parseCourseList(List<dynamic> items) {
  final colors = [
    const Color(0xFF4A63F5),
    const Color(0xFF7088FF),
    const Color(0xFFFF6F0F),
    const Color(0xFF3347E8),
  ];
  final courses = <Course>[];
  var colorIndex = 0;
  for (final raw in items) {
    if (raw is StudentCourse) {
      courses.add(
        Course(
          title: raw.title,
          subtitle: raw.teacher.isNotEmpty ? raw.teacher : raw.category,
          duration: '',
          progress: raw.progress,
          accent: colors[colorIndex % colors.length],
          tags: const [],
        ),
      );
      colorIndex += 1;
    } else if (raw is Map<String, dynamic>) {
      var title =
          _readString(raw, const ['title', 'name', 'courseTitle', 'courseName']);
      final id = _readString(raw, const ['courseId', 'course_id', 'id', '_id']);
      if (title.isEmpty && id.isNotEmpty) {
        title = 'Course $id';
      }
      if (title.isEmpty) {
        continue;
      }
      final subtitle = _readString(raw, const [
        'subtitle',
        'teacher',
        'teacherName',
        'instructor',
        'category',
      ]);
      final duration = _readString(raw, const [
        'duration',
        'totalDuration',
        'length',
      ]);
      final progressRaw = _readDouble(raw, const [
        'progress',
        'completion',
        'completionPercent',
        'progressPercent',
      ]);
      final progress = _normalizeProgress(progressRaw);
      final tags = _readStringList(raw, const ['tags', 'labels']);

      courses.add(
        Course(
          title: title,
          subtitle: subtitle,
          duration: duration,
          progress: progress,
          accent: colors[colorIndex % colors.length],
          tags: tags,
        ),
      );
      colorIndex += 1;
    }
  }
  return courses;
}

List<_CourseSnapshot> _parseCourseSnapshots(List<dynamic> items) {
  if (items.isEmpty) return const [];
  final snapshots = <_CourseSnapshot>[];
  for (final raw in items) {
    if (raw is StudentCourse) {
      snapshots.add(
        _CourseSnapshot(
          title: raw.title,
          teacher: raw.teacher,
          category: raw.category,
          progress: raw.progress,
          status: raw.status,
          nextLecture: raw.nextLecture,
        ),
      );
    } else if (raw is Map<String, dynamic>) {
      var title =
          _readString(raw, const ['title', 'name', 'courseTitle', 'courseName']);
      final id = _readString(raw, const ['courseId', 'course_id', 'id', '_id']);
      if (title.isEmpty && id.isNotEmpty) {
        title = 'Course $id';
      }
      if (title.isEmpty) continue;
      final teacher = _readString(
        raw,
        const ['teacher', 'teacherName', 'instructor', 'mentor'],
      );
      final category =
          _readString(raw, const ['category', 'subject', 'track']);
      final status = _readString(raw, const ['status', 'state', 'courseStatus']);
      final nextLecture = _readString(
        raw,
        const ['nextLecture', 'nextLesson', 'nextActivity', 'nextContent'],
      );
      final progress = _normalizeProgress(
        _readDouble(raw, const [
          'progress',
          'completion',
          'completionPercent',
          'progressPercent',
        ]),
      );
      snapshots.add(
        _CourseSnapshot(
          title: title,
          teacher: teacher,
          category: category,
          progress: progress,
          status: status,
          nextLecture: nextLecture,
        ),
      );
    }
  }
  return snapshots;
}

ActiveCourseInfo? _resolveActiveCourse(
  List<_CourseSnapshot> snapshots,
  ActiveCourseInfo? fallback,
) {
  if (snapshots.isEmpty) {
    return fallback;
  }

  snapshots.sort((a, b) => b.progress.compareTo(a.progress));
  final best = snapshots.first;

  return ActiveCourseInfo(
    title: best.title,
    teacher: best.teacher,
    progress: best.progress,
    nextLecture: best.nextLecture.isEmpty
        ? 'Resume from your last activity'
        : best.nextLecture,
  );
}

List<Course> _buildRecentCourses(List<_CourseSnapshot> snapshots) {
  final colors = [
    const Color(0xFF4A63F5),
    const Color(0xFF7088FF),
    const Color(0xFFFF6F0F),
    const Color(0xFF3347E8),
  ];
  final courses = <Course>[];
  var colorIndex = 0;
  for (final snap in snapshots) {
    courses.add(
      Course(
        title: snap.title,
        subtitle: snap.teacher.isNotEmpty ? snap.teacher : snap.category,
        duration: '',
        progress: snap.progress,
        accent: colors[colorIndex % colors.length],
        tags: const [],
      ),
    );
    colorIndex += 1;
  }
  return courses;
}

double _resolveAttendancePercent(
  Map<String, dynamic> attendance,
  double fallback,
) {
  if (attendance.isEmpty) return fallback;
  final summary = attendance['summary'];
  if (summary is Map) {
    final present = _parseInt(summary['present']);
    final absent = _parseInt(summary['absent']);
    if (present != null || absent != null) {
      final total = (present ?? 0) + (absent ?? 0);
      if (total > 0) {
        return (present ?? 0) / total * 100;
      }
    }
  }

  final classes = attendance['classes'];
  if (classes is List && classes.isNotEmpty) {
    final percentages = classes
        .whereType<Map>()
        .map((item) => _parseDouble(item['percentage']))
        .whereType<double>()
        .toList();
    if (percentages.isNotEmpty) {
      final sum = percentages.reduce((a, b) => a + b);
      return sum / percentages.length;
    }
  }

  final direct = _parseDouble(
    attendance['attendancePercent'] ??
        attendance['percentage'] ??
        attendance['attendance'],
  );
  return direct ?? fallback;
}

int _countList(List<dynamic> items) {
  return items.where((item) => item != null).length;
}

List<String> _readStringList(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = _readNestedValue(data, key);
    if (value is List) {
      return value
          .whereType<Object>()
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
  }
  return const [];
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
    for (final entry in value.entries) {
      final nested = _parseInt(entry.value);
      if (nested != null) return nested;
    }
  }
  return null;
}

bool? _parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final lower = value.trim().toLowerCase();
    if (lower == 'true' || lower == 'yes' || lower == '1') return true;
    if (lower == 'false' || lower == 'no' || lower == '0') return false;
  }
  return null;
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) {
    final cleaned = value.replaceAll(',', '').trim();
    return double.tryParse(cleaned);
  }
  if (value is Map) {
    for (final entry in value.entries) {
      final nested = _parseDouble(entry.value);
      if (nested != null) return nested;
    }
  }
  return null;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int || value is num) {
    final numVal = value is int ? value : value.toInt();
    final isMillis = numVal > 1000000000000;
    final millis = isMillis ? numVal : numVal * 1000;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }
  if (value is String) {
    final parsed = DateTime.tryParse(value.trim());
    if (parsed != null) return parsed;
  }
  if (value is Map) {
    final seconds = value['seconds'];
    if (seconds is int) {
      return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    }
  }
  return null;
}
