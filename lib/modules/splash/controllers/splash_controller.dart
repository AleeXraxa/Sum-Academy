import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/routes/app_routes.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<double> logoScale;
  late final Animation<double> logoFade;
  late final Animation<Offset> logoSlide;
  late final Animation<Offset> nameSlide;
  late final Animation<double> nameFade;
  late final Animation<double> loaderFade;

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

    Future.delayed(const Duration(milliseconds: 5000), () {
      if (Get.currentRoute == AppRoutes.splash) {
        Get.offAllNamed(AppRoutes.onboarding);
      }
    });
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
