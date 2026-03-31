import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';
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
      Get.snackbar(
        'Email sent',
        'Check your inbox for the password reset link.',
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        await _showNoInternetDialog();
        return;
      }
      Get.snackbar('Reset failed', e.message ?? 'Please try again.');
    } catch (_) {
      Get.snackbar('Reset failed', 'Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _showNoInternetDialog() async {
    final context = Get.context;
    if (context == null) {
      Get.snackbar(
        'No internet',
        'Please check your connection and try again.',
      );
      return;
    }
    await showNoInternetDialog(context);
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
