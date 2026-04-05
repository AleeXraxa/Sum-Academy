import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/modules/admin/controllers/admin_course_controller.dart';
import 'package:sum_academy/modules/admin/models/admin_course.dart';
import 'package:sum_academy/modules/admin/models/course_subject.dart';

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
      query: {
        if (page > 0) 'page': page,
        if (limit > 0) 'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      },
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
            'teacherId': subject.teacherId,
            'order': subject.order,
          },
        )
        .toList();
    final coursePayload = <String, dynamic>{
      'title': title,
      if (shortDescription.isNotEmpty) 'shortDescription': shortDescription,
      'description': description,
      'category': category,
      'level': level,
      'price': price,
      'discountPercent': discount,
      if (status.isNotEmpty) 'status': status,
      if (certificateEnabled) 'certificateOnCompletion': certificateEnabled,
      if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
        'thumbnail': thumbnailUrl,
    };
    if (subjectPayload.isNotEmpty) {
      coursePayload['subjects'] = subjectPayload;
    }
    final response = await _client.post(
      '/admin/courses',
      auth: true,
      body: coursePayload,
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
        if (shortDescription.isNotEmpty) 'shortDescription': shortDescription,
        if (description.isNotEmpty) 'description': description,
        if (category.isNotEmpty) 'category': category,
        if (level.isNotEmpty) 'level': level,
        'price': price,
        'discountPercent': discount,
        if (status.isNotEmpty) 'status': status,
        if (certificateEnabled) 'certificateOnCompletion': certificateEnabled,
        if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
          'thumbnail': thumbnailUrl,
      },
    );
    return AdminCourse.fromJson(_extractItem(response['data']));
  }

  Future<AdminCourse> archiveCourse({
    required String courseId,
  }) async {
    final response = await _client.patch(
      '/admin/courses/$courseId',
      auth: true,
      body: {
        'status': 'archived',
        'archived': true,
        'isArchived': true,
      },
    );
    return AdminCourse.fromJson(_extractItem(response['data']));
  }

  Future<AdminCourse> publishCourse({
    required String courseId,
  }) async {
    final response = await _client.patch(
      '/admin/courses/$courseId',
      auth: true,
      body: {
        'status': 'published',
        'archived': false,
        'isArchived': false,
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

  Future<void> deleteSubject({
    required String courseId,
    required String subjectId,
  }) async {
    await _client.delete(
      '/admin/courses/$courseId/subjects/$subjectId',
      auth: true,
    );
  }

  Future<List<CourseSubject>> fetchCourseSubjects(String courseId) async {
    final response = await _client.get(
      '/admin/courses/$courseId/content',
      auth: true,
    );
    final data = response['data'];
    final subjects = _extractSubjects(data);
    return subjects.map(CourseSubject.fromJson).toList();
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
      final list = data['courses'] ?? data['data'] ?? data['items'];
      if (list is List) {
        return list
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }
    return [];
  }

  List<Map<String, dynamic>> _extractSubjects(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final direct = _extractSubjectsFromMap(data);
      if (direct.isNotEmpty) return direct;
      for (final key in ['course', 'data', 'payload', 'result', 'content']) {
        final nested = data[key];
        if (nested is Map<String, dynamic>) {
          final nestedList = _extractSubjectsFromMap(nested);
          if (nestedList.isNotEmpty) return nestedList;
        }
      }
    }
    return [];
  }

  List<Map<String, dynamic>> _extractSubjectsFromMap(
    Map<String, dynamic> data,
  ) {
    final list = data['subjects'] ??
        data['subjectList'] ??
        data['courseSubjects'] ??
        data['subjectsData'] ??
        data['subjectsList'];
    if (list is List) {
      return list
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return [];
  }
}
