import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:sum_academy/modules/onboarding/widgets/onboarding_indicator.dart';
import 'package:sum_academy/modules/onboarding/widgets/onboarding_slide.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: SumAcademyTheme.surfaceSecondary,
      body: SafeArea(
        child: Stack(
          children: [
            const _OnboardingBackdrop(),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 6.h),
                  child: Row(
                    children: [
                      _BrandPill(),
                      const Spacer(),
                      TextButton(
                        onPressed: controller.skip,
                        style: TextButton.styleFrom(
                          foregroundColor:
                              SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                        ),
                        child: const Text('Skip'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: controller.pageController,
                    itemCount: controller.pages.length,
                    onPageChanged: controller.onPageChanged,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return OnboardingSlide(data: controller.pages[index]);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 22.h),
                  child: Obx(() {
                    final activeColor =
                        controller.pages[controller.pageIndex.value].accent;
                    final isLast = controller.isLastPage;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OnboardingIndicator(
                          count: controller.pages.length,
                          index: controller.pageIndex.value,
                          activeColor: activeColor,
                          inactiveColor:
                              SumAcademyTheme.darkBase.withOpacityFloat(0.12),
                        ),
                        SizedBox(height: 18.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: controller.nextPage,
                            icon: Icon(
                              isLast
                                  ? Icons.check_circle_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 18.r,
                            ),
                            label: Text(
                              isLast ? 'Get Started' : 'Next',
                              style: theme.textTheme.labelLarge
                                  ?.copyWith(color: SumAcademyTheme.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: SumAcademyTheme.white,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
        boxShadow: [
          BoxShadow(
            color: SumAcademyTheme.brandBlue.withOpacityFloat(0.08),
            blurRadius: 18.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.r,
            height: 8.r,
            decoration: const BoxDecoration(
              color: SumAcademyTheme.brandBlue,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'Sum Academy LMS',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: SumAcademyTheme.darkBase,
                ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingBackdrop extends StatelessWidget {
  const _OnboardingBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              SumAcademyTheme.white,
              SumAcademyTheme.surfaceSecondary,
              SumAcademyTheme.brandBluePale.withOpacityFloat(0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}
