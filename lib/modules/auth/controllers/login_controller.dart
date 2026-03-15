import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/routes/app_routes.dart';
import 'package:sum_academy/modules/auth/services/auth_service.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordHidden = true.obs;
  final isLoading = false.obs;

  AuthService get _authService => Get.find<AuthService>();

  void togglePassword() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> signIn() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text;

    isLoading.value = true;
    try {
      await _authService.signIn(email: email, password: password);
      Get.offAllNamed(AppRoutes.home);
    } finally {
      isLoading.value = false;
    }
  }

  void goToRegister() {
    Get.toNamed(AppRoutes.register);
  }

  void goToForgotPassword() {
    Get.toNamed(AppRoutes.forgotPassword);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
