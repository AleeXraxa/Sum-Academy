import 'package:sum_academy/modules/student/models/student_course.dart';

class StudentEnrolledClass {
  final String id;
  final String code;
  final String name;
  final String teacher;
  final double progress;
  final int paidCourses;
  final int totalCourses;
  final List<StudentCourse> courses;
  final String thumbnailUrl;

  const StudentEnrolledClass({
    required this.id,
    required this.code,
    required this.name,
    required this.teacher,
    required this.progress,
    required this.paidCourses,
    required this.totalCourses,
    required this.courses,
    required this.thumbnailUrl,
  });

  bool get hasCourses => courses.isNotEmpty;
}
