import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/modules/student/models/student_test.dart';

class StudentTestsService {
  StudentTestsService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<StudentTest>> fetchTests() async {
    final response = await _client.get('/student/tests', auth: true);
    return parseStudentTests(response);
  }

  Future<StudentTestDetail> fetchTestDetail(String testId) async {
    final response = await _client.get('/student/tests/$testId', auth: true);
    return StudentTestDetail.fromJson(response);
  }

  Future<StudentTestDetail> startOrResume(String testId) async {
    final response = await _client.post('/student/tests/$testId/start', auth: true);
    // Some backends return attempt only; re-fetch detail for current question.
    try {
      return StudentTestDetail.fromJson(response);
    } catch (_) {
      return fetchTestDetail(testId);
    }
  }

  Future<void> answer({
    required String testId,
    required String questionId,
    required String selectedAnswer,
  }) async {
    await _client.post(
      '/student/tests/$testId/answer',
      auth: true,
      body: {
        'questionId': questionId,
        'selectedAnswer': selectedAnswer,
      },
    );
  }

  Future<Map<String, dynamic>> finish({
    required String testId,
    String reason = 'manual',
  }) async {
    return _client.post(
      '/student/tests/$testId/finish',
      auth: true,
      body: {'reason': reason},
    );
  }

  Future<Map<String, dynamic>> fetchRanking(String testId) async {
    return _client.get('/student/tests/$testId/ranking', auth: true);
  }
}

