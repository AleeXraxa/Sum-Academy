import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/modules/student/models/student_support_info.dart';

class StudentSupportService {
  StudentSupportService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<StudentSupportInfo> fetchSupportInfo() async {
    final response = await _client.get('/student/settings', auth: true);
    final data = response['data'] ?? response;
    return StudentSupportInfo.fromAny(data);
  }
}
