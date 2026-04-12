import 'package:get/get.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/student/models/student_payment.dart';
import 'package:sum_academy/modules/student/services/student_payments_service.dart';

class StudentPaymentsController extends GetxController {
  StudentPaymentsController(this._service);

  final StudentPaymentsService _service;

  final isLoading = true.obs;
  final activeTab = 'Transaction History'.obs;
  final payments = <StudentPaymentSummary>[].obs;
  final installments = <StudentInstallmentPlan>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll({bool force = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _service.fetchPayments(force: force),
        _service.fetchInstallments(force: force),
      ]);
      payments.assignAll(results[0] as List<StudentPaymentSummary>);
      installments.assignAll(results[1] as List<StudentInstallmentPlan>);
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showAppErrorDialog(
          title: 'Payments',
          message: e.message,
        );
      }
    } catch (_) {
      await showAppErrorDialog(
        title: 'Payments',
        message: 'Failed to load payments.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void setTab(String tab) {
    activeTab.value = tab;
  }
}
