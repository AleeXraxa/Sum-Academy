import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/modules/student/models/student_explore_course.dart';

class StudentExploreCoursesService {
  StudentExploreCoursesService({ApiClient? client})
      : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<StudentExploreCourse>> fetchCourses() async {
    final response = await _client.get('/courses/explore', auth: false);
    final data = response['data'] ?? response;
    return parseExploreCourses(data);
  }
}
