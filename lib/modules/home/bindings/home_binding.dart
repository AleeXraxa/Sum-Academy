import 'package:get/get.dart';
import 'package:sum_academy/modules/home/controllers/home_controller.dart';
import 'package:sum_academy/modules/home/services/home_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeService>(HomeService.new);
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<HomeService>()),
    );
  }
}

