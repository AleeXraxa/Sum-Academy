import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/modules/student/models/student_course.dart';

class StudentCoursesService {
  StudentCoursesService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<StudentCourse>> fetchCourses() async {
    final response = await _client.get('/student/courses', auth: true);
    final data = response['data'] ?? response;
    return parseStudentCourses(data);
  }
}
