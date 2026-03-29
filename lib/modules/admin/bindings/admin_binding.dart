import 'package:get/get.dart';
import 'package:sum_academy/modules/admin/controllers/admin_controller.dart';
import 'package:sum_academy/modules/admin/services/admin_user_service.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminUserService>(() => AdminUserService(), fenix: true);
    Get.lazyPut<AdminController>(() => AdminController());
  }
}
