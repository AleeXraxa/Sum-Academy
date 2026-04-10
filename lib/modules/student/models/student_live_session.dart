import 'package:sum_academy/modules/student/models/student_course_progress.dart';

class StudentLiveSession {
  final String courseId;
  final String courseTitle;
  final String className;
  final String classCode;
  final StudentCourseLecture lecture;

  const StudentLiveSession({
    required this.courseId,
    required this.courseTitle,
    required this.className,
    required this.classCode,
    required this.lecture,
  });

  bool get isLive => lecture.isCurrentlyLive;

  bool get isScheduled {
    if (!lecture.isLiveSession) return false;
    if (lecture.isCurrentlyLive) return false;
    final start = lecture.startsAt;
    if (start == null) return true;
    return start.isAfter(DateTime.now());
  }

  DateTime? get joinOpensAt => lecture.joinOpensAt;
  DateTime? get startsAt => lecture.startsAt;
  DateTime? get endsAt => lecture.endsAt;
}

