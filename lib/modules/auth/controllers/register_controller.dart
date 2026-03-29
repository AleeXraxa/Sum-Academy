import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sum_academy/modules/admin/bindings/admin_binding.dart';
import 'package:sum_academy/modules/admin/views/admin_dashboard_view.dart';
import 'package:sum_academy/modules/auth/services/auth_service.dart';
import 'package:sum_academy/modules/home/bindings/home_binding.dart';
import 'package:sum_academy/modules/home/views/home_view.dart';

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
      await _authService.register(name: name, email: email, password: password);
      Get.snackbar('Register success', 'Welcome to Sum Academy!');
      await _routeByRole();
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Register failed', e.message ?? 'Please try again.');
    } catch (_) {
      Get.snackbar('Register failed', 'Please try again.');
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
      Get.snackbar('Signed in', 'Welcome to Sum Academy!');
      await _routeByRole();
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Sign-in failed', e.message ?? 'Please try again.');
    } catch (_) {
      Get.snackbar('Sign-in failed', 'Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() {
    Get.back();
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
