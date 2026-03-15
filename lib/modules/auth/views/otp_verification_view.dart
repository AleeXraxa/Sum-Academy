import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          SizedBox(height: 8.h),
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
                SizedBox(height: 14.h),
                Obx(() {
                  return Text(
                    controller.secondsRemaining.value > 0
                        ? 'Resend available in ${controller.formattedTimer}'
                        : 'Didn\'t receive it?',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: baseColor.withOpacity(0.6),
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
                SizedBox(height: 12.h),
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
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: baseColor.withOpacity(0.55)),
          ),
        ],
      ),
    );
  }
}
