import 'package:get/get.dart';
import 'package:sum_academy/modules/auth/services/auth_service.dart';
import 'package:sum_academy/modules/home/controllers/home_controller.dart';
import 'package:sum_academy/modules/home/services/home_service.dart';
import 'package:sum_academy/modules/student/controllers/student_shell_controller.dart';

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
  }
}
