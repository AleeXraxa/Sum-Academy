import 'package:get/get.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/student/controllers/student_courses_controller.dart';
import 'package:sum_academy/modules/student/models/student_course.dart';
import 'package:sum_academy/modules/student/models/student_course_progress.dart';
import 'package:sum_academy/modules/student/models/student_live_session.dart';
import 'package:sum_academy/modules/student/services/student_course_progress_service.dart';

class StudentLiveSessionsController extends GetxController {
  final StudentCourseProgressService _progressService;

  StudentLiveSessionsController({StudentCourseProgressService? progressService})
      : _progressService = progressService ?? StudentCourseProgressService();

  final sessions = <StudentLiveSession>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSessions();
  }

  Future<void> fetchSessions({bool silent = false}) async {
    if (!silent) {
      isLoading.value = true;
      errorMessage.value = '';
    }
    try {
      final courses = _enrolledCourses();
      final found = <StudentLiveSession>[];

      for (final course in courses) {
        final progress = await _progressService.fetchProgress(course.id);
        for (final chapter in progress.chapters) {
          for (final lecture in chapter.lectures) {
            if (!lecture.shouldShowInLiveSessionsTab) continue;
            found.add(
              StudentLiveSession(
                courseId: course.id,
                courseTitle: course.title,
                className: course.className,
                classCode: course.classCode,
                lecture: lecture,
              ),
            );
          }
        }
      }

      found.sort((a, b) {
        if (a.isLive != b.isLive) return a.isLive ? -1 : 1;
        final aStart = a.startsAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bStart = b.startsAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aStart.compareTo(bStart);
      });

      sessions.assignAll(found);
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

  List<StudentCourse> _enrolledCourses() {
    if (!Get.isRegistered<StudentCoursesController>()) return const [];
    final controller = Get.find<StudentCoursesController>();
    return controller.courses.where((c) => c.isEnrolled).toList();
  }
}

