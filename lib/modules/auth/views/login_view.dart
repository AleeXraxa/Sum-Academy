import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/auth/controllers/login_controller.dart';
import 'package:sum_academy/modules/auth/widgets/auth_action_button.dart';
import 'package:sum_academy/modules/auth/widgets/auth_card.dart';
import 'package:sum_academy/modules/auth/widgets/auth_footer_link.dart';
import 'package:sum_academy/modules/auth/widgets/auth_header.dart';
import 'package:sum_academy/modules/auth/widgets/auth_scaffold.dart';
import 'package:sum_academy/modules/auth/widgets/auth_social_button.dart';
import 'package:sum_academy/modules/auth/widgets/auth_text_field.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.onSurface;

    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: _BrandRow()),
          SizedBox(height: 16.h),
          const AuthHeader(
            title: 'Welcome back',
            subtitle: 'Sign in to manage classes, students, and learning paths.',
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
                  Obx(() {
                    return AuthTextField(
                      controller: controller.passwordController,
                      label: 'Password',
                      hint: 'Enter your password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: controller.isPasswordHidden.value,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => controller.signIn(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required.';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters.';
                        }
                        return null;
                      },
                      suffix: IconButton(
                        onPressed: controller.togglePassword,
                        icon: Icon(
                          controller.isPasswordHidden.value
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 6.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Use at least 6 characters.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: baseColor.withOpacity(0.55),
                          ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Obx(() {
                        return Checkbox(
                          value: controller.rememberMe.value,
                          onChanged: controller.setRememberMe,
                        );
                      }),
                      Text(
                        'Remember me',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: baseColor.withOpacity(0.65),
                            ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: controller.goToForgotPassword,
                        child: const Text('Forgot password?'),
                      ),
                    ],
                  ),
                  Divider(color: SumAcademyTheme.brandBluePale, height: 24.h),
                  Obx(() {
                    return AuthActionButton(
                      label: 'Sign In',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.signIn,
                      icon: Icons.login_rounded,
                    );
                  }),
                  SizedBox(height: 12.h),
                  _OrDivider(baseColor: baseColor),
                  SizedBox(height: 12.h),
                  AuthSocialButton(
                    label: 'Continue with Google',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 18.h),
          AuthFooterLink(
            prompt: 'New to Sum Academy?',
            actionLabel: 'Create account',
            onTap: controller.goToRegister,
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

class _OrDivider extends StatelessWidget {
  final Color baseColor;

  const _OrDivider({required this.baseColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: SumAcademyTheme.brandBluePale)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text(
            'or',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: baseColor.withOpacity(0.5),
                ),
          ),
        ),
        Expanded(child: Divider(color: SumAcademyTheme.brandBluePale)),
      ],
    );
  }
}
