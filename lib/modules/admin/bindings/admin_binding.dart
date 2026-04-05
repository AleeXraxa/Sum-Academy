import 'package:get/get.dart';
import 'package:sum_academy/modules/admin/controllers/admin_controller.dart';
import 'package:sum_academy/modules/admin/controllers/admin_class_controller.dart';
import 'package:sum_academy/modules/admin/controllers/admin_course_controller.dart';
import 'package:sum_academy/modules/admin/controllers/admin_payments_controller.dart';
import 'package:sum_academy/modules/admin/controllers/admin_student_controller.dart';
import 'package:sum_academy/modules/admin/controllers/admin_teacher_controller.dart';
import 'package:sum_academy/modules/admin/services/admin_activity_service.dart';
import 'package:sum_academy/modules/admin/services/admin_class_service.dart';
import 'package:sum_academy/modules/admin/services/admin_course_service.dart';
import 'package:sum_academy/modules/admin/services/admin_installment_service.dart';
import 'package:sum_academy/modules/admin/services/admin_payment_service.dart';
import 'package:sum_academy/modules/admin/services/admin_stats_service.dart';
import 'package:sum_academy/modules/admin/services/admin_student_service.dart';
import 'package:sum_academy/modules/admin/services/admin_teacher_service.dart';
import 'package:sum_academy/modules/admin/services/admin_user_service.dart';
import 'package:sum_academy/modules/admin/services/student_profile_service.dart';
import 'package:sum_academy/modules/admin/services/teacher_profile_service.dart';
import 'package:sum_academy/modules/admin/services/user_profile_service.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminUserService>(() => AdminUserService(), fenix: true);
    Get.lazyPut<AdminTeacherService>(() => AdminTeacherService(), fenix: true);
    Get.lazyPut<AdminStudentService>(() => AdminStudentService(), fenix: true);
    Get.lazyPut<AdminCourseService>(() => AdminCourseService(), fenix: true);
    Get.lazyPut<AdminClassService>(() => AdminClassService(), fenix: true);
    Get.lazyPut<AdminPaymentService>(() => AdminPaymentService(), fenix: true);
    Get.lazyPut<AdminInstallmentService>(
      () => AdminInstallmentService(),
      fenix: true,
    );
    Get.lazyPut<StudentProfileService>(() => StudentProfileService(), fenix: true);
    Get.lazyPut<UserProfileService>(() => UserProfileService(), fenix: true);
    Get.lazyPut<TeacherProfileService>(() => TeacherProfileService(), fenix: true);
    Get.lazyPut<AdminActivityService>(() => AdminActivityService(), fenix: true);
    Get.lazyPut<AdminStatsService>(() => AdminStatsService(), fenix: true);
    Get.lazyPut<AdminController>(() => AdminController());
    Get.lazyPut<AdminPaymentsController>(() => AdminPaymentsController());
    Get.lazyPut<AdminTeacherController>(() => AdminTeacherController());
    Get.lazyPut<AdminStudentController>(() => AdminStudentController());
    Get.lazyPut<AdminCourseController>(() => AdminCourseController());
    Get.lazyPut<AdminClassController>(() => AdminClassController());
  }
}
