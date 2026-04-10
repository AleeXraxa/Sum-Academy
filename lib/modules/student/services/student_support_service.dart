import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/modules/student/models/student_support_info.dart';

class StudentSupportService {
  StudentSupportService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<StudentSupportInfo> fetchSupportInfo() async {
    try {
      final response = await _client.get('/settings');
      final data = response['data'] ?? response;
      final scoped = data is Map<String, dynamic>
          ? (data['contact'] ?? data['support'] ?? data)
          : data;
      return StudentSupportInfo.fromAny(scoped);
    } catch (_) {
      final response = await _client.get('/student/settings', auth: true);
      final data = response['data'] ?? response;
      final scoped = data is Map<String, dynamic>
          ? (data['contact'] ?? data['support'] ?? data)
          : data;
      return StudentSupportInfo.fromAny(scoped);
    }
  }
}
