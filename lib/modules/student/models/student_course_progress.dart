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
    var progress = _normalizeProgress(
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
      if (progress == 0 && totalLectures > 0 && completedLectures > 0) {
        progress = (completedLectures / totalLectures).clamp(0.0, 1.0);
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
  final String id;
  final String title;
  final String duration;
  final bool isCompleted;
  final double progress;
  final String videoUrl;
  final String videoMode;
  final bool isLiveSession;
  final DateTime? joinOpensAt;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool isLocked;
  final bool canRewatch;
  final bool lockAfterCompletion;
  final String lockReason;

  const StudentCourseLecture({
    required this.id,
    required this.title,
    required this.duration,
    required this.isCompleted,
    required this.progress,
    required this.videoUrl,
    required this.videoMode,
    required this.isLiveSession,
    this.joinOpensAt,
    this.startsAt,
    this.endsAt,
    required this.isLocked,
    required this.canRewatch,
    required this.lockAfterCompletion,
    required this.lockReason,
  });

  bool get shouldShowInLiveSessionsTab {
    if (!isLiveSession) return false;
    final end = endsAt;
    if (end == null) return true;
    return end.isAfter(DateTime.now());
  }

  bool get isCurrentlyLive {
    if (!isLiveSession) return false;
    final now = DateTime.now();
    final start = startsAt;
    final end = endsAt;
    if (start == null || end == null) return false;
    return now.isAfter(start) && now.isBefore(end);
  }
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
  const accessMapKeys = [
    'access',
    'videoAccess',
    'rewatchAccess',
    'rewatch',
    'unlock',
    'unlockAccess',
    'enrollment',
    'courseAccess',
    'studentAccess',
  ];
  const accessValueKeys = [
    'unlocked',
    'isUnlocked',
    'canRewatch',
    'rewatchAllowed',
    'allowRewatch',
    'rewatchUnlocked',
    'unlockedForRewatch',
    'lockAfterCompletion',
    'lock_after_completion',
    'lockAfterComplete',
    'lockOnComplete',
    'lockAfter',
    'isLocked',
    'locked',
    'isAccessLocked',
    'accessLocked',
    'isBlocked',
    'blocked',
    'hasAccess',
    'canAccess',
    'isAccessible',
  ];
  final rootAccessMap =
      _readMap(root, accessMapKeys) ?? _readNestedMap(root, accessValueKeys);
  final rootUnlockFlag = _readBool(root, const [
    'unlocked',
    'isUnlocked',
    'canRewatch',
    'rewatchAllowed',
    'allowRewatch',
    'rewatchAccess',
    'rewatchUnlocked',
    'unlockedForRewatch',
  ]) ??
      _readBool(rootAccessMap, const [
        'unlocked',
        'isUnlocked',
        'canRewatch',
        'rewatchAllowed',
        'allowRewatch',
        'rewatchUnlocked',
        'unlockedForRewatch',
      ]);
  final rootLockAfterCompletion = _readBool(root, const [
    'lockAfterCompletion',
    'lock_after_completion',
    'lockAfterComplete',
    'lockOnComplete',
    'lockAfter',
  ]) ??
      _readBool(rootAccessMap, const [
        'lockAfterCompletion',
        'lock_after_completion',
        'lockAfterComplete',
        'lockOnComplete',
        'lockAfter',
      ]);
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
      final lectureAccessMap = _readMap(lectureMap, accessMapKeys) ??
          _readNestedMap(lectureMap, accessValueKeys);
      final title = _readString(lectureMap, const [
        'title',
        'name',
        'lectureTitle',
        'contentTitle',
        'lessonTitle',
      ]);
      if (title.isEmpty) continue;
      final id = _readString(lectureMap, const [
        'lectureId',
        'lecture_id',
        'contentId',
        'content_id',
        'id',
        '_id',
      ]);
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
      final currentTimeSec = _readDouble(lectureMap, const [
        'currentTimeSec',
        'current_time_sec',
        'currentTime',
      ]);
      final durationSec = _readDouble(lectureMap, const [
        'durationSec',
        'duration_sec',
        'totalTimeSec',
        'totalDurationSec',
      ]);
      final computedProgress = (progress > 0 || durationSec <= 0)
          ? progress
          : _normalizeProgress(currentTimeSec / durationSec);
      final videoUrl = _readString(lectureMap, const [
        'videoUrl',
        'videoURL',
        'url',
        'video',
        'streamUrl',
      ]);
      final videoMode = _readString(lectureMap, const [
        'videoMode',
        'mode',
        'type',
      ]);
      final isLiveSession = _readBool(lectureMap, const [
            'isLiveSession',
            'isLive',
            'live',
          ]) ??
          false;
      final scheduleMap = _readMap(lectureMap, const [
        'liveSession',
        'schedule',
        'session',
        'live',
      ]);
      final joinOpensAt = _readDateTime(lectureMap, const [
            'joinOpensAt',
            'joinOpenAt',
            'joinOpens',
          ]) ??
          (scheduleMap == null
              ? null
              : _readDateTime(scheduleMap, const [
                  'joinOpensAt',
                  'joinOpenAt',
                  'joinOpens',
                ]));
      final startsAt = _readDateTime(lectureMap, const [
            'startsAt',
            'startAt',
            'startTime',
          ]) ??
          (scheduleMap == null
              ? null
              : _readDateTime(scheduleMap, const [
                  'startsAt',
                  'startAt',
                  'startTime',
                ]));
      final endsAt = _readDateTime(lectureMap, const [
            'endsAt',
            'endAt',
            'endTime',
          ]) ??
          (scheduleMap == null
              ? null
              : _readDateTime(scheduleMap, const [
                  'endsAt',
                  'endAt',
                  'endTime',
                ]));
      final lockReason = _readString(lectureMap, const [
        'lockReason',
        'lockedReason',
        'lockMessage',
        'reason',
      ]);
      final lockAfterCompletion = _readBool(lectureMap, const [
            'lockAfterCompletion',
            'lock_after_completion',
            'lockAfterComplete',
            'lockOnComplete',
            'lockAfter',
          ]) ??
          _readBool(lectureAccessMap, const [
            'lockAfterCompletion',
            'lock_after_completion',
            'lockAfterComplete',
            'lockOnComplete',
            'lockAfter',
          ]) ??
          rootLockAfterCompletion ??
          true;
      final accessFlag = _readBool(lectureMap, const [
        'hasAccess',
        'canAccess',
        'isAccessible',
      ]) ??
          _readBool(lectureAccessMap, const [
            'hasAccess',
            'canAccess',
            'isAccessible',
          ]) ??
          _readBool(rootAccessMap, const [
            'hasAccess',
            'canAccess',
            'isAccessible',
          ]);
      final unlockFlag = _readBool(lectureMap, const [
        'unlocked',
        'isUnlocked',
        'canRewatch',
        'rewatchAllowed',
        'allowRewatch',
      ]) ??
          _readBool(lectureAccessMap, const [
            'unlocked',
            'isUnlocked',
            'canRewatch',
            'rewatchAllowed',
            'allowRewatch',
            'rewatchUnlocked',
            'unlockedForRewatch',
          ]) ??
          rootUnlockFlag;
      var isLocked = _readBool(lectureMap, const [
            'isLocked',
            'locked',
            'isAccessLocked',
            'accessLocked',
            'isBlocked',
            'blocked',
          ]) ??
          _readBool(lectureAccessMap, const [
            'isLocked',
            'locked',
            'isAccessLocked',
            'accessLocked',
            'isBlocked',
            'blocked',
          ]) ??
          _readBool(rootAccessMap, const [
            'isLocked',
            'locked',
            'isAccessLocked',
            'accessLocked',
            'isBlocked',
            'blocked',
          ]) ??
          false;
      final canRewatch = unlockFlag ?? false;
      if (isCompleted && lockAfterCompletion && !canRewatch) {
        isLocked = true;
      }
      if (accessFlag != null) {
        if (!accessFlag) {
          isLocked = true;
        } else if (accessFlag && !isLocked) {
          isLocked = false;
        }
      }
      if (unlockFlag == true) {
        isLocked = false;
      }
      if (!lockAfterCompletion && isCompleted && accessFlag != false) {
        isLocked = false;
      }
      lectures.add(
        StudentCourseLecture(
          id: id,
          title: title,
          duration: duration,
          isCompleted: isCompleted,
          progress: computedProgress,
          videoUrl: videoUrl,
          videoMode: videoMode,
          isLiveSession: isLiveSession,
          joinOpensAt: joinOpensAt,
          startsAt: startsAt,
          endsAt: endsAt,
          isLocked: isLocked,
          canRewatch: canRewatch,
          lockAfterCompletion: lockAfterCompletion,
          lockReason: lockReason,
        ),
      );
      continue;
    }
    if (raw is String) {
      final title = raw.trim();
      if (title.isEmpty) continue;
      lectures.add(
        StudentCourseLecture(
          id: '',
          title: title,
          duration: '',
          isCompleted: false,
          progress: 0,
          videoUrl: '',
          videoMode: '',
          isLiveSession: false,
          joinOpensAt: null,
          startsAt: null,
          endsAt: null,
          isLocked: false,
          canRewatch: false,
          lockAfterCompletion: true,
          lockReason: '',
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

DateTime? _readDateTime(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value == null) continue;
    if (value is DateTime) return value;
    if (value is String) {
      final parsed = DateTime.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
    if (value is int) {
      if (value > 100000000000) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      if (value > 1000000000) {
        return DateTime.fromMillisecondsSinceEpoch(value * 1000);
      }
    }
    if (value is num) {
      final intValue = value.toInt();
      if (intValue > 100000000000) {
        return DateTime.fromMillisecondsSinceEpoch(intValue);
      }
      if (intValue > 1000000000) {
        return DateTime.fromMillisecondsSinceEpoch(intValue * 1000);
      }
    }
  }
  return null;
}

bool? _readBool(Map<String, dynamic>? map, List<String> keys) {
  if (map == null) return null;
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

Map<String, dynamic>? _readMap(
  Map<String, dynamic>? map,
  List<String> keys,
) {
  if (map == null) return null;
  for (final key in keys) {
    final value = map[key];
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
  }
  return null;
}

Map<String, dynamic>? _readNestedMap(
  Map<String, dynamic> map,
  List<String> valueKeys,
) {
  for (final entry in map.entries) {
    final value = entry.value;
    if (value is Map) {
      final nested = Map<String, dynamic>.from(value);
      for (final key in valueKeys) {
        if (nested.containsKey(key)) {
          return nested;
        }
      }
    }
  }
  return null;
}
