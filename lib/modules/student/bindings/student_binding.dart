import 'package:get/get.dart';
import 'package:sum_academy/modules/auth/services/auth_service.dart';
import 'package:sum_academy/modules/home/controllers/home_controller.dart';
import 'package:sum_academy/modules/home/services/home_service.dart';
import 'package:sum_academy/modules/student/controllers/student_courses_controller.dart';
import 'package:sum_academy/modules/student/controllers/student_explore_courses_controller.dart';
import 'package:sum_academy/modules/student/controllers/student_shell_controller.dart';
import 'package:sum_academy/modules/student/controllers/student_support_controller.dart';
import 'package:sum_academy/modules/student/services/student_courses_service.dart';
import 'package:sum_academy/modules/student/services/student_explore_courses_service.dart';
import 'package:sum_academy/modules/student/services/student_support_service.dart';

class StudentBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HomeService>()) {
      Get.lazyPut<HomeService>(HomeService.new, fenix: true);
    }
    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut<HomeController>(
        () => HomeController(Get.find<HomeService>()),
      );
    }
    if (!Get.isRegistered<StudentShellController>()) {
      Get.lazyPut<StudentShellController>(
        () => StudentShellController(Get.find<AuthService>()),
      );
    }
    if (!Get.isRegistered<StudentCoursesService>()) {
      Get.lazyPut<StudentCoursesService>(
        StudentCoursesService.new,
        fenix: true,
      );
    }
    if (!Get.isRegistered<StudentCoursesController>()) {
      Get.lazyPut<StudentCoursesController>(
        () => StudentCoursesController(Get.find<StudentCoursesService>()),
      );
    }
    if (!Get.isRegistered<StudentExploreCoursesService>()) {
      Get.lazyPut<StudentExploreCoursesService>(
        StudentExploreCoursesService.new,
        fenix: true,
      );
    }
    if (!Get.isRegistered<StudentExploreCoursesController>()) {
      Get.lazyPut<StudentExploreCoursesController>(
        () =>
            StudentExploreCoursesController(Get.find<StudentExploreCoursesService>()),
      );
    }
    if (!Get.isRegistered<StudentSupportService>()) {
      Get.lazyPut<StudentSupportService>(
        StudentSupportService.new,
        fenix: true,
      );
    }
    if (!Get.isRegistered<StudentSupportController>()) {
      Get.lazyPut<StudentSupportController>(
        () => StudentSupportController(Get.find<StudentSupportService>()),
      );
    }
  }
}
