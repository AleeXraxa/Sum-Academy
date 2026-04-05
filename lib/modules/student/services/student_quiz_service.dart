import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/modules/student/models/student_quiz.dart';

class StudentQuizService {
  StudentQuizService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<StudentQuizSummary>> fetchQuizzes() async {
    final response = await _client.get('/student/quizzes', auth: true);
    final data = response['data'] ?? response;
    final list = _extractList(data);
    return list.map(StudentQuizSummary.fromJson).toList();
  }

  Future<StudentQuizDetail> fetchQuiz(String quizId) async {
    final response = await _client.get(
      '/student/quizzes/$quizId',
      auth: true,
    );
    final data = response['data'] ?? response;
    if (data is Map<String, dynamic>) {
      return StudentQuizDetail.fromJson(data);
    }
    throw ApiException('Failed to load quiz.');
  }

  Future<Map<String, dynamic>> submitQuiz({
    required String quizId,
    required List<Map<String, dynamic>> answers,
  }) async {
    final response = await _client.post(
      '/student/quizzes/$quizId/submit',
      auth: true,
      body: {'answers': answers},
    );
    final data = response['data'] ?? response;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {};
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final list = data['data'] ?? data['items'] ?? data['quizzes'];
      if (list is List) {
        return list
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }
    return [];
  }
}
