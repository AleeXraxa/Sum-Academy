class CourseSubject {
  final String id;
  final String name;
  final String teacherId;
  final String teacherName;
  final int order;

  const CourseSubject({
    required this.id,
    required this.name,
    required this.teacherId,
    required this.teacherName,
    required this.order,
  });

  factory CourseSubject.fromJson(Map<String, dynamic> json) {
    final id = _readString(json, ['id', '_id', 'subjectId']);
    final name = _readString(json, ['name', 'subjectName', 'title']);
    var teacherId = _readString(
      json,
      ['teacherId', 'teacherUid', 'teacher_id'],
    );
    var teacherName = _readString(
      json,
      ['teacherName', 'teacherFullName', 'teacherDisplay', 'teacher'],
    );
    final teacher = json['teacher'];
    if (teacher is Map<String, dynamic>) {
      teacherId = teacherId.isNotEmpty
          ? teacherId
          : _readString(teacher, ['id', '_id', 'uid', 'userId']);
      if (teacherName.isEmpty) {
        teacherName = _readString(teacher, ['name', 'fullName', 'email']);
      }
    } else if (teacher is String && teacherName.isEmpty) {
      teacherName = teacher;
    }
    final order = _readInt(json, ['order', 'position', 'sortOrder']);

    return CourseSubject(
      id: id,
      name: name,
      teacherId: teacherId,
      teacherName: teacherName,
      order: order,
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
