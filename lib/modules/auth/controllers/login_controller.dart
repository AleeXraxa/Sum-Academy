import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sum_academy/app/routes/app_routes.dart';
import 'package:sum_academy/core/services/maintenance_service.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';

import 'package:sum_academy/modules/auth/services/auth_service.dart';
import 'package:sum_academy/modules/maintenance/bindings/maintenance_binding.dart';
import 'package:sum_academy/modules/maintenance/views/maintenance_view.dart';
import 'package:sum_academy/modules/student/bindings/student_binding.dart';
import 'package:sum_academy/modules/student/views/student_shell_view.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordHidden = true.obs;
  final isLoading = false.obs;
  final rememberMe = false.obs;

  AuthService get _authService => Get.find<AuthService>();

  void togglePassword() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void setRememberMe(bool? value) {
    rememberMe.value = value ?? false;
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
      await _routeByRole();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        await _showNoInternetDialog();
        return;
      }
      if (e.code == 'device-ip-mismatch' || e.code == 'device-mismatch') {
        final dialogContext = Get.context ?? Get.key.currentContext;
        if (dialogContext != null) {
          await showDeviceBlockedDialog(dialogContext);
        }
        return;
      }
      final message = _friendlyAuthMessage(e);
      await showAppErrorDialog(title: 'Login failed', message: message);
    } catch (_) {
      await showAppErrorDialog(
        title: 'Login failed',
        message: 'Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      final signedIn = await _authService.signInWithGoogle();
      if (!signedIn) {
        return;
      }
      await _routeByRole();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        await _showNoInternetDialog();
        return;
      }
      if (e.code == 'device-ip-mismatch' || e.code == 'device-mismatch') {
        final dialogContext = Get.context ?? Get.key.currentContext;
        if (dialogContext != null) {
          await showDeviceBlockedDialog(dialogContext);
        }
        return;
      }
      final message = _friendlyAuthMessage(e);
      await showAppErrorDialog(title: 'Login failed', message: message);
    } catch (_) {
      await showAppErrorDialog(
        title: 'Login failed',
        message: 'Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _friendlyAuthMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'account-exists-with-different-credential':
      case 'credential-already-in-use':
        return 'This email is linked to a different sign-in method.';
      case 'device-ip-mismatch':
      case 'device-mismatch':
        return 'Access denied. This account is locked to another device.';
      case 'ip-check-failed':
        return 'Unable to verify your device. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Unable to sign in. Please try again.';
    }
  }

  void goToRegister() {
    Get.toNamed(AppRoutes.register);
  }

  void goToForgotPassword() {
    Get.toNamed(AppRoutes.forgotPassword);
  }

  Future<void> _showNoInternetDialog() async {
    await showNoInternetDialogOnce();
  }

  Future<void> _routeByRole() async {
    final role = await _authService.getCurrentUserRole();
    if (role == 'admin' || role == 'teacher') {
      await _authService.logout();
      await showAppErrorDialog(
        title: 'Access Restricted',
        message: 'This platform is only for Student, for your role use Web Portal',
      );
      return;
    } else {
      try {
        final status = await Get.find<MaintenanceService>().fetchStatus();
        if (status.enabled) {
          Get.offAll(
            () => const MaintenanceView(),
            binding: MaintenanceBinding(),
          );
          return;
        }
      } catch (_) {}
      Get.offAll(
        () => const StudentShellView(),
        binding: StudentBinding(),
      );
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
