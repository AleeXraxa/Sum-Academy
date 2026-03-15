import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/routes/app_routes.dart';
import 'package:sum_academy/modules/onboarding/data/onboarding_content.dart';
import 'package:sum_academy/modules/onboarding/models/onboarding_page.dart';

class OnboardingController extends GetxController {
  final RxInt pageIndex = 0.obs;
  late final PageController pageController;

  List<OnboardingPageData> get pages => onboardingPages;

  bool get isLastPage => pageIndex.value == pages.length - 1;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  void onPageChanged(int index) {
    pageIndex.value = index;
  }

  void nextPage() {
    if (isLastPage) {
      finish();
      return;
    }

    pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void skip() {
    finish();
  }

  void finish() {
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
