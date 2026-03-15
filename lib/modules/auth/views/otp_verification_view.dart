import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/auth/controllers/otp_controller.dart';
import 'package:sum_academy/modules/auth/widgets/auth_action_button.dart';
import 'package:sum_academy/modules/auth/widgets/auth_card.dart';
import 'package:sum_academy/modules/auth/widgets/auth_header.dart';
import 'package:sum_academy/modules/auth/widgets/auth_scaffold.dart';
import 'package:sum_academy/modules/auth/widgets/otp_input.dart';

class OtpVerificationView extends GetView<OtpController> {
  const OtpVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.onSurface;

    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              SizedBox(width: 6.w),
              Expanded(child: Center(child: _BrandRow())),
              SizedBox(width: 48.w),
            ],
          ),
          SizedBox(height: 16.h),
          const AuthHeader(
            title: 'Verify your code',
            subtitle:
                'Enter the 6-digit code we sent to your email to continue.',
          ),
          SizedBox(height: 20.h),
          AuthCard(
            child: Column(
              children: [
                OtpInput(
                  controllers: controller.codeControllers,
                  focusNodes: controller.focusNodes,
                  onChanged: controller.onDigitChanged,
                ),
                Obx(() {
                  final message = controller.errorMessage.value;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: message.isEmpty
                        ? const SizedBox(height: 8)
                        : Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              message,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          ),
                  );
                }),
                SizedBox(height: 10.h),
                Obx(() {
                  return Text(
                    controller.secondsRemaining.value > 0
                        ? 'Resend available in ${controller.formattedTimer}'
                        : 'Didn\'t receive it?',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: baseColor.withOpacityFloat(0.6),
                        ),
                  );
                }),
                SizedBox(height: 6.h),
                Obx(() {
                  final canResend = controller.secondsRemaining.value == 0;
                  return TextButton(
                    onPressed: canResend ? controller.resendCode : null,
                    child: Text(canResend ? 'Resend Code' : 'Please wait'),
                  );
                }),
                SizedBox(height: 8.h),
                Divider(color: SumAcademyTheme.brandBluePale, height: 24.h),
                Obx(() {
                  return AuthActionButton(
                    label: 'Verify & Continue',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.verify,
                    icon: Icons.verified_rounded,
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'After verification, you will be taken back to sign in.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: baseColor.withOpacityFloat(0.55),
                ),
          ),
        ],
      ),
    );
  }
}
class _BrandRow extends StatelessWidget {
  const _BrandRow();

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.onSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44.r,
          height: 44.r,
          decoration: BoxDecoration(
            color: SumAcademyTheme.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: SumAcademyTheme.brandBluePale),
            boxShadow: [
              BoxShadow(
                color: SumAcademyTheme.brandBlue.withOpacityFloat(0.12),
                blurRadius: 16.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.asset('assets/logo.jpeg', fit: BoxFit.cover),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          'Sum Academy LMS',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: baseColor,
              ),
        ),
      ],
    );
  }
}


