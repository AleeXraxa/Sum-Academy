import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/modules/student/models/student_payment.dart';

class StudentPaymentsService {
  StudentPaymentsService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<StudentPaymentSummary>> fetchPayments() async {
    final response = await _client.get('/payments/my-payments', auth: true);
    final data = response['data'] ?? response;
    final list = _extractList(data);
    return list.map(StudentPaymentSummary.fromJson).toList();
  }

  Future<List<StudentInstallmentPlan>> fetchInstallments() async {
    final response = await _client.get('/payments/my-installments', auth: true);
    final data = response['data'] ?? response;
    final list = _extractList(data);
    return list.map(StudentInstallmentPlan.fromJson).toList();
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final list = data['data'] ?? data['items'] ?? data['payments'];
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
