import 'dart:ui';

import 'package:sum_academy/modules/home/models/course.dart';
import 'package:sum_academy/modules/home/models/live_session.dart';

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
    if (raw is Map<String, dynamic>) {
      final title = _readString(raw, const ['title', 'name', 'courseTitle']);
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
