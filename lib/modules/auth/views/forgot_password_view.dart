import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/auth/controllers/forgot_password_controller.dart';
import 'package:sum_academy/modules/auth/widgets/auth_action_button.dart';
import 'package:sum_academy/modules/auth/widgets/auth_card.dart';
import 'package:sum_academy/modules/auth/widgets/auth_header.dart';
import 'package:sum_academy/modules/auth/widgets/auth_scaffold.dart';
import 'package:sum_academy/modules/auth/widgets/auth_text_field.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

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
            title: 'Reset your password',
            subtitle:
                'Enter your email and we will send a verification code to continue.',
          ),
          SizedBox(height: 20.h),
          AuthCard(
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  AuthTextField(
                    controller: controller.emailController,
                    label: 'Email address',
                    hint: 'you@sumacademy.com',
                    icon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => controller.sendResetCode(),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required.';
                      }
                      if (!GetUtils.isEmail(value.trim())) {
                        return 'Enter a valid email address.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 14.h),
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: SumAcademyTheme.infoLight,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: SumAcademyTheme.info.withOpacityFloat(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_reset_rounded,
                            color: SumAcademyTheme.info, size: 20.r),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'We will deliver a 6-digit code to verify your identity.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: baseColor.withOpacityFloat(0.7),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Divider(color: SumAcademyTheme.brandBluePale, height: 24.h),
                  Obx(() {
                    return AuthActionButton(
                      label: 'Send Verification Code',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.sendResetCode,
                      icon: Icons.mark_email_read_rounded,
                    );
                  }),
                ],
              ),
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


