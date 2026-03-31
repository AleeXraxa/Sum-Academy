import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/modules/admin/models/admin_user.dart';

class AdminStudentService {
  AdminStudentService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<AdminUser>> fetchStudents({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final response = await _client.get(
      '/admin/students',
      auth: true,
      query: {
        'page': page,
        'limit': limit,
        'search': search,
      },
    );
    final data = response['data'];
    final students = _extractList(data);
    return students.map(AdminUser.fromJson).toList();
  }

  Future<AdminUser> createStudent({
    required String fullName,
    required String email,
    required String password,
    required String phone,
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
        'role': 'student',
        'isActive': true,
      },
    );
    return AdminUser.fromJson(_extractItem(response['data']));
  }

  Future<AdminUser> updateStudent({
    required String uid,
    required String fullName,
    required String email,
    required String phone,
    required bool isActive,
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
        'role': 'student',
        'isActive': isActive,
      },
    );
    return AdminUser.fromJson(_extractItem(response['data']));
  }

  Future<void> deleteStudent(String uid) async {
    await _client.delete('/admin/users/$uid', auth: true);
  }

  Map<String, dynamic> _extractItem(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['student'] is Map) {
        return Map<String, dynamic>.from(data['student'] as Map);
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
      final list = data['students'] ?? data['users'] ?? data['data'];
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
