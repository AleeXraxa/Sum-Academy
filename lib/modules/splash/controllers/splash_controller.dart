import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/routes/app_routes.dart';
import 'package:sum_academy/modules/admin/bindings/admin_binding.dart';
import 'package:sum_academy/modules/admin/views/admin_dashboard_view.dart';
import 'package:sum_academy/modules/auth/services/auth_service.dart';
import 'package:sum_academy/modules/home/bindings/home_binding.dart';
import 'package:sum_academy/modules/home/views/home_view.dart';

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

    if (role == 'admin') {
      Get.offAll(
        () => const AdminDashboardView(),
        binding: AdminBinding(),
      );
    } else {
      Get.offAll(
        () => const HomeView(),
        binding: HomeBinding(),
      );
    }
  }

  @override
  void onClose() {
    _redirectTimer?.cancel();
    animationController.dispose();
    super.onClose();
  }
}
