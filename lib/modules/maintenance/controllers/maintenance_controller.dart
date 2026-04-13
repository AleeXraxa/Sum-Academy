import 'dart:async';

import 'package:get/get.dart';
import 'package:sum_academy/app/routes/app_routes.dart';
import 'package:sum_academy/core/services/maintenance_service.dart';
import 'package:sum_academy/modules/admin/bindings/admin_binding.dart';
import 'package:sum_academy/modules/admin/views/admin_shell_view.dart';
import 'package:sum_academy/modules/auth/services/auth_service.dart';
import 'package:sum_academy/modules/student/bindings/student_binding.dart';
import 'package:sum_academy/modules/student/views/student_shell_view.dart';

class MaintenanceController extends GetxController {
  MaintenanceController(this._maintenanceService, this._authService);

  final MaintenanceService _maintenanceService;
  final AuthService _authService;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<MaintenanceStatus> status =
      const MaintenanceStatus(enabled: false, message: '').obs;

  Timer? _pollTimer;

  @override
  void onInit() {
    super.onInit();
    loadStatus();
    // Poll so students automatically get back in when maintenance is turned off.
    _pollTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      loadStatus(silent: true);
    });
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }

  Future<void> loadStatus({bool silent = false}) async {
    if (!silent) {
      isLoading.value = true;
      errorMessage.value = '';
    }
    try {
      final next = await _maintenanceService.fetchStatus();
      status.value = next;
      if (!next.enabled) {
        await _exitMaintenanceIfPossible();
      }
    } catch (e) {
      if (!silent) {
        errorMessage.value = 'Unable to load maintenance status.';
      }
    } finally {
      if (!silent) {
        isLoading.value = false;
      }
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed(AppRoutes.onboarding);
  }

  Future<void> _exitMaintenanceIfPossible() async {
    final user = _authService.currentUser;
    if (user == null) {
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }
    final role = await _authService.getCurrentUserRole();
    if (role == 'admin') {
      Get.offAll(
        () => const AdminShellView(),
        binding: AdminBinding(),
      );
    } else {
      Get.offAll(
        () => const StudentShellView(),
        binding: StudentBinding(),
      );
    }
  }
}

