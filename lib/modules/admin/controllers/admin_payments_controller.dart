import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/admin/models/admin_installment.dart';
import 'package:sum_academy/modules/admin/models/admin_payment.dart';
import 'package:sum_academy/modules/admin/services/admin_installment_service.dart';
import 'package:sum_academy/modules/admin/services/admin_payment_service.dart';

class AdminPaymentsController extends GetxController {
  final AdminPaymentService _paymentService = Get.find<AdminPaymentService>();
  final AdminInstallmentService _installmentService =
      Get.find<AdminInstallmentService>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final RxList<AdminPaymentRow> payments = <AdminPaymentRow>[].obs;
  final RxList<AdminInstallmentRow> installments = <AdminInstallmentRow>[].obs;

  final RxList<AdminFilterChip> paymentFilters = <AdminFilterChip>[].obs;
  final RxList<AdminFilterChip> installmentFilters = <AdminFilterChip>[].obs;

  final RxBool isPaymentsLoading = false.obs;
  final RxBool isPaymentsLoadingMore = false.obs;
  final RxBool hasMorePayments = true.obs;
  final RxBool isPaymentsInitialized = false.obs;

  final RxBool isInstallmentsLoading = false.obs;
  final RxBool isInstallmentsLoadingMore = false.obs;
  final RxBool hasMoreInstallments = true.obs;
  final RxBool isInstallmentsInitialized = false.obs;

  final RxInt paymentFilterIndex = 0.obs;
  final RxInt installmentFilterIndex = 0.obs;
  final RxString paymentSearchQuery = ''.obs;
  final RxString installmentSearchQuery = ''.obs;

  final TextEditingController paymentSearchController = TextEditingController();
  final TextEditingController installmentSearchController =
      TextEditingController();

  Timer? _paymentDebounce;
  Timer? _installmentDebounce;

