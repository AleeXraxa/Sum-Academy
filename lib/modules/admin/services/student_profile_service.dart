import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/modules/admin/models/student_profile.dart';

class StudentProfileService {
  StudentProfileService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<StudentProfileData> fetchStudentProfile(String studentId) async {
    final detailResponse = await _client.get(
      '/teacher/students/$studentId',
      auth: true,
    );
    final progressResponse = await _client.get(
      '/teacher/students/$studentId/progress/',
      auth: true,
    );

    final detail = _extract(detailResponse['data']);
    final progress = _extract(progressResponse['data']);

    return StudentProfileData(
      profile: StudentProfile.fromJson(detail),
      progress: StudentProgress.fromJson(progress),
    );
  }

  Map<String, dynamic> _extract(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['student'] is Map) {
        return Map<String, dynamic>.from(data['student'] as Map);
      }
      if (data['profile'] is Map) {
        return Map<String, dynamic>.from(data['profile'] as Map);
      }
      if (data['detail'] is Map) {
        return Map<String, dynamic>.from(data['detail'] as Map);
      }
      if (data['progress'] is Map) {
        return Map<String, dynamic>.from(data['progress'] as Map);
      }
      if (data['user'] is Map) {
        return Map<String, dynamic>.from(data['user'] as Map);
      }
      if (data['doc'] is Map) {
        return Map<String, dynamic>.from(data['doc'] as Map);
      }
      if (data['data'] is Map) {
        return Map<String, dynamic>.from(data['data'] as Map);
      }
      return data;
    }
    return {};
  }
}
