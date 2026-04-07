import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';
import 'package:sum_academy/modules/student/models/student_checkout_models.dart';
import 'package:sum_academy/modules/student/models/student_explore_course.dart';
import 'package:sum_academy/modules/student/services/student_checkout_service.dart';

class StudentCheckoutController extends GetxController {
  StudentCheckoutController({
    required this.course,
    this.subject,
    StudentCheckoutService? service,
  }) : _service = service ?? StudentCheckoutService();

  final StudentExploreCourse course;
  final StudentExploreSubject? subject;
  final StudentCheckoutService _service;

  final isLoading = true.obs;
  final stepIndex = 0.obs;

  final classes = <StudentCheckoutClass>[].obs;
  final selectedClass = Rxn<StudentCheckoutClass>();
  final selectedShift = Rxn<StudentCheckoutShift>();

  final paymentConfig = Rxn<StudentPaymentConfig>();
  final selectedMethod = ''.obs;

  final promoController = TextEditingController();
  final isValidatingPromo = false.obs;
  final promoMessage = ''.obs;
  final promoDiscount = 0.0.obs;
  final promoFinalAmount = 0.0.obs;

  final isInstallment = false.obs;
  final selectedInstallmentCount = 2.obs;

  final paymentId = ''.obs;
  final paymentReference = ''.obs;
  final paymentInitiated = false.obs;
  final isSubmittingPayment = false.obs;

