import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/modules/admin/models/admin_installment.dart';

class AdminInstallmentService {
  AdminInstallmentService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<AdminInstallmentPlan>> fetchInstallments({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  }) async {
    final response = await _client.get(
      '/admin/installments',
      auth: true,
      query: {
        if (page > 0) 'page': page,
        if (limit > 0) 'limit': limit,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    final data = response['data'];
    final list = _extractList(data);
    return list.map(AdminInstallmentPlan.fromJson).toList();
  }

  Future<List<InstallmentItem>> fetchInstallmentDetail(String planId) async {
    final response = await _client.get(
      '/admin/installments/$planId',
      auth: true,
    );
    final data = response['data'];
    final items = _extractInstallments(data);
    return items.map(InstallmentItem.fromJson).toList();
  }

  Future<void> markInstallmentPaid({
    required String planId,
    required int number,
  }) async {
    await _client.patch(
      '/admin/installments/$planId/$number/pay',
      auth: true,
    );
  }

  Future<void> sendReminder({required String studentId}) async {
    await _client.post(
      '/admin/installments/send-reminders',
      auth: true,
      body: {'studentId': studentId},
    );
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final list = data['installments'] ?? data['data'] ?? data['items'];
      if (list is List) {
        return list
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }
    return [];
  }

  List<Map<String, dynamic>> _extractInstallments(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final list = data['installments'] ??
          data['items'] ??
          data['data'] ??
          data['schedule'];
      if (list is List) {
        return list
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }
    return [];
  }
}
