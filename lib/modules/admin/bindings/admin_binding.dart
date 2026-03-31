import 'package:get/get.dart';
import 'package:sum_academy/modules/admin/controllers/admin_controller.dart';
import 'package:sum_academy/modules/admin/controllers/admin_student_controller.dart';
import 'package:sum_academy/modules/admin/controllers/admin_teacher_controller.dart';
import 'package:sum_academy/modules/admin/services/admin_activity_service.dart';
import 'package:sum_academy/modules/admin/services/admin_stats_service.dart';
import 'package:sum_academy/modules/admin/services/admin_student_service.dart';
import 'package:sum_academy/modules/admin/services/admin_teacher_service.dart';
import 'package:sum_academy/modules/admin/services/admin_user_service.dart';
import 'package:sum_academy/modules/admin/services/student_profile_service.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminUserService>(() => AdminUserService(), fenix: true);
    Get.lazyPut<AdminTeacherService>(() => AdminTeacherService(), fenix: true);
    Get.lazyPut<AdminStudentService>(() => AdminStudentService(), fenix: true);
    Get.lazyPut<StudentProfileService>(() => StudentProfileService(), fenix: true);
    Get.lazyPut<AdminActivityService>(() => AdminActivityService(), fenix: true);
    Get.lazyPut<AdminStatsService>(() => AdminStatsService(), fenix: true);
    Get.lazyPut<AdminController>(() => AdminController());
    Get.lazyPut<AdminTeacherController>(() => AdminTeacherController());
    Get.lazyPut<AdminStudentController>(() => AdminStudentController());
  }
}
