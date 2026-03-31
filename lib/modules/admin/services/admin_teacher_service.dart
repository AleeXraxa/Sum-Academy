import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/modules/admin/models/admin_user.dart';

class AdminTeacherService {
  AdminTeacherService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<AdminUser>> fetchTeachers({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final response = await _client.get(
      '/admin/teachers',
      auth: true,
      query: {
        'page': page,
        'limit': limit,
        'search': search,
      },
    );
    final data = response['data'];
    final teachers = _extractList(data);
    return teachers.map(AdminUser.fromJson).toList();
  }

  Future<AdminUser> createTeacher({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    String subject = '',
    String bio = '',
  }) async {
    final response = await _client.post(
      '/admin/users',
      auth: true,
      body: {
        'name': fullName,
        'fullName': fullName,
        'email': email,
        'password': password,
        'phoneNumber': phone,
        'phone': phone,
        'role': 'teacher',
        'isActive': true,
        'subject': subject,
        'bio': bio,
      },
    );
    return AdminUser.fromJson(_extractItem(response['data']));
  }

  Future<AdminUser> updateTeacher({
    required String uid,
    required String fullName,
    required String email,
    required String phone,
    required bool isActive,
    String subject = '',
    String bio = '',
  }) async {
    final response = await _client.put(
      '/admin/users/$uid',
      auth: true,
      body: {
        'name': fullName,
        'fullName': fullName,
        'email': email,
        'phoneNumber': phone,
        'phone': phone,
        'role': 'teacher',
        'isActive': isActive,
        'subject': subject,
        'bio': bio,
      },
    );
    return AdminUser.fromJson(_extractItem(response['data']));
  }

  Future<void> deleteTeacher(String uid) async {
    await _client.delete('/admin/users/$uid', auth: true);
  }

  Map<String, dynamic> _extractItem(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['teacher'] is Map) {
        return Map<String, dynamic>.from(data['teacher'] as Map);
      }
      if (data['user'] is Map) {
        return Map<String, dynamic>.from(data['user'] as Map);
      }
      if (data['doc'] is Map) {
        return Map<String, dynamic>.from(data['doc'] as Map);
      }
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
      final list = data['teachers'] ?? data['users'] ?? data['data'];
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
