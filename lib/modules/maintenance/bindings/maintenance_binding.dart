import 'package:get/get.dart';
import 'package:sum_academy/core/services/maintenance_service.dart';
import 'package:sum_academy/modules/auth/services/auth_service.dart';
import 'package:sum_academy/modules/maintenance/controllers/maintenance_controller.dart';

class MaintenanceBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MaintenanceController>()) {
      Get.put(
        MaintenanceController(
          Get.find<MaintenanceService>(),
          Get.find<AuthService>(),
        ),
      );
    }
  }
}

