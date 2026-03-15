import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/modules/auth/controllers/register_controller.dart';
import 'package:sum_academy/modules/auth/widgets/auth_action_button.dart';
import 'package:sum_academy/modules/auth/widgets/auth_card.dart';
import 'package:sum_academy/modules/auth/widgets/auth_footer_link.dart';
import 'package:sum_academy/modules/auth/widgets/auth_header.dart';
import 'package:sum_academy/modules/auth/widgets/auth_scaffold.dart';
import 'package:sum_academy/modules/auth/widgets/auth_text_field.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.onSurface;

    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: controller.goToLogin,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          SizedBox(height: 8.h),
          const AuthHeader(
            title: 'Create your account',
            subtitle: 'Join Sum Academy and launch your learning workspace.',
          ),
          SizedBox(height: 20.h),
          AuthCard(
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  AuthTextField(
                    controller: controller.nameController,
                    label: 'Full name',
                    hint: 'Alee Khan',
                    icon: Icons.person_outline_rounded,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Full name is required.';
                      }
                      if (value.trim().length < 2) {
                        return 'Enter a valid name.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 14.h),
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
                      hint: 'Create a password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: controller.isPasswordHidden.value,
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
                  SizedBox(height: 14.h),
                  Obx(() {
                    return AuthTextField(
                      controller: controller.confirmPasswordController,
                      label: 'Confirm password',
                      hint: 'Re-enter your password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: controller.isConfirmHidden.value,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => controller.register(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password.';
                        }
                        if (value != controller.passwordController.text) {
                          return 'Passwords do not match.';
                        }
                        return null;
                      },
                      suffix: IconButton(
                        onPressed: controller.toggleConfirmPassword,
                        icon: Icon(
                          controller.isConfirmHidden.value
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 10.h),
                  Text(
                    'By creating an account, you agree to the terms and privacy policy.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: baseColor.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Obx(() {
                    return AuthActionButton(
                      label: 'Create Account',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.register,
                      icon: Icons.person_add_alt_1_rounded,
                    );
                  }),
                ],
              ),
            ),
          ),
          SizedBox(height: 18.h),
          AuthFooterLink(
            prompt: 'Already have an account?',
            actionLabel: 'Sign in',
            onTap: controller.goToLogin,
          ),
        ],
      ),
    );
  }
}
