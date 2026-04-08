import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sum_academy/app/routes/app_routes.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/admin/bindings/admin_binding.dart';
import 'package:sum_academy/modules/admin/views/admin_shell_view.dart';
import 'package:sum_academy/modules/auth/services/auth_service.dart';
import 'package:sum_academy/modules/student/bindings/student_binding.dart';
import 'package:sum_academy/modules/student/views/student_shell_view.dart';

class OtpController extends GetxController {
  static const int codeLength = 6;

  late final List<TextEditingController> codeControllers;
  late final List<FocusNode> focusNodes;

  final isLoading = false.obs;
  final secondsRemaining = 30.obs;
  final errorMessage = ''.obs;

  Timer? _timer;
  String _flow = 'register';
  String _email = '';
  String _name = '';
  String _password = '';

  AuthService get _authService => Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    codeControllers = List.generate(
      codeLength,
      (_) => TextEditingController(),
    );
    focusNodes = List.generate(codeLength, (_) => FocusNode());
    _loadArguments();
    _startTimer();
  }

  void onDigitChanged(int index, String value) {
    if (errorMessage.value.isNotEmpty) {
      errorMessage.value = '';
    }

    if (value.isNotEmpty && index < codeLength - 1) {
      focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  String get code => codeControllers.map((c) => c.text).join();

  String get formattedTimer {
    final seconds = secondsRemaining.value;
    return '00:${seconds.toString().padLeft(2, '0')}';
  }

  bool get isRegisterFlow => _flow == 'register';

  String get subtitleText {
    if (isRegisterFlow) {
      final masked = _email.isNotEmpty ? _email : 'your email';
      return 'Enter the 6-digit code we sent to $masked to create your account.';
    }
    return 'Enter the 6-digit code we sent to your email to continue.';
  }

  String get footerText {
    if (isRegisterFlow) {
      return 'After verification, your account will be created automatically.';
    }
    return 'After verification, you will be taken back to sign in.';
  }

  String get actionLabel {
    return isRegisterFlow ? 'Verify & Create Account' : 'Verify & Continue';
  }

  Future<void> verify() async {
    if (code.length != codeLength) {
      errorMessage.value = 'Enter the 6-digit code to continue.';
      return;
    }

    errorMessage.value = '';
    isLoading.value = true;
    try {
      if (isRegisterFlow) {
        if (_email.isEmpty || _name.isEmpty || _password.isEmpty) {
          errorMessage.value = 'Missing registration details. Please try again.';
          return;
        }
        await _authService.verifyRegisterOtp(code: code, email: _email);
        await _authService.register(
          name: _name,
          email: _email,
          password: _password,
        );
        await _routeByRole();
      } else {
        await _authService.verifyOtp(code: code);
        Get.offAllNamed(AppRoutes.login);
      }
    } on ApiException catch (e) {
      if (e.statusCode == 0) {
        await _showNoInternetDialog();
        return;
      }
      errorMessage.value = e.message;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        await _showNoInternetDialog();
        return;
      }
      errorMessage.value = e.message ?? 'Unable to verify the code.';
    } catch (_) {
      errorMessage.value = 'Unable to verify the code.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendCode() async {
    if (secondsRemaining.value > 0) return;
    if (_email.isEmpty) {
      errorMessage.value = 'Missing email address.';
      return;
    }
    errorMessage.value = '';
    try {
      await _authService.sendRegisterOtp(email: _email);
      secondsRemaining.value = 30;
      _startTimer();
    } on ApiException catch (e) {
      if (e.statusCode == 0) {
        await _showNoInternetDialog();
        return;
      }
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Unable to resend code. Please try again.';
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value == 0) {
        timer.cancel();
        return;
      }
      secondsRemaining.value = secondsRemaining.value - 1;
    });
  }

  Future<void> _showNoInternetDialog() async {
    await showNoInternetDialogOnce();
  }

  void _loadArguments() {
    final args = Get.arguments;
    if (args is Map) {
      final flow = args['flow']?.toString().trim();
      if (flow != null && flow.isNotEmpty) {
        _flow = flow;
      }
      _email = args['email']?.toString().trim() ?? '';
      _name = args['name']?.toString().trim() ?? '';
      _password = args['password']?.toString() ?? '';
    }
  }

  Future<void> _routeByRole() async {
    final role = await _authService.getCurrentUserRole();
    if (role == 'admin') {
      Get.offAll(
        () => const AdminShellView(),
        binding: AdminBinding(),
      );
    } else {
      Get.offAll(
        () => const StudentShellView(),
        binding: StudentBinding(),
      );
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    for (final controller in codeControllers) {
      controller.dispose();
    }
    for (final node in focusNodes) {
      node.dispose();
    }
    super.onClose();
  }
}

