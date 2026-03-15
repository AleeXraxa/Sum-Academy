import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/routes/app_routes.dart';
import 'package:sum_academy/modules/auth/services/auth_service.dart';

class ForgotPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final isLoading = false.obs;

  AuthService get _authService => Get.find<AuthService>();

  Future<void> sendResetCode() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    final email = emailController.text.trim();

    isLoading.value = true;
    try {
      await _authService.requestPasswordReset(email: email);
      Get.toNamed(AppRoutes.otp);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
