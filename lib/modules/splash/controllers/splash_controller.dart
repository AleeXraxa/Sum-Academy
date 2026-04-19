import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/routes/app_routes.dart';
import 'package:sum_academy/core/services/maintenance_service.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/auth/services/auth_service.dart';
import 'package:sum_academy/modules/maintenance/bindings/maintenance_binding.dart';
import 'package:sum_academy/modules/maintenance/views/maintenance_view.dart';
import 'package:sum_academy/modules/student/bindings/student_binding.dart';
import 'package:sum_academy/modules/student/views/student_shell_view.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<double> logoScale;
  late final Animation<double> logoFade;
  late final Animation<Offset> logoSlide;
  late final Animation<Offset> nameSlide;
  late final Animation<double> nameFade;
  late final Animation<double> loaderFade;
  Timer? _redirectTimer;

  AuthService get _authService => Get.find<AuthService>();
  MaintenanceService get _maintenanceService => Get.find<MaintenanceService>();

  @override
  void onInit() {
    super.onInit();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    logoScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    logoSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: animationController,
            curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
          ),
        );

    nameSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: animationController,
            curve: const Interval(0.3, 0.85, curve: Curves.easeOutCubic),
          ),
        );

    nameFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.3, 0.85, curve: Curves.easeOut),
      ),
    );

    loaderFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
      ),
    );

    animationController.forward();

    _redirectTimer = Timer(const Duration(milliseconds: 5000), () {
      _handleRedirect();
    });
  }

  Future<void> _handleRedirect() async {
    if (isClosed || Get.currentRoute != AppRoutes.splash) {
      return;
    }

    final user = _authService.currentUser;
    if (user == null) {
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

    final role = await _authService.getCurrentUserRole();
    if (isClosed) {
      return;
    }

    if (role == 'admin' || role == 'teacher') {
      await _authService.logout();
      Get.offAllNamed(AppRoutes.login);
      Future.delayed(const Duration(milliseconds: 300), () {
        showAppErrorDialog(
          title: 'Access Restricted',
          message:
              'This platform is only for Student, for your role use Web Portal',
        );
      });
      return;
    } else {
      final maintenanceEnabled = await _isMaintenanceEnabled();
      if (maintenanceEnabled) {
        Get.offAll(
          () => const MaintenanceView(),
          binding: MaintenanceBinding(),
        );
        return;
      }
      Get.offAll(() => const StudentShellView(), binding: StudentBinding());
    }
  }

  Future<bool> _isMaintenanceEnabled() async {
    try {
      final status = await _maintenanceService.fetchStatus();
      return status.enabled;
    } catch (_) {
      return false;
    }
  }

  @override
  void onClose() {
    _redirectTimer?.cancel();
    animationController.dispose();
    super.onClose();
  }
}
