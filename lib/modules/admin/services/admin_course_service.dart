import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/modules/admin/models/admin_course.dart';
import 'package:sum_academy/modules/admin/controllers/admin_course_controller.dart';

class AdminCourseService {
  AdminCourseService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<AdminCourse>> fetchCourses({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final response = await _client.get(
      '/admin/courses',
      auth: true,
      query: {'page': page, 'limit': limit, 'search': search},
    );
    final data = response['data'];
    final courses = _extractList(data);
    return courses.map(AdminCourse.fromJson).toList();
  }

  Future<AdminCourse> createCourse({
    required String title,
    required String shortDescription,
    required String description,
    required String category,
    required String level,
    required double price,
    required double discount,
    required String status,
    required bool certificateEnabled,
    String? thumbnailUrl,
    List<CourseSubjectInput> subjects = const [],
  }) async {
    final subjectPayload = subjects
        .map(
          (subject) => {
            'name': subject.name,
            'subjectName': subject.name,
            'title': subject.name,
            'teacherId': subject.teacherId,
            'teacher': subject.teacherId,
            'teacherUid': subject.teacherId,
            'order': subject.order,
          },
        )
        .toList();
    final response = await _client.post(
      '/admin/courses',
      auth: true,
      body: {
        'title': title,
        'shortDescription': shortDescription,
        'description': description,
        'category': category,
        'level': level,
        'price': price,
        'discount': discount,
        'status': status,
        'certificateOnCompletion': certificateEnabled,
        if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
          'thumbnail': thumbnailUrl,
        if (subjectPayload.isNotEmpty) 'subjects': subjectPayload,
        if (subjectPayload.isNotEmpty) 'subjectList': subjectPayload,
        if (subjectPayload.isNotEmpty) 'courseSubjects': subjectPayload,
        if (subjectPayload.isNotEmpty) 'subjectsData': subjectPayload,
      },
    );
    return AdminCourse.fromJson(_extractItem(response['data']));
  }

  Future<AdminCourse> updateCourse({
    required String courseId,
    required String title,
    required String shortDescription,
    required String description,
    required String category,
    required String level,
    required double price,
    required double discount,
    required String status,
    required bool certificateEnabled,
    String? thumbnailUrl,
  }) async {
    final response = await _client.put(
      '/admin/courses/$courseId',
      auth: true,
      body: {
        'title': title,
        'shortDescription': shortDescription,
        'description': description,
        'category': category,
        'level': level,
        'price': price,
        'discount': discount,
        'status': status,
        'certificateOnCompletion': certificateEnabled,
        if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
          'thumbnail': thumbnailUrl,
      },
    );
    return AdminCourse.fromJson(_extractItem(response['data']));
  }

  Future<void> deleteCourse(String courseId) async {
    await _client.delete('/admin/courses/$courseId', auth: true);
  }

  Future<void> addSubject({
    required String courseId,
    required String name,
    required String teacherId,
    required int order,
  }) async {
    await _client.post(
      '/admin/courses/$courseId/subjects',
      auth: true,
      body: {'name': name, 'teacherId': teacherId, 'order': order},
    );
  }

  Map<String, dynamic> _extractItem(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['course'] is Map) {
        return Map<String, dynamic>.from(data['course'] as Map);
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
      final list = data['courses'] ?? data['data'];
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
