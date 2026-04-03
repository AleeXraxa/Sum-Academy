import 'package:get/get.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/student/models/student_support_info.dart';
import 'package:sum_academy/modules/student/services/student_support_service.dart';

class StudentSupportController extends GetxController {
  StudentSupportController(this._service);

  final StudentSupportService _service;

  final info = StudentSupportInfo.empty().obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSupportInfo();
  }

  Future<void> fetchSupportInfo({bool silent = false}) async {
    if (!silent) {
      isLoading.value = true;
    }
    try {
      info.value = await _service.fetchSupportInfo();
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showAppErrorDialog(
          title: 'Support failed',
          message: e.message,
        );
      }
    } catch (_) {
      await showAppErrorDialog(
        title: 'Support failed',
        message: 'Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
