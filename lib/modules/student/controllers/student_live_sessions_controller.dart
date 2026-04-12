import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/student/controllers/student_courses_controller.dart';
import 'package:sum_academy/modules/student/models/student_course.dart';
import 'package:sum_academy/modules/student/models/student_course_progress.dart';
import 'package:sum_academy/modules/student/models/student_session.dart';
import 'package:sum_academy/modules/student/services/student_course_progress_service.dart';
import 'package:sum_academy/modules/student/services/student_sessions_service.dart';

class StudentLiveSessionsController extends GetxController {
  final StudentCourseProgressService _progressService;
  final StudentSessionsService _sessionsService;

  StudentLiveSessionsController({
    StudentCourseProgressService? progressService,
    StudentSessionsService? sessionsService,
  })  : _progressService = progressService ?? StudentCourseProgressService(),
        _sessionsService = sessionsService ?? StudentSessionsService();

  final sessions = <StudentSession>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final selectedFilter = 'all'.obs; // all | live | upcoming | recording

  @override
  void onInit() {
    super.onInit();
    fetchSessions();
  }

  List<StudentSession> get filteredSessions {
    final filter = selectedFilter.value;
    if (filter == 'live') {
      return sessions.where((s) => s.isLive).toList();
    }
    if (filter == 'upcoming') {
      return sessions.where((s) => !s.isLive && !s.hasEnded).toList();
    }
    if (filter == 'recording') {
      return const [];
    }
    return sessions.where((s) => !s.hasEnded).toList();
  }

  void setFilter(String value) {
    selectedFilter.value = value;
  }

  Future<void> fetchSessions({bool silent = false}) async {
    if (!silent) {
      isLoading.value = true;
      errorMessage.value = '';
    }
    try {
      final listed = await _sessionsService.fetchLiveSessions();
      if (kDebugMode) {
        debugPrint('Live sessions list -> count=${listed.length}');
      }
      final detailed = await Future.wait(
        listed.map((s) async {
          if (s.id.trim().isEmpty) return s;
          try {
            return await _sessionsService.fetchSession(s.id);
          } catch (_) {
            return s;
          }
        }),
      );
      final filtered = detailed.where((s) => s.id.trim().isNotEmpty).toList();
      filtered.sort((a, b) {
        final aRank = _statusRank(a);
        final bRank = _statusRank(b);
        if (aRank != bRank) return aRank.compareTo(bRank);
        final aStart = a.startAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bStart = b.startAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aStart.compareTo(bStart);
      });
      sessions.assignAll(filtered);
    } on ApiException catch (e) {
      if (!silent) {
        errorMessage.value = e.message;
        final handled = await handleNetworkError(e);
        if (!handled) {
          await showAppErrorDialog(title: 'Live Sessions', message: e.message);
        }
      }
    } catch (_) {
      if (!silent) {
        errorMessage.value = 'Unable to load live sessions.';
      }
    } finally {
      if (!silent) {
        isLoading.value = false;
      }
    }
  }

  Future<void> refresh() async {
    await fetchSessions();
  }

  Future<Map<String, dynamic>> joinSession(StudentSession session) async {
    final id = session.id.trim();
    if (id.isEmpty) return const {'canPlay': false};
    return _sessionsService.joinSession(id);
  }

  Future<void> reportViolation({
    required StudentSession session,
    required String reason,
    required int count,
  }) async {
    final id = session.id.trim();
    if (id.isEmpty) return;
    await _sessionsService.reportViolation(
      sessionId: id,
      reason: reason,
      count: count,
      timestamp: DateTime.now(),
    );
  }

  Future<void> leaveSession(
    StudentSession session, {
    bool lectureCompleted = false,
  }) async {
    final id = session.id.trim();
    if (id.isEmpty) return;
    await _sessionsService.leaveSession(id, lectureCompleted: lectureCompleted);
  }

  Future<Map<String, dynamic>> syncSession(StudentSession session) async {
    final id = session.id.trim();
    if (id.isEmpty) return const {};
    return _sessionsService.syncSession(id);
  }

  Future<StudentSession> fetchSessionStatus(String sessionId) {
    return _sessionsService.fetchSession(sessionId);
  }

  List<StudentCourse> _enrolledCourses() {
    if (!Get.isRegistered<StudentCoursesController>()) return const [];
    final controller = Get.find<StudentCoursesController>();
    return controller.courses.where((c) => c.isEnrolled).toList();
  }

  int _statusRank(StudentSession session) {
    if (session.isLive) return 0;
    return 1;
  }
}
