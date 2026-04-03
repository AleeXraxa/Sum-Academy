import 'package:get/get.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/home/models/home_dashboard.dart';
import 'package:sum_academy/modules/home/services/home_service.dart';

class HomeController extends GetxController {
  HomeController(this._service);

  final HomeService _service;
  final Rx<HomeDashboard> dashboard = HomeDashboard.empty().obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    try {
      dashboard.value = await _service.fetchDashboard();
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showAppErrorDialog(
          title: 'Dashboard failed',
          message: e.message,
        );
      }
    } catch (_) {
      await showAppErrorDialog(
        title: 'Dashboard failed',
        message: 'Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }
}

