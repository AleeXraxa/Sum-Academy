import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/modules/admin/models/student_profile.dart';

class UserProfileService {
  UserProfileService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<StudentProfile> fetchUserProfile(String userId) async {
    final response = await _client.get(
      '/admin/users/$userId',
      auth: true,
    );
    final detail = _extract(response['data']);
    return StudentProfile.fromJson(detail);
  }

  Map<String, dynamic> _extract(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['user'] is Map) {
        return Map<String, dynamic>.from(data['user'] as Map);
      }
      if (data['profile'] is Map) {
        return Map<String, dynamic>.from(data['profile'] as Map);
      }
      if (data['detail'] is Map) {
        return Map<String, dynamic>.from(data['detail'] as Map);
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
