import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/modules/admin/models/admin_class.dart';

class AdminClassService {
  AdminClassService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<AdminClass>> fetchClasses({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
  }) async {
    final response = await _client.get(
      '/admin/classes',
      auth: true,
      query: {
        if (page > 0) 'page': page,
        if (limit > 0) 'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    final data = response['data'];
    final items = _extractList(data);
    return items.map(AdminClass.fromJson).toList();
  }

  Future<AdminClass> createClass({
    required String name,
    String description = '',
    required int capacity,
    required String status,
    DateTime? startDate,
    DateTime? endDate,
    String? code,
    List<String>? courseIds,
    List<Map<String, dynamic>>? shifts,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      if (description.isNotEmpty) 'description': description,
      'capacity': capacity,
      'status': status,
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
      if (code != null && code.isNotEmpty) 'batchCode': code,
    };
    if (courseIds != null && courseIds.isNotEmpty) {
      payload['assignedCourses'] =
          courseIds.map((id) => {'courseId': id}).toList();
    }
    if (shifts != null && shifts.isNotEmpty) {
      payload['shifts'] = shifts;
    }
    final response = await _client.post(
      '/admin/classes',
      auth: true,
      body: payload,
    );
    return AdminClass.fromJson(_extractItem(response['data']));
  }

  Future<AdminClass> updateClass({
    required String classId,
    required String name,
    String description = '',
    required int capacity,
    required String status,
    DateTime? startDate,
    DateTime? endDate,
    String? code,
    List<String>? courseIds,
    List<Map<String, dynamic>>? shifts,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      if (description.isNotEmpty) 'description': description,
      'capacity': capacity,
      'status': status,
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
      if (code != null && code.isNotEmpty) 'batchCode': code,
    };
    if (courseIds != null && courseIds.isNotEmpty) {
      payload['assignedCourses'] =
          courseIds.map((id) => {'courseId': id}).toList();
    }
    if (shifts != null && shifts.isNotEmpty) {
      payload['shifts'] = shifts;
    }
    final response = await _client.put(
      '/admin/classes/$classId',
      auth: true,
      body: payload,
    );
    return AdminClass.fromJson(_extractItem(response['data']));
  }

  Future<void> deleteClass(String classId) async {
    await _client.delete('/admin/classes/$classId', auth: true);
  }

  Future<void> addCourseToClass({
    required String classId,
    required String courseId,
  }) async {
    await _client.post(
      '/admin/classes/$classId/courses',
      auth: true,
      body: {'courseId': courseId},
    );
  }

  Future<void> removeCourseFromClass({
    required String classId,
    required String courseId,
  }) async {
    await _client.delete(
      '/admin/classes/$classId/courses/$courseId',
      auth: true,
    );
  }

  Future<void> addShift({
    required String classId,
    required Map<String, dynamic> payload,
  }) async {
    await _client.post(
      '/admin/classes/$classId/shifts',
      auth: true,
      body: payload,
    );
  }

  Future<void> updateShift({
    required String classId,
    required String shiftId,
    required Map<String, dynamic> payload,
  }) async {
    await _client.put(
      '/admin/classes/$classId/shifts/$shiftId',
      auth: true,
      body: payload,
    );
  }

  Future<void> deleteShift({
    required String classId,
    required String shiftId,
  }) async {
    await _client.delete(
      '/admin/classes/$classId/shifts/$shiftId',
      auth: true,
    );
  }

  Future<void> addStudent({
    required String classId,
    required String studentId,
    String? shiftId,
  }) async {
    await _client.post(
      '/admin/classes/$classId/students',
      auth: true,
      body: {
        'studentId': studentId,
        if (shiftId != null && shiftId.isNotEmpty) 'shiftId': shiftId,
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchClassStudents({
    required String classId,
  }) async {
    final response = await _client.get(
      '/admin/classes/$classId/students',
      auth: true,
    );
    final data = response['data'];
    return _extractList(data);
  }

  Future<void> enrollStudent({
    required String classId,
    required String studentId,
    String? shiftId,
  }) async {
    await _client.post(
      '/admin/classes/$classId/enroll',
      auth: true,
      body: {
        'studentId': studentId,
        if (shiftId != null && shiftId.isNotEmpty) 'shiftId': shiftId,
      },
    );
  }

  Future<void> removeStudent({
    required String classId,
    required String studentId,
  }) async {
    await _client.delete(
      '/admin/classes/$classId/students/$studentId',
      auth: true,
    );
  }

  Map<String, dynamic> _extractItem(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['class'] is Map) {
        return Map<String, dynamic>.from(data['class'] as Map);
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

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final list = data['classes'] ?? data['data'] ?? data['items'];
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
