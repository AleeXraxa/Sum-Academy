import 'package:get/get.dart';
import 'package:sum_academy/modules/auth/services/auth_service.dart';
import 'package:sum_academy/modules/home/controllers/home_controller.dart';
import 'package:sum_academy/modules/home/services/home_service.dart';
import 'package:sum_academy/modules/student/controllers/student_courses_controller.dart';
import 'package:sum_academy/modules/student/controllers/student_certificates_controller.dart';
import 'package:sum_academy/modules/student/controllers/student_announcements_controller.dart';
import 'package:sum_academy/modules/student/controllers/student_explore_courses_controller.dart';
import 'package:sum_academy/modules/student/controllers/student_payments_controller.dart';
import 'package:sum_academy/modules/student/controllers/student_quizzes_controller.dart';
import 'package:sum_academy/modules/student/controllers/student_shell_controller.dart';
import 'package:sum_academy/modules/student/controllers/student_settings_controller.dart';
import 'package:sum_academy/modules/student/controllers/student_support_controller.dart';
import 'package:sum_academy/modules/student/services/student_announcements_service.dart';
import 'package:sum_academy/modules/student/services/student_certificates_service.dart';
import 'package:sum_academy/modules/student/services/student_courses_service.dart';
import 'package:sum_academy/modules/student/services/student_explore_courses_service.dart';
import 'package:sum_academy/modules/student/services/student_payments_service.dart';
import 'package:sum_academy/modules/student/services/student_quiz_service.dart';
import 'package:sum_academy/modules/student/services/student_settings_service.dart';
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
    if (!Get.isRegistered<StudentCertificatesService>()) {
      Get.lazyPut<StudentCertificatesService>(
        StudentCertificatesService.new,
        fenix: true,
      );
    }
    if (!Get.isRegistered<StudentCertificatesController>()) {
      Get.lazyPut<StudentCertificatesController>(
        () => StudentCertificatesController(Get.find<StudentCertificatesService>()),
      );
    }
    if (!Get.isRegistered<StudentAnnouncementsService>()) {
      Get.lazyPut<StudentAnnouncementsService>(
        StudentAnnouncementsService.new,
        fenix: true,
      );
    }
    if (!Get.isRegistered<StudentAnnouncementsController>()) {
      Get.put(
        StudentAnnouncementsController(
          Get.find<StudentAnnouncementsService>(),
        ),
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
    if (!Get.isRegistered<StudentPaymentsService>()) {
      Get.lazyPut<StudentPaymentsService>(
        StudentPaymentsService.new,
        fenix: true,
      );
    }
    if (!Get.isRegistered<StudentPaymentsController>()) {
      Get.lazyPut<StudentPaymentsController>(
        () => StudentPaymentsController(Get.find<StudentPaymentsService>()),
      );
    }
    if (!Get.isRegistered<StudentSettingsService>()) {
      Get.lazyPut<StudentSettingsService>(
        StudentSettingsService.new,
        fenix: true,
      );
    }
    if (!Get.isRegistered<StudentSettingsController>()) {
      Get.lazyPut<StudentSettingsController>(
        () => StudentSettingsController(Get.find<StudentSettingsService>()),
      );
    }
    if (!Get.isRegistered<StudentQuizService>()) {
      Get.lazyPut<StudentQuizService>(StudentQuizService.new, fenix: true);
    }
    if (!Get.isRegistered<StudentQuizzesController>()) {
      Get.lazyPut<StudentQuizzesController>(
        () => StudentQuizzesController(Get.find<StudentQuizService>()),
      );
    }
  }
}
