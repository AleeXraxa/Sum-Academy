import 'package:get/get.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/admin/models/chart_series.dart';
import 'package:sum_academy/modules/admin/services/admin_analytics_service.dart';

class AdminAnalyticsController extends GetxController {
  final AdminAnalyticsService _service = Get.find<AdminAnalyticsService>();

  final Rx<ChartSeries> revenueSeries =
      ChartSeries.empty(labelPrefix: '').obs;
  final Rx<ChartSeries> enrollmentSeries =
      ChartSeries.empty(labelPrefix: '').obs;

  final RxBool isRevenueLoading = false.obs;
  final RxBool isEnrollmentLoading = false.obs;

  final RxString quickRange = '30d'.obs;
  final RxString revenueInterval = 'daily'.obs;
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  void setQuickRange(String range) {
    quickRange.value = range;
    fromDate = null;
    toDate = null;
    fetchAll();
  }

  void setRevenueInterval(String interval) {
    revenueInterval.value = interval;
    fetchRevenue();
  }

  void setFromDate(DateTime date) {
    fromDate = date;
    fetchAll();
  }

  void setToDate(DateTime date) {
    toDate = date;
    fetchAll();
  }

  Future<void> fetchAll() async {
    await Future.wait([
      fetchRevenue(),
      fetchEnrollment(),
    ]);
  }

  Future<void> fetchRevenue() async {
    isRevenueLoading.value = true;
    try {
      final series = await _service.fetchRevenueChart(
        range: quickRange.value,
        interval: revenueInterval.value,
        from: fromDate,
        to: toDate,
      );
      revenueSeries.value = series;
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showAppErrorDialog(
          title: 'Revenue Analytics',
          message: e.message,
        );
      }
    } catch (_) {
      await showAppErrorDialog(
        title: 'Revenue Analytics',
        message: 'Failed to load revenue analytics.',
      );
    } finally {
      isRevenueLoading.value = false;
    }
  }

  Future<void> fetchEnrollment() async {
    isEnrollmentLoading.value = true;
    try {
      final series = await _service.fetchEnrollmentChart(
        range: quickRange.value,
        from: fromDate,
        to: toDate,
      );
      enrollmentSeries.value = series;
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showAppErrorDialog(
          title: 'Enrollment Analytics',
          message: e.message,
        );
      }
    } catch (_) {
      await showAppErrorDialog(
        title: 'Enrollment Analytics',
        message: 'Failed to load enrollment analytics.',
      );
    } finally {
      isEnrollmentLoading.value = false;
    }
  }
}
