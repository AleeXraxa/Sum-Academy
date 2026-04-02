import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/modules/admin/models/teacher_profile.dart';

class TeacherProfileService {
  TeacherProfileService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<TeacherProfileData> fetchTeacherProfile(String teacherId) async {
    final response = await _client.get(
      '/admin/teachers/$teacherId',
      auth: true,
    );
    final detail = _extract(response['data']);
    return TeacherProfileData.fromJson(detail);
  }

  Map<String, dynamic> _extract(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['teacher'] is Map) {
        return Map<String, dynamic>.from(data['teacher'] as Map);
      }
      if (data['profile'] is Map) {
        return Map<String, dynamic>.from(data['profile'] as Map);
      }
      if (data['detail'] is Map) {
        return Map<String, dynamic>.from(data['detail'] as Map);
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
