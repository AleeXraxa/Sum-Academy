import 'package:get/get.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/student/models/student_course_progress.dart';
import 'package:sum_academy/modules/student/services/student_course_progress_service.dart';

class StudentCourseProgressController extends GetxController {
  StudentCourseProgressController(
    this._service, {
    required this.courseId,
  });

  final StudentCourseProgressService _service;
  final String courseId;

  final progress = StudentCourseProgress.empty().obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      isLoading.value = true;
    }
    errorMessage.value = '';
    try {
      final result = await _service.fetchProgress(courseId);
      progress.value = result;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showAppErrorDialog(
          title: 'Course progress',
          message: e.message,
        );
      }
    } catch (_) {
      errorMessage.value = 'Unable to load course content.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    await load(silent: true);
  }
}
