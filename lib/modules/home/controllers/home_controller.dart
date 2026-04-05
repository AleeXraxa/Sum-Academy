import 'package:get/get.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/home/models/home_dashboard.dart';
import 'package:sum_academy/modules/home/services/home_service.dart';
import 'package:sum_academy/modules/student/controllers/student_courses_controller.dart';

class HomeController extends GetxController {
  HomeController(this._service);

  final HomeService _service;
  final Rx<HomeDashboard> dashboard = HomeDashboard.empty().obs;
  final isLoading = false.obs;
  bool _hasRetried = false;
  bool _coursesLinked = false;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
    _linkCourses();
  }

  Future<void> loadDashboard({bool retryIfEmpty = true}) async {
    isLoading.value = true;
    try {
      dashboard.value = await _service.fetchDashboard();
      if (retryIfEmpty &&
          !_hasRetried &&
          _isDashboardEmpty(dashboard.value)) {
        _hasRetried = true;
        Future.delayed(const Duration(seconds: 2), () {
          if (!isLoading.value) {
            loadDashboard(retryIfEmpty: false);
          }
        });
      }
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showAppErrorDialog(
          title: 'Dashboard failed',
          message: e.message,
        );
      }
    } catch (_) {
      await showAppErrorDialog(
        title: 'Dashboard failed',
        message: 'Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _linkCourses() {
    if (_coursesLinked) return;
    if (!Get.isRegistered<StudentCoursesController>()) return;
    _coursesLinked = true;
    final coursesController = Get.find<StudentCoursesController>();
    ever<List<dynamic>>(coursesController.courses, (_) {
      if (_isDashboardEmpty(dashboard.value) &&
          coursesController.courses.isNotEmpty) {
        dashboard.value = HomeDashboard.fromApi(
          dashboard: const {},
          courses: coursesController.courses,
          certificates: const [],
          attendance: const {},
        );
      }
    });
  }
}

bool _isDashboardEmpty(HomeDashboard dashboard) {
  if (dashboard.enrolledCourses > 0) return false;
  if (dashboard.recentCourses.isNotEmpty) return false;
  if (dashboard.activeCourse != null &&
      !(dashboard.activeCourse?.isEmpty ?? true)) {
    return false;
  }
  return true;
}

