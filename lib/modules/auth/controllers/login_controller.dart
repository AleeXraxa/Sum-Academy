import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sum_academy/app/routes/app_routes.dart';
import 'package:sum_academy/modules/admin/bindings/admin_binding.dart';
import 'package:sum_academy/modules/admin/views/admin_dashboard_view.dart';
import 'package:sum_academy/modules/auth/services/auth_service.dart';
import 'package:sum_academy/modules/home/bindings/home_binding.dart';
import 'package:sum_academy/modules/home/views/home_view.dart';

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
      Get.snackbar('Login success', 'Welcome back!');
      await _routeByRole();
    } on FirebaseAuthException catch (e) {
      final message = _friendlyAuthMessage(e);
      Get.snackbar('Login failed', message);
    } catch (_) {
      Get.snackbar('Login failed', 'Please try again.');
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
        Get.snackbar('Google sign-in', 'Sign-in cancelled.');
        return;
      }
      Get.snackbar('Login success', 'Welcome back!');
      await _routeByRole();
    } on FirebaseAuthException catch (e) {
      final message = _friendlyAuthMessage(e);
      Get.snackbar('Login failed', message);
    } catch (_) {
      Get.snackbar('Login failed', 'Please try again.');
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

  Future<void> _routeByRole() async {
    final role = await _authService.getCurrentUserRole();
    if (role == 'admin') {
      Get.offAll(
        () => const AdminDashboardView(),
        binding: AdminBinding(),
      );
    } else {
      Get.offAll(
        () => const HomeView(),
        binding: HomeBinding(),
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