  int _paymentPage = 1;
  int _installmentPage = 1;
  final int _pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    paymentSearchController.addListener(_onPaymentSearchChanged);
    installmentSearchController.addListener(_onInstallmentSearchChanged);
    ever<List<AdminPaymentRow>>(payments, (_) => _refreshPaymentFilters());
    ever<List<AdminInstallmentRow>>(installments, (_) {
      _refreshInstallmentFilters();
    });
    _refreshPaymentFilters();
    _refreshInstallmentFilters();
  }

  Future<void> ensurePaymentsLoaded() async {
    if (isPaymentsInitialized.value || isPaymentsLoading.value) return;
    await fetchPayments();
  }

  Future<void> ensureInstallmentsLoaded() async {
    if (isInstallmentsInitialized.value || isInstallmentsLoading.value) return;
    await fetchInstallments();
  }

  Future<void> fetchPayments({bool reset = true}) async {
    if (reset) {
      _paymentPage = 1;
      hasMorePayments.value = true;
      isPaymentsLoading.value = true;
      isPaymentsLoadingMore.value = false;
    } else {
      isPaymentsLoadingMore.value = true;
    }

    try {
      await _ensureAuthReady();
      final result = await _paymentService.fetchPayments(
        page: _paymentPage,
        limit: _pageSize,
        status: null,
        search: null,
      );
      final rows = result.map(_toPaymentRow).toList();
      final pageRows = rows.length > _pageSize
          ? _slicePage(rows, _paymentPage, _pageSize)
          : rows;
      if (reset) {
        payments
          ..clear()
          ..addAll(pageRows);
      } else {
        final existing = payments.map((item) => item.id).toSet();
        payments.addAll(
          pageRows.where((item) => !existing.contains(item.id)),
        );
      }
      if (pageRows.length < _pageSize) {
        hasMorePayments.value = false;
      }
      _refreshPaymentFilters();
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (handled) return;
      await showAppErrorDialog(
        title: 'Payments',
        message: _formatApiError(e),
      );
    } catch (_) {
      await showAppErrorDialog(
        title: 'Payments',
        message: 'Failed to load payments.',
      );
    } finally {
      if (reset) {
        isPaymentsLoading.value = false;
        if (!isPaymentsInitialized.value) {
          isPaymentsInitialized.value = true;
        }
      } else {
        isPaymentsLoadingMore.value = false;
      }
    }
  }

  Future<void> loadMorePayments() async {
    if (isPaymentsLoadingMore.value || isPaymentsLoading.value) return;
    if (!hasMorePayments.value) return;
    _paymentPage += 1;
    await fetchPayments(reset: false);
  }

  Future<void> fetchInstallments({bool reset = true}) async {
    if (reset) {
      _installmentPage = 1;
      hasMoreInstallments.value = true;
      isInstallmentsLoading.value = true;
      isInstallmentsLoadingMore.value = false;
    } else {
      isInstallmentsLoadingMore.value = true;
    }

    try {
      await _ensureAuthReady();
      final result = await _installmentService.fetchInstallments(
        page: _installmentPage,
        limit: _pageSize,
        status: null,
        search: null,
      );
      final rows = result.map(_toInstallmentRow).toList();
      final pageRows = rows.length > _pageSize
          ? _slicePage(rows, _installmentPage, _pageSize)
          : rows;
      if (reset) {
        installments
          ..clear()
          ..addAll(pageRows);
      } else {
        final existing = installments.map((item) => item.planId).toSet();
        installments.addAll(
          pageRows.where((item) => !existing.contains(item.planId)),
        );
      }
      if (pageRows.length < _pageSize) {
        hasMoreInstallments.value = false;
      }
      _refreshInstallmentFilters();
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (handled) return;
      await showAppErrorDialog(
        title: 'Installments',
        message: _formatApiError(e),
      );
    } catch (_) {
      await showAppErrorDialog(
        title: 'Installments',
        message: 'Failed to load installments.',
      );
    } finally {
      if (reset) {
        isInstallmentsLoading.value = false;
        if (!isInstallmentsInitialized.value) {
          isInstallmentsInitialized.value = true;
        }
      } else {
        isInstallmentsLoadingMore.value = false;
      }
    }
  }

  Future<void> loadMoreInstallments() async {
    if (isInstallmentsLoadingMore.value || isInstallmentsLoading.value) return;
    if (!hasMoreInstallments.value) return;
    _installmentPage += 1;
    await fetchInstallments(reset: false);
  }

  Future<PaymentActionResult> verifyPayment({
    required String paymentId,
    required String action,
  }) async {
    if (paymentId.trim().isEmpty) {
      return const PaymentActionResult.failure(
        'Payment ID is missing. Please refresh and try again.',
      );
    }
    try {
      final updated = await _paymentService.verifyPayment(
        paymentId: paymentId,
        action: action,
      );
      final index = payments.indexWhere((item) => item.id == paymentId);
      if (index != -1) {
        final row = payments[index];
        payments[index] = row.copyWith(
          status: updated.status.isNotEmpty ? updated.status : row.status,
        );
      }
      _refreshPaymentFilters();
      return PaymentActionResult.success(
        action == 'approve'
            ? 'Payment approved successfully.'
            : 'Payment rejected successfully.',
      );
    } on ApiException catch (e) {
      if (e.statusCode == 0) {
        return PaymentActionResult.networkFailure(e.message);
      }
      return PaymentActionResult.failure(_formatApiError(e));
    } catch (_) {
      return const PaymentActionResult.failure('Please try again.');
    }
  }

  Future<InstallmentActionResult> markNextInstallmentPaid(
    AdminInstallmentRow plan,
  ) async {
    try {
      final items =
          await _installmentService.fetchInstallmentDetail(plan.planId);
      items.sort((a, b) => a.number.compareTo(b.number));
      InstallmentItem? next;
      for (final item in items) {
        if (!item.isPaid) {
          next = item;
          break;
        }
      }
      if (next == null) {
        return const InstallmentActionResult.failure(
          'All installments are already paid.',
        );
      }
      await _installmentService.markInstallmentPaid(
        planId: plan.planId,
        number: next.number,
      );
      await fetchInstallments(reset: true);
      return const InstallmentActionResult.success(
        'Installment marked as paid.',
      );
    } on ApiException catch (e) {
      if (e.statusCode == 0) {
        return InstallmentActionResult.networkFailure(e.message);
      }
      return InstallmentActionResult.failure(_formatApiError(e));
    } catch (_) {
      return const InstallmentActionResult.failure('Please try again.');
    }
  }

  void setPaymentFilterIndex(int index) {
    paymentFilterIndex.value = index;
  }

  void setInstallmentFilterIndex(int index) {
    installmentFilterIndex.value = index;
  }

  List<AdminPaymentRow> get filteredPayments {
    final query = paymentSearchQuery.value.trim().toLowerCase();
    Iterable<AdminPaymentRow> list = payments;
    if (query.isNotEmpty) {
      list = list.where(
        (payment) =>
            payment.studentName.toLowerCase().contains(query) ||
            payment.studentEmail.toLowerCase().contains(query) ||
            payment.id.toLowerCase().contains(query) ||
            payment.reference.toLowerCase().contains(query),
      );
    }

    switch (paymentFilterIndex.value) {
      case 1:
        list = list.where((p) => _paymentStatusType(p.status) == 'pending');
        break;
      case 2:
        list = list.where((p) => _paymentStatusType(p.status) == 'approved');
        break;
      case 3:
        list = list.where((p) => _paymentStatusType(p.status) == 'rejected');
        break;
      default:
        break;
    }

    return list.toList();
  }

  List<AdminInstallmentRow> get filteredInstallments {
    final query = installmentSearchQuery.value.trim().toLowerCase();
    Iterable<AdminInstallmentRow> list = installments;
    if (query.isNotEmpty) {
      list = list.where(
        (plan) =>
            plan.studentName.toLowerCase().contains(query) ||
            plan.studentEmail.toLowerCase().contains(query) ||
            plan.planId.toLowerCase().contains(query) ||
            plan.courseTitle.toLowerCase().contains(query),
      );
    }

    switch (installmentFilterIndex.value) {
      case 1:
        list = list.where((p) => _installmentStatusType(p) == 'pending');
        break;
      case 2:
        list = list.where((p) => _installmentStatusType(p) == 'paid');
        break;
      case 3:
        list = list.where((p) => _installmentStatusType(p) == 'overdue');
        break;
      default:
        break;
    }

    return list.toList();
  }

  void _refreshPaymentFilters() {
    final all = payments.length;
    final pending =
        payments.where((p) => _paymentStatusType(p.status) == 'pending').length;
    final approved = payments
        .where((p) => _paymentStatusType(p.status) == 'approved')
        .length;
    final rejected = payments
        .where((p) => _paymentStatusType(p.status) == 'rejected')
        .length;

    paymentFilters.assignAll([
      AdminFilterChip(label: 'All', count: all),
      AdminFilterChip(label: 'Under Review', count: pending),
      AdminFilterChip(label: 'Approved', count: approved),
      AdminFilterChip(label: 'Rejected', count: rejected),
    ]);
  }

  void _refreshInstallmentFilters() {
    final all = installments.length;
    final pending = installments.where((p) => _installmentStatusType(p) == 'pending').length;
    final paid = installments.where((p) => _installmentStatusType(p) == 'paid').length;
    final overdue = installments.where((p) => _installmentStatusType(p) == 'overdue').length;

    installmentFilters.assignAll([
      AdminFilterChip(label: 'All', count: all),
      AdminFilterChip(label: 'Pending', count: pending),
      AdminFilterChip(label: 'Paid', count: paid),
      AdminFilterChip(label: 'Overdue', count: overdue),
    ]);
  }

  void _onPaymentSearchChanged() {
    _paymentDebounce?.cancel();
    _paymentDebounce = Timer(const Duration(milliseconds: 300), () {
      paymentSearchQuery.value = paymentSearchController.text.trim();
    });
  }

  void _onInstallmentSearchChanged() {
    _installmentDebounce?.cancel();
    _installmentDebounce = Timer(const Duration(milliseconds: 300), () {
      installmentSearchQuery.value =
          installmentSearchController.text.trim();
    });
  }

  Future<void> _ensureAuthReady() async {
    if (_firebaseAuth.currentUser != null) {
      return;
    }
    try {
      await _firebaseAuth
          .authStateChanges()
          .firstWhere((user) => user != null)
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      if (_firebaseAuth.currentUser == null) {
        throw ApiException('Authentication required.', statusCode: 401);
      }
    }
  }

  @override
  void onClose() {
    _paymentDebounce?.cancel();
    _installmentDebounce?.cancel();
    paymentSearchController.removeListener(_onPaymentSearchChanged);
    installmentSearchController.removeListener(_onInstallmentSearchChanged);
    paymentSearchController.dispose();
    installmentSearchController.dispose();
    super.onClose();
  }
}

