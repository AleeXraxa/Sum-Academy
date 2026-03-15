import 'package:get/get.dart';
import 'package:sum_academy/modules/auth/services/auth_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
  }
}
