import 'package:get/get.dart';
import 'package:sum_academy/modules/home/models/home_dashboard.dart';
import 'package:sum_academy/modules/home/services/home_service.dart';

class HomeController extends GetxController {
  HomeController(this._service);

  final HomeService _service;
  final Rx<HomeDashboard> dashboard = HomeDashboard.empty().obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  void loadDashboard() {
    dashboard.value = _service.fetchDashboard();
  }
}

