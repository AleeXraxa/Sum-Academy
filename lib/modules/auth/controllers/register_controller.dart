import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/routes/app_routes.dart';
import 'package:sum_academy/modules/auth/services/auth_service.dart';

class RegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isPasswordHidden = true.obs;
  final isConfirmHidden = true.obs;
  final isLoading = false.obs;

  AuthService get _authService => Get.find<AuthService>();

  void togglePassword() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPassword() {
    isConfirmHidden.value = !isConfirmHidden.value;
  }

  Future<void> register() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    isLoading.value = true;
    try {
      await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      Get.offAllNamed(AppRoutes.otp);
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() {
    Get.back();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
