import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/modules/admin/models/admin_payment.dart';

class AdminPaymentService {
  AdminPaymentService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<AdminPayment>> fetchPayments({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  }) async {
    final response = await _client.get(
      '/admin/payments',
      auth: true,
      query: {
        if (page > 0) 'page': page,
        if (limit > 0) 'limit': limit,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    final data = response['data'];
    final payments = _extractList(data);
    return payments.map(AdminPayment.fromJson).toList();
  }

  Future<AdminPayment> verifyPayment({
    required String paymentId,
    required String action,
  }) async {
    try {
      final response = await _client.patch(
        '/admin/payments/$paymentId/verify',
        auth: true,
        body: {'action': action},
        query: {'action': action},
      );
      final payload = _extractItem(response['data']);
      if (payload.isEmpty) {
        return AdminPayment.fromJson({
          'id': paymentId,
          'status': action == 'approve' ? 'approved' : 'rejected',
        });
      }
      return AdminPayment.fromJson(payload);
    } on ApiException catch (e) {
      final lower = e.message.toLowerCase();
      if (lower.contains('action') || lower.contains('approve')) {
        final response = await _client.patch(
          '/admin/payments/$paymentId/verify',
          auth: true,
          query: {'action': action},
        );
        final payload = _extractItem(response['data']);
        if (payload.isEmpty) {
          return AdminPayment.fromJson({
            'id': paymentId,
            'status': action == 'approve' ? 'approved' : 'rejected',
          });
        }
        return AdminPayment.fromJson(payload);
      }
      rethrow;
    }
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final list = data['payments'] ?? data['data'] ?? data['items'];
      if (list is List) {
        return list
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }
    return [];
  }

  Map<String, dynamic> _extractItem(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['payment'] is Map) {
        return Map<String, dynamic>.from(data['payment'] as Map);
      }
      if (data['doc'] is Map) {
        return Map<String, dynamic>.from(data['doc'] as Map);
      }
      if (data['data'] is Map) {
        return Map<String, dynamic>.from(data['data'] as Map);
      }
      return data;
    }
    return {};
  }
}
