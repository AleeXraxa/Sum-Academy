class StudentCourseProgress {
  final String courseId;
  final double progress;
  final int completedLectures;
  final int totalLectures;
  final List<StudentCourseChapter> chapters;

  const StudentCourseProgress({
    required this.courseId,
    required this.progress,
    required this.completedLectures,
    required this.totalLectures,
    required this.chapters,
  });

  factory StudentCourseProgress.empty({String courseId = ''}) {
    return StudentCourseProgress(
      courseId: courseId,
      progress: 0,
      completedLectures: 0,
      totalLectures: 0,
      chapters: const [],
    );
  }

  bool get isEmpty => chapters.isEmpty && totalLectures == 0;

  factory StudentCourseProgress.fromAny(dynamic value) {
    if (value is Map<String, dynamic>) {
      return StudentCourseProgress.fromJson(value);
    }
    if (value is Map) {
      return StudentCourseProgress.fromJson(Map<String, dynamic>.from(value));
    }
    return StudentCourseProgress.empty();
  }

  factory StudentCourseProgress.fromJson(Map<String, dynamic> json) {
    final source = _unwrapMap(json);
    final courseId = _readString(source, const [
      'courseId',
      'course_id',
      'id',
      '_id',
    ]);
    final progress = _normalizeProgress(
      _readDouble(source, const [
        'progress',
        'completion',
        'completionPercent',
        'progressPercent',
      ]),
    );

    var completedLectures = _readInt(source, const [
      'completedLectures',
      'completed',
      'completedCount',
      'completedLecturesCount',
    ]);
    var totalLectures = _readInt(source, const [
      'totalLectures',
      'lecturesCount',
      'total',
      'totalCount',
    ]);

    var chapters = _parseChapters(source);
    if (chapters.isEmpty) {
      final lectures = _parseLectures(source, source);
      if (lectures.isNotEmpty) {
        chapters = [
          StudentCourseChapter(
            title: 'Lectures',
            lectures: lectures,
          ),
        ];
      }
    }

    if (chapters.isNotEmpty) {
      final computedTotal = chapters.fold<int>(
        0,
        (sum, chapter) => sum + chapter.lectures.length,
      );
      final computedCompleted = chapters.fold<int>(
        0,
        (sum, chapter) =>
            sum +
            chapter.lectures.where((lecture) => lecture.isCompleted).length,
      );
      if (totalLectures == 0) {
        totalLectures = computedTotal;
      }
      if (completedLectures == 0) {
        completedLectures = computedCompleted;
      }
    }

    return StudentCourseProgress(
      courseId: courseId,
      progress: progress,
      completedLectures: completedLectures,
      totalLectures: totalLectures,
      chapters: chapters,
    );
  }
}

class StudentCourseChapter {
  final String title;
  final List<StudentCourseLecture> lectures;

  const StudentCourseChapter({
    required this.title,
    required this.lectures,
  });
}

class StudentCourseLecture {
  final String title;
  final String duration;
  final bool isCompleted;
  final double progress;

  const StudentCourseLecture({
    required this.title,
    required this.duration,
    required this.isCompleted,
    required this.progress,
  });
}

List<StudentCourseChapter> _parseChapters(Map<String, dynamic> source) {
  final rawChapters = _readList(source, const [
    'chapters',
    'sections',
    'modules',
    'units',
  ]);
  if (rawChapters == null) {
    return const [];
  }

  final chapters = <StudentCourseChapter>[];
  var index = 1;
  for (final raw in rawChapters) {
    if (raw is Map) {
      final chapterMap = Map<String, dynamic>.from(raw);
      final title = _readString(
        chapterMap,
        const ['title', 'name', 'chapterTitle', 'sectionTitle'],
      );
      final lectures = _parseLectures(source, chapterMap);
      if (lectures.isEmpty && title.isEmpty) {
        index += 1;
        continue;
      }
      chapters.add(
        StudentCourseChapter(
          title: title.isEmpty ? 'Chapter $index' : title,
          lectures: lectures,
        ),
      );
      index += 1;
      continue;
    }
    if (raw is String) {
      chapters.add(
        StudentCourseChapter(
          title: raw.trim().isEmpty ? 'Chapter $index' : raw.trim(),
          lectures: const [],
        ),
      );
      index += 1;
    }
  }
  return chapters;
}

List<StudentCourseLecture> _parseLectures(
  Map<String, dynamic> root,
  Map<String, dynamic> source,
) {
  final rawLectures = _readList(source, const [
    'lectures',
    'lessons',
    'topics',
    'items',
    'contents',
  ]);
  if (rawLectures == null) {
    return const [];
  }
  final lectures = <StudentCourseLecture>[];
  for (final raw in rawLectures) {
    if (raw is Map) {
      final lectureMap = Map<String, dynamic>.from(raw);
      final title = _readString(lectureMap, const [
        'title',
        'name',
        'lectureTitle',
        'contentTitle',
        'lessonTitle',
      ]);
      if (title.isEmpty) continue;
      final duration = _readString(lectureMap, const [
        'duration',
        'length',
        'time',
      ]);
      final isCompleted = _readBool(lectureMap, const [
            'isCompleted',
            'completed',
            'done',
          ]) ??
          false;
      final progress = _normalizeProgress(
        _readDouble(lectureMap, const [
          'progress',
          'completion',
          'completionPercent',
          'percent',
          'watchedPercent',
        ]),
      );
      lectures.add(
        StudentCourseLecture(
          title: title,
          duration: duration,
          isCompleted: isCompleted,
          progress: progress,
        ),
      );
      continue;
    }
    if (raw is String) {
      final title = raw.trim();
      if (title.isEmpty) continue;
      lectures.add(
        StudentCourseLecture(
          title: title,
          duration: '',
          isCompleted: false,
          progress: 0,
        ),
      );
    }
  }
  return lectures;
}

Map<String, dynamic> _unwrapMap(Map<String, dynamic> source) {
  final data = source['data'];
  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  return source;
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

int _readInt(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value == null) continue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
  }
  return 0;
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