class AdminFilterChip {
  final String label;
  final int count;

  const AdminFilterChip({required this.label, required this.count});
}

class AdminPaymentRow {
  final String id;
  final String studentName;
  final String studentEmail;
  final String status;
  final double amount;
  final String currency;
  final String method;
  final DateTime? createdAt;
  final String reference;
  final String courseTitle;
  final String className;
  final String initials;
  final Color avatarColor;

  const AdminPaymentRow({
    required this.id,
    required this.studentName,
    required this.studentEmail,
    required this.status,
    required this.amount,
    required this.currency,
    required this.method,
    required this.createdAt,
    required this.reference,
    required this.courseTitle,
    required this.className,
    required this.initials,
    required this.avatarColor,
  });

  AdminPaymentRow copyWith({String? status}) {
    return AdminPaymentRow(
      id: id,
      studentName: studentName,
      studentEmail: studentEmail,
      status: status ?? this.status,
      amount: amount,
      currency: currency,
      method: method,
      createdAt: createdAt,
      reference: reference,
      courseTitle: courseTitle,
      className: className,
      initials: initials,
      avatarColor: avatarColor,
    );
  }
}

class AdminInstallmentRow {
  final String planId;
  final String studentName;
  final String studentEmail;
  final double totalAmount;
  final double remainingAmount;
  final int numberOfInstallments;
  final int paidInstallments;
  final String status;
  final DateTime? startDate;
  final DateTime? nextDueDate;
  final String courseTitle;
  final String className;
  final String initials;
  final Color avatarColor;

