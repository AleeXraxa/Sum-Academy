import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sum_academy/core/utils/network_error.dart';
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
      await showAppSuccessDialog(
        title: 'Email sent',
        message: 'Check your inbox for the password reset link.',
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        await _showNoInternetDialog();
        return;
      }
      await showAppErrorDialog(
        title: 'Reset failed',
        message: e.message ?? 'Please try again.',
      );
    } catch (_) {
      await showAppErrorDialog(
        title: 'Reset failed',
        message: 'Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _showNoInternetDialog() async {
    await showNoInternetDialogOnce();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
