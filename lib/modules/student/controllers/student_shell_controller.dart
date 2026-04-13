import 'dart:async';

import 'package:get/get.dart';
import 'package:sum_academy/core/services/maintenance_service.dart';
import 'package:sum_academy/modules/auth/services/auth_service.dart';
import 'package:sum_academy/modules/maintenance/bindings/maintenance_binding.dart';
import 'package:sum_academy/modules/maintenance/views/maintenance_view.dart';
import 'package:sum_academy/modules/student/utils/student_navigation.dart';

class StudentShellController extends GetxController {
  StudentShellController(this._authService, this._maintenanceService);

  final AuthService _authService;
  final MaintenanceService _maintenanceService;

  final navIndex = 0.obs;
  final activeLabel = studentNavItems.first.obs;
  final userName = 'Student'.obs;

  Timer? _maintenanceTimer;
  bool _maintenanceCheckRunning = false;

  @override
  void onInit() {
    super.onInit();
    _loadUserName();
    _startMaintenanceWatcher();
  }

  @override
  void onClose() {
    _maintenanceTimer?.cancel();
    super.onClose();
  }

  Future<void> _loadUserName() async {
    userName.value = await _authService.getCurrentUserName();
  }

  void _startMaintenanceWatcher() {
    _maintenanceTimer?.cancel();
    _maintenanceTimer = Timer.periodic(const Duration(seconds: 60), (_) async {
      if (_maintenanceCheckRunning) return;
      _maintenanceCheckRunning = true;
      try {
        final status = await _maintenanceService.fetchStatus();
        if (status.enabled) {
          Get.offAll(
            () => const MaintenanceView(),
            binding: MaintenanceBinding(),
          );
        }
      } catch (_) {
        // Ignore transient errors.
      } finally {
        _maintenanceCheckRunning = false;
      }
    });
  }

  void setNavIndex(int index) {
    navIndex.value = index;
    activeLabel.value = studentActiveLabelForIndex(index);
  }

  void setActiveLabel(String label) {
    final index = studentNavIndexForLabel(label);
    if (index == null) {
      return;
    }
    navIndex.value = index;
    activeLabel.value = label;
  }
}
