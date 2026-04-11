class StudentTest {
  final String id;
  final String title;
  final String description;
  final String scope;
  final String classId;
  final String className;
  final DateTime? startAt;
  final DateTime? endAt;
  final int durationMinutes;
  final bool isAttempted;
  final double? scorePercent;

  const StudentTest({
    required this.id,
    required this.title,
    required this.description,
    required this.scope,
    required this.classId,
    required this.className,
    required this.startAt,
    required this.endAt,
    required this.durationMinutes,
    required this.isAttempted,
    required this.scorePercent,
  });

  bool get isActiveNow {
    final now = DateTime.now();
    final start = startAt;
    final end = endAt;
    // Strict: test is attemptable only within [startAt, endAt].
    if (start == null || end == null) return false;
    if (now.isBefore(start)) return false;
    if (now.isAfter(end)) return false;
    return true;
  }

  bool get isUpcoming {
    final start = startAt;
    if (start == null) return false;
    return DateTime.now().isBefore(start);
  }

  bool get isEnded {
    final end = endAt;
    if (end == null) return false;
    return DateTime.now().isAfter(end);
  }

  factory StudentTest.fromJson(Map<String, dynamic> json) {
    final source = _unwrapMap(json);
    final id = _readString(source, const ['id', '_id', 'testId']);
    final title = _readString(source, const ['title', 'name']);
    final description = _readString(source, const ['description', 'details']);
    final scope = _readString(source, const ['scope', 'type']);
    final classId = _readString(source, const ['classId', 'class_id']);
    final className = _readString(source, const ['className', 'classTitle']);
    final startAt = _readDateTime(source, const ['startAt', 'startsAt', 'start']);
    final endAt = _readDateTime(source, const ['endAt', 'endsAt', 'end']);
    final durationMinutes = _readInt(source, const ['durationMinutes', 'duration']);

    final attemptMap = _readMap(source, const ['attempt', 'currentAttempt', 'myAttempt']);
    final attemptedFlag = _readBool(source, const ['isAttempted', 'attempted']) ??
        _readBool(attemptMap ?? const {}, const ['isAttempted', 'attempted', 'finished']) ??
        false;

    final scorePercentValue = _readDouble(source, const ['scorePercent', 'percent']) > 0
        ? _readDouble(source, const ['scorePercent', 'percent'])
        : _readDouble(attemptMap ?? const {}, const ['scorePercent', 'percent']);
    final normalizedScore = scorePercentValue <= 0
        ? null
        : (scorePercentValue > 1 ? (scorePercentValue / 100) : scorePercentValue).clamp(0.0, 1.0);

    return StudentTest(
      id: id,
      title: title,
      description: description,
      scope: scope,
      classId: classId,
      className: className,
      startAt: startAt,
      endAt: endAt,
      durationMinutes: durationMinutes,
      isAttempted: attemptedFlag,
      scorePercent: normalizedScore,
    );
  }
}

class StudentTestDetail {
  final StudentTest test;
  final int currentQuestionNumber;
  final int totalQuestions;
  final StudentTestQuestion? currentQuestion;
  final DateTime? attemptStartedAt;
  final bool isFinished;

  const StudentTestDetail({
    required this.test,
    required this.currentQuestionNumber,
    required this.totalQuestions,
    required this.currentQuestion,
    required this.attemptStartedAt,
    required this.isFinished,
  });

  factory StudentTestDetail.fromJson(Map<String, dynamic> json) {
    final source = _unwrapMap(json);
    final data = source['data'];
    final payload = data is Map ? Map<String, dynamic>.from(data) : source;

    final testMap = _readMap(payload, const ['test', 'meta', 'metadata']) ?? payload;
    final test = StudentTest.fromJson(testMap);

    final questions = payload['questions'];
    final totalQuestions = questions is List ? questions.length : _readInt(payload, const ['totalQuestions', 'questionsCount']);

    final currentNumber = _readInt(payload, const ['currentQuestionNumber', 'questionNumber', 'currentIndex']);
    final currentQuestionMap = _readMap(payload, const ['currentQuestion', 'question']);
    final currentQuestion = currentQuestionMap == null
        ? null
        : StudentTestQuestion.fromJson(currentQuestionMap);

    final attemptMap = _readMap(payload, const ['attempt', 'currentAttempt']);
    final attemptStartedAt = attemptMap == null
        ? null
        : _readDateTime(attemptMap, const ['startedAt', 'startAt', 'createdAt']);
    final isFinished = _readBool(payload, const ['isFinished', 'finished']) ??
        _readBool(attemptMap ?? const {}, const ['isFinished', 'finished']) ??
        false;

    return StudentTestDetail(
      test: test,
      currentQuestionNumber: currentNumber > 0 ? currentNumber : (currentQuestion == null ? 0 : 1),
      totalQuestions: totalQuestions,
      currentQuestion: currentQuestion,
      attemptStartedAt: attemptStartedAt,
      isFinished: isFinished,
    );
  }
}

class StudentTestQuestion {
  final String id;
  final String text;
  final List<String> options;

  const StudentTestQuestion({
    required this.id,
    required this.text,
    required this.options,
  });

  factory StudentTestQuestion.fromJson(Map<String, dynamic> json) {
    final source = _unwrapMap(json);
    final id = _readString(source, const ['id', '_id', 'questionId']);
    final text = _readString(source, const ['questionText', 'question', 'text']);

    final options = <String>[];
    for (final key in const ['optionA', 'optionB', 'optionC', 'optionD']) {
      final value = source[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) options.add(text);
    }
    final list = source['options'];
    if (options.isEmpty && list is List) {
      for (final item in list) {
        final value = item?.toString().trim() ?? '';
        if (value.isNotEmpty) options.add(value);
      }
    }

    return StudentTestQuestion(
      id: id,
      text: text,
      options: options,
    );
  }
}

List<StudentTest> parseStudentTests(dynamic data) {
  if (data is List) {
    return data
        .whereType<Map>()
        .map((item) => StudentTest.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.id.trim().isNotEmpty)
        .toList();
  }
  if (data is Map) {
    final map = Map<String, dynamic>.from(data);
    final list = map['data'] ?? map['items'] ?? map['tests'] ?? map['results'];
    return parseStudentTests(list);
  }
  return const [];
}

Map<String, dynamic> _unwrapMap(Map<String, dynamic> source) {
  final data = source['data'];
  if (data is Map) return Map<String, dynamic>.from(data);
  return source;
}

Map<String, dynamic>? _readMap(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is Map) return Map<String, dynamic>.from(value);
  }
  return null;
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

DateTime? _readDateTime(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value == null) continue;
    if (value is DateTime) return value;
    if (value is String) {
      final parsed = DateTime.tryParse(value.trim());
      if (parsed != null) {
        // Normalize to local so schedule gating and UI match device time.
        return parsed.isUtc ? parsed.toLocal() : parsed;
      }
    }
    if (value is num) {
      final intValue = value.toInt();
      if (intValue > 100000000000) {
        return DateTime.fromMillisecondsSinceEpoch(intValue).toLocal();
      }
      if (intValue > 1000000000) {
        return DateTime.fromMillisecondsSinceEpoch(intValue * 1000).toLocal();
      }
    }
  }
  return null;
}
