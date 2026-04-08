class StudentQuizSummary {
  final String id;
  final String title;
  final String courseTitle;
  final String subject;
  final String status;
  final bool assigned;
  final int questionCount;
  final int totalMarks;
  final double scorePercent;

  const StudentQuizSummary({
    required this.id,
    required this.title,
    required this.courseTitle,
    required this.subject,
    required this.status,
    required this.assigned,
    required this.questionCount,
    required this.totalMarks,
    this.scorePercent = -1,
  });

  bool get isAvailable {
    if (isAttempted) return false;
    if (assigned) return true;
    final lower = status.toLowerCase();
    if (lower.contains('available') || lower.contains('assigned')) return true;
    return false;
  }

  bool get isAttempted {
    final lower = status.toLowerCase();
    return lower.contains('attempt') ||
        lower.contains('submitted') ||
        lower.contains('completed');
  }

  factory StudentQuizSummary.fromJson(Map<String, dynamic> json) {
    final totalMarks = _readInt(json, const [
      'totalMarks',
      'marks',
      'total',
      'totalScore',
    ]);
    final scorePercent = _resolveScorePercent(json, totalMarks);
    return StudentQuizSummary(
      id: _readString(json, const ['id', '_id', 'quizId']),
      title: _readString(json, const ['title', 'name']),
      courseTitle: _readString(json, const [
        'courseTitle',
        'course',
        'courseName',
        'className',
      ]),
      subject: _readString(json, const ['subject', 'topic']),
      status: _readString(json, const ['status', 'state']),
      assigned: _readBool(json, const ['assigned', 'isAssigned', 'available']),
      questionCount: _readInt(json, const [
        'questionCount',
        'questionsCount',
        'questions',
      ]),
      totalMarks: totalMarks,
      scorePercent: scorePercent,
    );
  }
}

class StudentQuizDetail {
  final String id;
  final String title;
  final List<StudentQuizQuestion> questions;

  const StudentQuizDetail({
    required this.id,
    required this.title,
    required this.questions,
  });

  factory StudentQuizDetail.fromJson(Map<String, dynamic> json) {
    final questions = _readList(json, const ['questions', 'items'])
        .whereType<Map>()
        .map(
          (item) => StudentQuizQuestion.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
    return StudentQuizDetail(
      id: _readString(json, const ['id', '_id', 'quizId']),
      title: _readString(json, const ['title', 'name']),
      questions: questions,
    );
  }
}

class StudentQuizQuestion {
  final String id;
  final String text;
  final String type;
  final int marks;
  final List<StudentQuizOption> options;

  const StudentQuizQuestion({
    required this.id,
    required this.text,
    required this.type,
    required this.marks,
    required this.options,
  });

  bool get hasOptions => options.isNotEmpty;

  factory StudentQuizQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = _readList(json, const ['options', 'choices', 'answers']);
    final options = rawOptions
        .map((item) {
          if (item is Map) {
            return StudentQuizOption.fromJson(
              Map<String, dynamic>.from(item as Map),
            );
          }
          return StudentQuizOption(id: '', label: item.toString());
        })
        .where((option) => option.label.isNotEmpty)
        .toList();

    var text = _readString(json, const [
      'question',
      'text',
      'title',
      'questionText',
      'statement',
      'prompt',
      'label',
    ]);
    final nestedQuestion = json['question'];
    if (text.isEmpty && nestedQuestion is Map) {
      text = _readString(Map<String, dynamic>.from(nestedQuestion), const [
        'text',
        'question',
        'title',
        'questionText',
        'statement',
        'prompt',
        'label',
      ]);
    } else if (text.isEmpty && nestedQuestion is String) {
      text = nestedQuestion.trim();
    }

    return StudentQuizQuestion(
      id: _readString(json, const ['id', '_id', 'questionId']),
      text: text,
      type: _readString(json, const ['type', 'questionType']),
      marks: _readInt(json, const ['marks', 'points']),
      options: options,
    );
  }
}

class StudentQuizOption {
  final String id;
  final String label;

  const StudentQuizOption({required this.id, required this.label});

  factory StudentQuizOption.fromJson(Map<String, dynamic> json) {
    return StudentQuizOption(
      id: _readString(json, const ['id', '_id', 'optionId', 'value']),
      label: _readString(json, const ['label', 'text', 'title', 'value']),
    );
  }
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return '';
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
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == 'yes') return true;
      if (lower == 'false' || lower == 'no') return false;
    }
  }
  return false;
}

List<dynamic> _readList(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) return value;
  }
  return const [];
}

double _resolveScorePercent(Map<String, dynamic> json, int totalMarks) {
  var percent = _readDouble(json, const [
    'scorePercent',
    'percentage',
    'percent',
    'scorePercentage',
    'resultPercent',
  ]);
  if (percent > 0) {
    return percent.clamp(0, 100);
  }

  final nested = json['result'] ?? json['attempt'] ?? json['submission'];
  if (nested is Map) {
    final nestedMap = Map<String, dynamic>.from(nested);
    percent = _readDouble(nestedMap, const [
      'scorePercent',
      'percentage',
      'percent',
      'scorePercentage',
      'resultPercent',
    ]);
    if (percent > 0) {
      return percent.clamp(0, 100);
    }
  }

  final score = _readDouble(json, const [
    'score',
    'marksObtained',
    'obtainedMarks',
    'points',
    'result',
  ]);
  final total = _readDouble(json, const [
    'total',
    'totalMarks',
    'maxMarks',
    'totalScore',
    'outOf',
  ]);
  if (score > 0 && total > 0) {
    return ((score / total) * 100).clamp(0, 100);
  }
  if (score > 0 && totalMarks > 0) {
    return ((score / totalMarks) * 100).clamp(0, 100);
  }
  if (score > 0 && score <= 100) {
    return score;
  }
  return -1;
}