  final receiptPath = ''.obs;
  final receiptUploaded = false.obs;
  final isUploadingReceipt = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
    promoController.addListener(_onPromoChanged);
  }

  @override
  void onClose() {
    promoController.removeListener(_onPromoChanged);
    promoController.dispose();
    super.onClose();
  }

  Future<void> _loadInitialData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _service.fetchAvailableClasses(),
        _service.fetchPaymentConfig(),
      ]);
      classes.assignAll(results[0] as List<StudentCheckoutClass>);
      paymentConfig.value = results[1] as StudentPaymentConfig;

      if (classes.isNotEmpty) {
        StudentCheckoutClass? match;
        for (final item in classes) {
          if (item.id == course.id || item.code == course.code) {
            match = item;
            break;
          }
        }
        final initial = match ?? classes.first;
        selectedClass.value = initial;
        _syncShiftFromClass(initial);
      }

      final methods = paymentConfig.value?.methods ??
          const ['JazzCash', 'EasyPaisa', 'Bank Transfer'];
      if (methods.isNotEmpty) {
        selectedMethod.value = methods.first;
      }

      final installments = paymentConfig.value?.installmentOptions;
      if (installments != null && installments.isNotEmpty) {
        selectedInstallmentCount.value = installments.first;
      }
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showAppErrorDialog(
          title: 'Checkout failed',
          message: e.message,
        );
      }
    } catch (_) {
      await showAppErrorDialog(
        title: 'Checkout failed',
        message: 'Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<int> get installmentOptions =>
      paymentConfig.value?.installmentOptions ?? const [2, 3, 4];

  List<String> get paymentMethods =>
      paymentConfig.value?.methods ?? const ['JazzCash', 'EasyPaisa', 'Bank Transfer'];

  List<StudentCheckoutShift> get availableShifts {
    final current = selectedClass.value;
    if (current == null) return const [];
    if (!isSingleSubject) {
      return current.shifts;
    }
    final targetCourseId = subject?.id ?? course.id;
    return current.shifts
        .where(
          (shift) =>
              shift.courseId.isEmpty ||
              shift.courseId == targetCourseId,
        )
        .toList();
  }

  double get originalPrice {
    if (subject != null) {
      return subject!.price;
    }
    if (course.remainingPrice > 0) return course.remainingPrice;
    if (course.totalPrice > 0) return course.totalPrice;
    return course.price;
  }

  double get _discountPercent {
    if (subject != null) {
      return subject!.discountPercent;
    }
    return course.discount;
  }

  double get courseDiscount {
    if (_discountPercent <= 0) return 0;
    return originalPrice * (_discountPercent / 100);
  }

  double get totalBeforePromo {
    final subtotal = originalPrice - courseDiscount;
    return subtotal < 0 ? 0 : subtotal;
  }

  double get totalAmount {
    final forced = promoFinalAmount.value;
    if (forced > 0) return forced;
    final total = totalBeforePromo - promoDiscount.value;
    return total < 0 ? 0 : total;
  }

  double get amountDueNow {
    if (!isInstallment.value) return totalAmount;
    final count = selectedInstallmentCount.value;
    if (count <= 1) return totalAmount;
    return totalAmount / count;
  }

  bool get isSingleSubject => subject != null;

  String get enrollmentType => isSingleSubject ? 'single_course' : 'full_class';

  String get summaryTitle => subject?.title ?? course.title;

  String get summarySubtitle =>
      isSingleSubject ? 'Individual subject enrollment' : 'Full class enrollment';

  String get discountLabel =>
      isSingleSubject ? 'Subject Discount' : 'Class Discount';

  void selectClassByLabel(String? label) {
    if (label == null) return;
    StudentCheckoutClass? match;
    for (final item in classes) {
      if (item.displayLabel == label) {
        match = item;
        break;
      }
    }
    if (match != null) {
      selectedClass.value = match;
      _syncShiftFromClass(match);
    }
  }

  void selectShiftByLabel(String? label) {
    if (label == null) return;
    StudentCheckoutShift? match;
    for (final item in availableShifts) {
      if (item.displayLabel == label) {
        match = item;
        break;
      }
    }
    if (match != null) {
      selectedShift.value = match;
    }
  }

  void toggleInstallment(bool enable) {
    isInstallment.value = enable;
  }

  void selectInstallmentCountByLabel(String? label) {
    if (label == null) return;
    final parsed = int.tryParse(label.split(' ').first) ?? 0;
    if (parsed > 0) {
      selectedInstallmentCount.value = parsed;
    }
  }

  void selectMethod(String method) {
    selectedMethod.value = method;
  }

  Future<void> validatePromo() async {
    if (!isSingleSubject) {
      await showAppErrorDialog(
        title: 'Promo code',
        message: 'Promo codes apply to individual subjects only.',
      );
      return;
    }
    final code = promoController.text.trim();
    if (code.isEmpty) {
      await showAppErrorDialog(
        title: 'Promo code',
        message: 'Enter a promo code to validate.',
      );
      return;
    }
    isValidatingPromo.value = true;
    promoMessage.value = '';
    try {
      final data = await _service.validatePromo(
        code: code,
        courseId: subject?.id ?? course.id,
      );
      promoDiscount.value =
          _readDouble(data, ['discountAmount', 'discount', 'amount']);
      promoFinalAmount.value =
          _readDouble(data, ['finalAmount', 'totalAmount', 'payableAmount']);
      promoMessage.value = data['message']?.toString() ?? 'Promo applied.';
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showAppErrorDialog(title: 'Promo invalid', message: e.message);
      }
      promoDiscount.value = 0;
      promoFinalAmount.value = 0;
    } catch (_) {
      await showAppErrorDialog(
        title: 'Promo invalid',
        message: 'Unable to validate promo code.',
      );
      promoDiscount.value = 0;
      promoFinalAmount.value = 0;
    } finally {
      isValidatingPromo.value = false;
    }
  }

  Future<void> initiatePayment() async {
    final currentClass = selectedClass.value;
    final currentShift = selectedShift.value;
    if (currentClass == null || currentShift == null) {
      await showAppErrorDialog(
        title: 'Required',
        message: 'Please select a class and shift.',
      );
      return;
    }
    final method = selectedMethod.value;
    if (method.isEmpty) {
      await showAppErrorDialog(
        title: 'Required',
        message: 'Please select a payment method.',
      );
      return;
    }
    isSubmittingPayment.value = true;
    final overlayContext = Get.context;
    if (overlayContext != null) {
      showLoadingDialog(overlayContext, message: 'Confirming payment...');
    }
    try {
      final data = await _service.initiatePayment(
        classId: currentClass.id,
        shiftId: currentShift.id,
        method: _methodKey(method),
        enrollmentType: enrollmentType,
        courseId: isSingleSubject ? subject?.id ?? course.id : null,
        promoCode: promoController.text.trim(),
        installmentCount: isInstallment.value
            ? selectedInstallmentCount.value
            : null,
      );
      paymentId.value = _readString(data, ['paymentId', 'id']);
      paymentReference.value =
          _readString(data, ['reference', 'paymentRef', 'ref']);
      promoDiscount.value = _readDouble(
        data,
        ['promoDiscountAmount', 'promoDiscount', 'discountAmount'],
      );
      promoFinalAmount.value = _readDouble(
        data,
        ['totalAmount', 'finalAmount', 'payableAmount'],
      );
      paymentInitiated.value = true;
      promoMessage.value = data['message']?.toString() ?? 'Payment initiated.';
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showAppErrorDialog(title: 'Payment failed', message: e.message);
      }
    } catch (_) {
      await showAppErrorDialog(
        title: 'Payment failed',
        message: 'Please try again.',
      );
    } finally {
      if (overlayContext != null &&
          Navigator.of(overlayContext, rootNavigator: true).canPop()) {
        Navigator.of(overlayContext, rootNavigator: true).pop();
      }
      isSubmittingPayment.value = false;
    }
  }

  Future<void> pickReceipt() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path ?? '';
    if (path.isEmpty) return;
    receiptPath.value = path;
    receiptUploaded.value = false;
  }

  Future<void> uploadReceipt() async {
    if (paymentId.value.isEmpty) {
      await showAppErrorDialog(
        title: 'Receipt',
        message: 'Payment reference not found.',
      );
      return;
    }
    final path = receiptPath.value;
    if (path.isEmpty) {
      await showAppErrorDialog(
        title: 'Receipt',
        message: 'Please select a receipt image to upload.',
      );
      return;
    }

    final file = File(path);
    if (!file.existsSync()) {
      await showAppErrorDialog(
        title: 'Receipt',
        message: 'Receipt file not found.',
      );
      return;
    }

    isUploadingReceipt.value = true;
    final overlayContext = Get.context;
    if (overlayContext != null) {
      showLoadingDialog(overlayContext, message: 'Uploading receipt...');
    }
    try {
      await _service.uploadReceipt(paymentId: paymentId.value, receiptFile: file);
      receiptUploaded.value = true;
      if (overlayContext != null) {
        await showAppSuccessDialog(
          title: 'Receipt Uploaded',
          message: 'Receipt submitted successfully for verification.',
        );
      }
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showAppErrorDialog(
          title: 'Upload failed',
          message: e.message,
        );
      }
    } catch (_) {
      await showAppErrorDialog(
        title: 'Upload failed',
        message: 'Please try again.',
      );
    } finally {
      if (overlayContext != null &&
          Navigator.of(overlayContext, rootNavigator: true).canPop()) {
        Navigator.of(overlayContext, rootNavigator: true).pop();
      }
      isUploadingReceipt.value = false;
    }
  }

  Future<void> goNext() async {
    if (isSubmittingPayment.value || isUploadingReceipt.value) {
      return;
    }
    if (stepIndex.value == 0) {
      if (selectedClass.value == null || selectedShift.value == null) {
        await showAppErrorDialog(
          title: 'Required',
          message: 'Please select a class and shift.',
        );
        return;
      }
    }
    if (stepIndex.value == 2 && selectedMethod.value.isEmpty) {
      await showAppErrorDialog(
        title: 'Required',
        message: 'Please select a payment method.',
      );
      return;
    }
    if (stepIndex.value == 3) {
      if (!paymentInitiated.value) {
        await initiatePayment();
        return;
      }
      if (!receiptUploaded.value) {
        await showAppErrorDialog(
          title: 'Receipt required',
          message: 'Please upload the payment receipt to finish.',
        );
        return;
      }
      Get.back();
      return;
    }
    stepIndex.value++;
  }

  void goBack() {
    if (stepIndex.value == 0) {
      Get.back();
    } else {
      stepIndex.value--;
    }
  }

  List<InstallmentPreview> get installmentSchedule {
    if (!isInstallment.value) return const [];
    final count = selectedInstallmentCount.value;
    if (count <= 1) return const [];
    final perInstallment = amountDueNow;
    final startDate = DateTime.now();
    return List.generate(count, (index) {
      final dueDate = DateTime(
        startDate.year,
        startDate.month + index + 1,
        startDate.day,
      );
      return InstallmentPreview(
        amount: perInstallment,
        dueDate: dueDate,
        sequence: index + 1,
      );
    });
  }

  void _syncShiftFromClass(StudentCheckoutClass value) {
    List<StudentCheckoutShift> shifts;
    if (!isSingleSubject) {
      shifts = value.shifts;
    } else {
      final targetCourseId = subject?.id ?? course.id;
      shifts = value.shifts
          .where(
            (shift) =>
                shift.courseId.isEmpty ||
                shift.courseId == targetCourseId,
          )
          .toList();
    }
    selectedShift.value = shifts.isNotEmpty ? shifts.first : null;
  }

  void _onPromoChanged() {
    promoMessage.value = '';
    promoDiscount.value = 0;
    promoFinalAmount.value = 0;
  }

  String _methodKey(String label) {
    final lower = label.trim().toLowerCase();
    if (lower.contains('bank')) return 'bank_transfer';
    if (lower.contains('jazz')) return 'jazzcash';
    if (lower.contains('easy')) return 'easypaisa';
    return lower.replaceAll(' ', '_');
  }

  double _readDouble(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;
      if (value is num) return value.toDouble();
      final parsed = double.tryParse(value.toString());
      if (parsed != null) return parsed;
    }
    return 0;
  }

  String _readString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }
}

class InstallmentPreview {
  final int sequence;
  final double amount;
  final DateTime dueDate;

  const InstallmentPreview({
    required this.sequence,
    required this.amount,
    required this.dueDate,
  });
}
