import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/modules/student/models/student_course_progress.dart';

class StudentCourseProgressService {
  StudentCourseProgressService({ApiClient? client})
      : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<StudentCourseProgress> fetchProgress(String courseId) async {
    if (courseId.trim().isEmpty) {
      return StudentCourseProgress.empty();
    }
    final response = await _client.get(
      '/student/courses/$courseId/progress',
      auth: true,
    );
    final payload = response['data'] ?? response;
    return StudentCourseProgress.fromAny(payload);
  }
}
