import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/modules/admin/models/admin_user.dart';

class AdminUserService {
  AdminUserService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<AdminUser>> fetchUsers({
    int page = 1,
    int limit = 20,
    String? search,
    String? role,
    bool? isActive,
  }) async {
    final response = await _client.get(
      '/admin/users',
      auth: true,
      query: {
        if (page > 0) 'page': page,
        if (limit > 0) 'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (role != null && role.isNotEmpty) 'role': role,
        if (isActive != null) 'isActive': isActive.toString(),
      },
    );
    final data = response['data'];
    final users = _extractList(data);
    return users.map(AdminUser.fromJson).toList();
  }

  Future<AdminUser> createUser({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    final normalizedRole = role.toLowerCase();
    final response = await _client.post(
      '/admin/users',
      auth: true,
      body: {
        'name': fullName,
        'fullName': fullName,
        'email': email,
        'password': password,
        'phone': phone,
        'phoneNumber': phone,
        'role': normalizedRole,
        'isActive': true,
      },
    );
    return AdminUser.fromJson(_extractItem(response['data']));
  }

  Future<AdminUser> updateUser({
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
        'fullName': fullName,
        'name': fullName,
        if (email.isNotEmpty) 'email': email,
        if (phone.isNotEmpty) 'phoneNumber': phone,
        if (phone.isNotEmpty) 'phone': phone,
        'isActive': isActive,
      },
    );
    return AdminUser.fromJson(_extractItem(response['data']));
  }

  Future<void> deleteUser(String uid) async {
    await _client.delete('/admin/users/$uid', auth: true);
  }

  Future<AdminUser> updateUserRole({
    required String uid,
    required String role,
  }) async {
    final response = await _client.patch(
      '/admin/users/$uid/role',
      auth: true,
      body: {'role': role.toLowerCase()},
    );
    return AdminUser.fromJson(_extractItem(response['data']));
  }

  Future<void> resetUserDevice(String uid) async {
    await _client.patch('/admin/users/$uid/reset-device', auth: true);
  }

  Map<String, dynamic> _extractItem(dynamic data) {
    if (data is Map<String, dynamic>) {
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
      final list = data['users'] ?? data['data'] ?? data['items'];
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
