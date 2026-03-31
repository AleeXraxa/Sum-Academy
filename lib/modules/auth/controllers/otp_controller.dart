import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sum_academy/app/routes/app_routes.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';
import 'package:sum_academy/modules/auth/services/auth_service.dart';

class OtpController extends GetxController {
  static const int codeLength = 6;

  late final List<TextEditingController> codeControllers;
  late final List<FocusNode> focusNodes;

  final isLoading = false.obs;
  final secondsRemaining = 30.obs;
  final errorMessage = ''.obs;

  Timer? _timer;

  AuthService get _authService => Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    codeControllers = List.generate(
      codeLength,
      (_) => TextEditingController(),
    );
    focusNodes = List.generate(codeLength, (_) => FocusNode());
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

  Future<void> verify() async {
    if (code.length != codeLength) {
      errorMessage.value = 'Enter the 6-digit code to continue.';
      return;
    }

    errorMessage.value = '';
    isLoading.value = true;
    try {
      await _authService.verifyOtp(code: code);
      Get.offAllNamed(AppRoutes.login);
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

  void resendCode() {
    if (secondsRemaining.value > 0) return;
    secondsRemaining.value = 30;
    _startTimer();
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

