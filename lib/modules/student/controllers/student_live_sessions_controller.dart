import 'dart:async';

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
  Worker? _coursesWatcher;

  @override
  void onInit() {
    super.onInit();
    fetchSessions();
    if (Get.isRegistered<StudentCoursesController>()) {
      final courses = Get.find<StudentCoursesController>();
      _coursesWatcher = ever(courses.courses, (_) {
        if (sessions.isNotEmpty) return;
        if (isLoading.value) return;
        unawaited(fetchSessions(silent: true));
      });
    }
  }

  @override
  void onClose() {
    _coursesWatcher?.dispose();
    super.onClose();
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
      final source = listed.isEmpty ? await _buildFallbackSessions() : listed;
      final detailed = await Future.wait(
        source.map((s) async {
          if (s.id.trim().isEmpty) return s;
          if (s.isClientComputed) return s;
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

  Future<List<StudentSession>> _buildFallbackSessions() async {
    final courses = _enrolledCourses();
    if (courses.isEmpty) return const [];

    final collected = <StudentSession>[];
    for (final course in courses) {
      try {
        final progress = await _progressService.fetchProgress(course.id);
        for (final chapter in progress.chapters) {
          for (final lecture in chapter.lectures) {
            if (!lecture.isLiveSession) continue;
            final url = lecture.videoUrl.trim();
            if (url.isEmpty) continue;
            final startAt = lecture.startsAt;
            final endAt = lecture.endsAt;
            if (startAt == null) continue;

            final now = DateTime.now();
            final computedStatus = (endAt != null && now.isAfter(endAt))
                ? 'ended'
                : (now.isAfter(startAt) && (endAt == null || now.isBefore(endAt)))
                    ? 'active'
                    : 'upcoming';
            if (computedStatus == 'ended') continue; // ended sessions move to Classes

            final idBase = lecture.sessionId.trim().isNotEmpty
                ? lecture.sessionId.trim()
                : 'local_${course.id}_${lecture.id}_${startAt.millisecondsSinceEpoch}';

            collected.add(
              StudentSession(
                id: idBase,
                topic: '${course.title} - ${lecture.title}'.trim(),
                classId: course.classId,
                className: course.className,
                batchCode: course.classCode,
                teacherId: '',
                teacherName: course.teacher,
                platform: 'video',
                meetingLink: '',
                status: computedStatus,
                canJoin: true,
                lectureCompleted: false,
                joinedCount: 0,
                totalStudents: 0,
                elapsedSeconds: 0,
                remainingSeconds: endAt == null
                    ? 0
                    : endAt.difference(now).inSeconds.clamp(0, 24 * 60 * 60),
                isLocked: false,
                recordingUrl: url,
                isClientComputed: true,
                joinOpensAt: lecture.joinOpensAt ??
                    startAt.subtract(const Duration(minutes: 10)),
                joinClosesAt: lecture.joinOpensAt ??
                    startAt.add(const Duration(minutes: 10)),
                startAt: startAt,
                endAt: endAt,
              ),
            );
          }
        }
      } catch (_) {
        // Ignore: fallback is best-effort.
      }
    }
    return collected;
  }

  Future<void> refresh() async {
    await fetchSessions();
  }

  Future<Map<String, dynamic>> joinSession(StudentSession session) async {
    final id = session.id.trim();
    if (id.isEmpty) return const {'canPlay': false};
    if (session.isClientComputed) return const {'canPlay': true};
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
    if (session.isClientComputed) return;
    await _sessionsService.leaveSession(id, lectureCompleted: lectureCompleted);
  }

  Future<Map<String, dynamic>> syncSession(StudentSession session) async {
    final id = session.id.trim();
    if (id.isEmpty) return const {};
    if (session.isClientComputed) return const {};
    return _sessionsService.syncSession(id);
  }

  Future<StudentSession> fetchSessionStatus(String sessionId) {
    return _sessionsService.fetchSession(sessionId);
  }

  List<StudentCourse> _enrolledCourses() {
    if (!Get.isRegistered<StudentCoursesController>()) return const [];
    final controller = Get.find<StudentCoursesController>();
    final enrolled = controller.courses.where((c) => c.isEnrolled).toList();
    // Backend/admin may mark a subject as "locked/NA" after completion which can
    // flip `isEnrolled` in some responses. For Live Sessions we still want to
    // compute schedule from visible courses in the student app.
    return enrolled.isNotEmpty ? enrolled : controller.courses.toList();
  }

  int _statusRank(StudentSession session) {
    if (session.isLive) return 0;
    return 1;
  }
}
