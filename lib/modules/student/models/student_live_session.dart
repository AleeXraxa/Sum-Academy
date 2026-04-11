import 'package:sum_academy/modules/student/models/student_course_progress.dart';
import 'package:sum_academy/modules/student/models/student_session.dart';

class StudentLiveSession {
  final String courseId;
  final String courseTitle;
  final String className;
  final String classCode;
  final StudentCourseLecture lecture;
  final StudentSession? session;

  const StudentLiveSession({
    required this.courseId,
    required this.courseTitle,
    required this.className,
    required this.classCode,
    required this.lecture,
    this.session,
  });

  String get sessionId => (session?.id ?? lecture.sessionId).trim();

  DateTime? get joinOpensAt => session?.joinOpensAt ?? lecture.joinOpensAt;
  DateTime? get startsAt => session?.startAt ?? lecture.startsAt;
  DateTime? get endsAt => session?.endAt ?? lecture.endsAt;
  DateTime? get joinClosesAt => session?.joinClosesAt;
  String get status => session?.status ?? '';
  String get teacherName => session?.teacherName ?? '';
  String get topic =>
      (session?.topic ?? '').isNotEmpty ? session!.topic : lecture.title;

  bool get isScheduled {
    if (!lecture.isLiveSession) return false;
    if (isLive) return false;
    if (hasEnded) return false;
    final start = startsAt;
    if (start == null) return true;
    return start.isAfter(DateTime.now());
  }

  String get meetingLink {
    final link = (session?.meetingLink ?? '').trim();
    if (link.isNotEmpty) return link;
    // Some backends keep the live meeting link in the lecture video URL.
    return lecture.videoUrl.trim();
  }

  bool get hasEnded {
    if (session != null) return session!.hasEnded;
    final end = endsAt;
    if (end == null) return false;
    return DateTime.now().isAfter(end);
  }

  bool get isLive {
    if (session != null) return session!.isLive;
    final start = startsAt;
    final end = endsAt;
    if (start == null || end == null) return false;
    final now = DateTime.now();
    return now.isAfter(start) && now.isBefore(end);
  }
}
