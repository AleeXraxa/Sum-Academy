import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sum_academy/modules/auth/services/auth_service.dart';
import 'package:sum_academy/modules/student/models/student_settings.dart';
import 'package:sum_academy/modules/student/services/student_settings_service.dart';

class StudentSettingsController extends GetxController {
  StudentSettingsController(this._service);

  final StudentSettingsService _service;
  final AuthService _authService = Get.find<AuthService>();

  final isLoading = true.obs;
  final isSaving = false.obs;
  final settings = const StudentSettings(
    fullName: '',
    email: '',
    phoneNumber: '',
    fatherName: '',
    fatherPhone: '',
    fatherOccupation: '',
    district: '',
    domicile: '',
    caste: '',
    address: '',
  ).obs;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final fatherNameController = TextEditingController();
  final fatherPhoneController = TextEditingController();
  final fatherOccupationController = TextEditingController();
  final districtController = TextEditingController();
  final domicileController = TextEditingController();
  final casteController = TextEditingController();
  final addressController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final passwordStrength = 0.0.obs;
  final passwordStrengthLabel = 'Weak'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    newPasswordController.addListener(_updateStrength);
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    fatherNameController.dispose();
    fatherPhoneController.dispose();
    fatherOccupationController.dispose();
    districtController.dispose();
    domicileController.dispose();
    casteController.dispose();
    addressController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  bool get isComplete => settings.value.isComplete;

  Future<void> _loadSettings() async {
    isLoading.value = true;
    try {
      final data = await _service.fetchSettings();
      settings.value = data;
      fullNameController.text = data.fullName;
      emailController.text = data.email;
      phoneController.text = data.phoneNumber;
      fatherNameController.text = data.fatherName;
      fatherPhoneController.text = data.fatherPhone;
      fatherOccupationController.text = data.fatherOccupation;
      districtController.text = data.district;
      domicileController.text = data.domicile;
      casteController.text = data.caste;
      addressController.text = data.address;
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showAppErrorDialog(title: 'Profile', message: e.message);
      }
    } catch (_) {
      await showAppErrorDialog(
        title: 'Profile',
        message: 'Failed to load profile.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProfile() async {
    if (fullNameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      await showAppErrorDialog(
        title: 'Required',
        message: 'Full name and phone number are required.',
      );
      return;
    }

    final updated = StudentSettings(
      fullName: fullNameController.text,
      email: emailController.text,
      phoneNumber: phoneController.text,
      fatherName: fatherNameController.text,
      fatherPhone: fatherPhoneController.text,
      fatherOccupation: fatherOccupationController.text,
      district: districtController.text,
      domicile: domicileController.text,
      caste: casteController.text,
      address: addressController.text,
    );

    isSaving.value = true;
    final overlayContext = Get.context;
    if (overlayContext != null) {
      showLoadingDialog(overlayContext, message: 'Saving profile...');
    }
    try {
      final saved = await _service.updateSettings(updated);
      settings.value = saved;
      if (overlayContext != null) {
        await showAppSuccessDialog(
          title: 'Profile Updated',
          message: 'Your profile has been saved successfully.',
        );
      }
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showAppErrorDialog(title: 'Save failed', message: e.message);
      }
    } catch (_) {
      await showAppErrorDialog(
        title: 'Save failed',
        message: 'Please try again.',
      );
    } finally {
      if (overlayContext != null &&
          Navigator.of(overlayContext, rootNavigator: true).canPop()) {
        Navigator.of(overlayContext, rootNavigator: true).pop();
      }
      isSaving.value = false;
    }
  }

  Future<void> changePassword() async {
    final current = currentPasswordController.text.trim();
    final next = newPasswordController.text.trim();
    final confirm = confirmPasswordController.text.trim();
    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      await showAppErrorDialog(
        title: 'Password',
        message: 'Please fill all password fields.',
      );
      return;
    }
    if (next.length < 8) {
      await showAppErrorDialog(
        title: 'Password',
        message: 'Password must be at least 8 characters.',
      );
      return;
    }
    if (next != confirm) {
      await showAppErrorDialog(
        title: 'Password',
        message: 'New password and confirm password do not match.',
      );
      return;
    }

    isSaving.value = true;
    final overlayContext = Get.context;
    if (overlayContext != null) {
      showLoadingDialog(overlayContext, message: 'Updating password...');
    }
    try {
      await _authService.changePassword(
        currentPassword: current,
        newPassword: next,
      );
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      _updateStrength();
      if (overlayContext != null) {
        await showAppSuccessDialog(
          title: 'Password Updated',
          message: 'Your password has been updated successfully.',
        );
      }
    } on FirebaseAuthException catch (e) {
      final message = _mapPasswordError(e);
      await showAppErrorDialog(title: 'Password', message: message);
    } catch (_) {
      await showAppErrorDialog(
        title: 'Password',
        message: 'Unable to update password. Please try again.',
      );
    } finally {
      if (overlayContext != null &&
          Navigator.of(overlayContext, rootNavigator: true).canPop()) {
        Navigator.of(overlayContext, rootNavigator: true).pop();
      }
      isSaving.value = false;
    }
  }

  void _updateStrength() {
    final value = newPasswordController.text;
    final score = _calculatePasswordScore(value);
    passwordStrength.value = score / 4;
    if (score <= 1) {
      passwordStrengthLabel.value = 'Weak';
    } else if (score == 2 || score == 3) {
      passwordStrengthLabel.value = 'Medium';
    } else {
      passwordStrengthLabel.value = 'Strong';
    }
  }

  int _calculatePasswordScore(String value) {
    var score = 0;
    if (value.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(value)) score++;
    if (RegExp(r'[0-9]').hasMatch(value)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) score++;
    return score;
  }

  String _mapPasswordError(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'wrong-password':
        return 'Current password is incorrect.';
      case 'requires-recent-login':
        return 'Please login again and retry changing your password.';
      case 'no-password-provider':
        return 'Password changes are available only for email accounts.';
      default:
        return exception.message ?? 'Unable to update password.';
    }
  }
}