  const AdminInstallmentRow({
    required this.planId,
    required this.studentName,
    required this.studentEmail,
    required this.totalAmount,
    required this.remainingAmount,
    required this.numberOfInstallments,
    required this.paidInstallments,
    required this.status,
    required this.startDate,
    required this.nextDueDate,
    required this.courseTitle,
    required this.className,
    required this.initials,
    required this.avatarColor,
  });
}

class PaymentActionResult {
  final bool isSuccess;
  final bool isNetworkError;
  final String message;

  const PaymentActionResult._(
    this.isSuccess,
    this.message, {
    this.isNetworkError = false,
  });

  const PaymentActionResult.success(this.message)
      : isSuccess = true,
        isNetworkError = false;

  const PaymentActionResult.failure(this.message)
      : isSuccess = false,
        isNetworkError = false;

  const PaymentActionResult.networkFailure(this.message)
      : isSuccess = false,
        isNetworkError = true;
}

class InstallmentActionResult {
  final bool isSuccess;
  final bool isNetworkError;
  final String message;

  const InstallmentActionResult._(
    this.isSuccess,
    this.message, {
    this.isNetworkError = false,
  });

  const InstallmentActionResult.success(this.message)
      : isSuccess = true,
        isNetworkError = false;

  const InstallmentActionResult.failure(this.message)
      : isSuccess = false,
        isNetworkError = false;

  const InstallmentActionResult.networkFailure(this.message)
      : isSuccess = false,
        isNetworkError = true;
}

AdminPaymentRow _toPaymentRow(AdminPayment payment) {
  final initials = _buildInitials(
    payment.studentName.isNotEmpty ? payment.studentName : payment.studentEmail,
  );
  return AdminPaymentRow(
    id: payment.id,
    studentName: payment.studentName,
    studentEmail: payment.studentEmail,
    status: payment.status,
    amount: payment.amount,
    currency: payment.currency,
    method: payment.method,
    createdAt: payment.createdAt,
    reference: payment.reference,
    courseTitle: payment.courseTitle,
    className: payment.className,
    initials: initials,
    avatarColor: SumAcademyTheme.brandBlue,
  );
}

AdminInstallmentRow _toInstallmentRow(AdminInstallmentPlan plan) {
  final initials = _buildInitials(
    plan.studentName.isNotEmpty ? plan.studentName : plan.studentEmail,
  );
  return AdminInstallmentRow(
    planId: plan.planId,
    studentName: plan.studentName,
    studentEmail: plan.studentEmail,
    totalAmount: plan.totalAmount,
    remainingAmount: plan.remainingAmount,
    numberOfInstallments: plan.numberOfInstallments,
    paidInstallments: plan.paidInstallments,
    status: plan.status,
    startDate: plan.startDate,
    nextDueDate: plan.nextDueDate,
    courseTitle: plan.courseTitle,
    className: plan.className,
    initials: initials,
    avatarColor: SumAcademyTheme.accentOrange,
  );
}

String _buildInitials(String value) {
  final parts = value.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return 'U';
  if (parts.length == 1) {
    final word = parts.first;
    return (word.length >= 2 ? word.substring(0, 2) : word).toUpperCase();
  }
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}

String _paymentStatusType(String status) {
  final normalized = status.toLowerCase();
  if (normalized.contains('approve') || normalized.contains('paid')) {
    return 'approved';
  }
  if (normalized.contains('reject') ||
      normalized.contains('fail') ||
      normalized.contains('cancel')) {
    return 'rejected';
  }
  return 'pending';
}

String _installmentStatusType(AdminInstallmentRow plan) {
  final normalized = plan.status.toLowerCase();
  if (normalized.contains('overdue') || normalized.contains('late')) {
    return 'overdue';
  }
  if (normalized.contains('paid') ||
      normalized.contains('complete') ||
      (plan.remainingAmount <= 0 && plan.totalAmount > 0)) {
    return 'paid';
  }
  return 'pending';
}

String _formatApiError(ApiException exception) {
  final base = exception.message;
  final errors = exception.errors;
  if (errors == null || errors.isEmpty) {
    return base;
  }

  final details = <String>[];
  errors.forEach((key, value) {
    if (value == null) return;
    if (value is List) {
      for (final item in value) {
        details.add('$key: $item');
      }
    } else {
      details.add('$key: $value');
    }
  });

  if (details.isEmpty) {
    return base;
  }

  return '$base\n${details.join('\n')}';
}

List<T> _slicePage<T>(List<T> items, int page, int pageSize) {
  if (items.isEmpty) return items;
  final start = (page - 1) * pageSize;
  if (start >= items.length) return <T>[];
  final end = start + pageSize;
  return items.sublist(start, end > items.length ? items.length : end);
}
