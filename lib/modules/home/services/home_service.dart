import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/modules/home/models/home_dashboard.dart';
import 'package:sum_academy/modules/student/models/student_settings.dart';
import 'package:sum_academy/modules/student/models/student_course.dart';

class HomeService {
  HomeService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<HomeDashboard> fetchDashboard() async {
    Map<String, dynamic> dashboardData = const {};
    try {
      final response = await _client.get('/student/dashboard', auth: true);
      dashboardData = _extractMap(response['data'] ?? response);
    } on ApiException {
      dashboardData = const {};
    }

    List<dynamic> courses = const [];
    List<dynamic> certificates = const [];
    bool? isProfileComplete;

    final settingsResponse = await _safeGet(
      _client.get('/student/settings', auth: true),
    );
    final settingsPayload = settingsResponse?['data'] ?? settingsResponse;
    final settingsMap = _extractMap(settingsPayload);
    if (settingsMap.isNotEmpty) {
      final settings = StudentSettings.fromJson(settingsMap);
      isProfileComplete = settings.isComplete;
    }

    final coursesResponse = await _safeGet(
      _client.get('/student/courses', auth: true),
    );
    final certsResponse = await _safeGet(
      _client.get('/student/certificates', auth: true),
    );
    final coursesPayload = coursesResponse?['data'] ?? coursesResponse;
    final parsedCourses = parseStudentCourses(coursesPayload);
    courses = parsedCourses.isNotEmpty
        ? parsedCourses
        : _extractList(coursesPayload);
    certificates = _extractList(certsResponse?['data'] ?? certsResponse);

    final mergedDashboard = _extractMap(dashboardData);
    if (isProfileComplete != null) {
      mergedDashboard['profileComplete'] = isProfileComplete;
    }

    return HomeDashboard.fromApi(
      dashboard: mergedDashboard,
      courses: courses,
      certificates: certificates,
      attendance: const {},
    );
  }
}

Future<Map<String, dynamic>?> _safeGet(
  Future<Map<String, dynamic>> future,
) async {
  try {
    return await future;
  } catch (_) {
    return null;
  }
}

List<dynamic> _extractList(dynamic value) {
  if (value is List) return value;
  if (value is Map<String, dynamic>) {
    final list = value['data'] ?? value['items'] ?? value['courses'];
    if (list is List) return list;
  }
  return const [];
}

Map<String, dynamic> _extractMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}
