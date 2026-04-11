import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/modules/student/models/student_session.dart';

class StudentSessionsService {
  StudentSessionsService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<StudentSession>> fetchLiveSessions() async {
    final response = await _client.get('/student/live-sessions', auth: true);
    final payload = response['data'] ?? response;
    if (payload is List) {
      return payload.map(StudentSession.fromAny).toList();
    }
    if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);
      final list = map['sessions'] ?? map['items'] ?? map['data'];
      if (list is List) {
        return list.map(StudentSession.fromAny).toList();
      }
    }
    return const [];
  }

  Future<StudentSession> fetchSession(String sessionId) async {
    if (sessionId.trim().isEmpty) {
      return StudentSession.empty();
    }
    // Updated API: status endpoint powers the live/pre/ended UI.
    final response =
        await _client.get('/student/sessions/$sessionId/status', auth: true);
    return StudentSession.fromJson(response);
  }

  Future<Map<String, dynamic>> joinSession(String sessionId) async {
    final response =
        await _client.post('/student/sessions/$sessionId/join', auth: true);
    return response['data'] is Map ? Map<String, dynamic>.from(response['data']) : response;
  }

  Future<Map<String, dynamic>> syncSession(String sessionId) async {
    final response =
        await _client.get('/student/sessions/$sessionId/sync', auth: true);
    return response['data'] is Map ? Map<String, dynamic>.from(response['data']) : response;
  }

  Future<void> leaveSession(String sessionId) async {
    await _client.post('/student/sessions/$sessionId/leave', auth: true);
  }

  Future<void> reportViolation({
    required String sessionId,
    required String reason,
    required int count,
    required DateTime timestamp,
  }) async {
    await _client.post(
      '/student/sessions/$sessionId/violation',
      auth: true,
      body: {
        'reason': reason,
        'count': count,
        'timestamp': timestamp.toUtc().toIso8601String(),
      },
    );
  }
}
