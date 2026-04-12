import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/modules/student/models/student_payment.dart';

class StudentPaymentsService {
  StudentPaymentsService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  static DateTime? _paymentsFetchedAt;
  static List<StudentPaymentSummary>? _paymentsCache;
  static Future<List<StudentPaymentSummary>>? _paymentsInFlight;

  static DateTime? _installmentsFetchedAt;
  static List<StudentInstallmentPlan>? _installmentsCache;
  static Future<List<StudentInstallmentPlan>>? _installmentsInFlight;

  static const Duration _paymentsTtl = Duration(minutes: 1);
  static const Duration _installmentsTtl = Duration(minutes: 15);

  Future<List<StudentPaymentSummary>> fetchPayments({bool force = false}) async {
    final now = DateTime.now();
    if (!force &&
        _paymentsCache != null &&
        _paymentsFetchedAt != null &&
        now.difference(_paymentsFetchedAt!) < _paymentsTtl) {
      return _paymentsCache!;
    }
    final inFlight = _paymentsInFlight;
    if (inFlight != null) return inFlight;

    _paymentsInFlight = () async {
      try {
        final response = await _client.get('/payments/my-payments', auth: true);
        final data = response['data'] ?? response;
        final list = _extractList(data);
        final parsed = list.map(StudentPaymentSummary.fromJson).toList();
        _paymentsCache = parsed;
        _paymentsFetchedAt = DateTime.now();
        return parsed;
      } on ApiException catch (e) {
        if (e.statusCode == 429 && _paymentsCache != null) {
          return _paymentsCache!;
        }
        rethrow;
      } finally {
        _paymentsInFlight = null;
      }
    }();
    return _paymentsInFlight!;
  }

  Future<List<StudentInstallmentPlan>> fetchInstallments({
    bool force = false,
  }) async {
    final now = DateTime.now();
    if (!force &&
        _installmentsCache != null &&
        _installmentsFetchedAt != null &&
        now.difference(_installmentsFetchedAt!) < _installmentsTtl) {
      return _installmentsCache!;
    }
    final inFlight = _installmentsInFlight;
    if (inFlight != null) return inFlight;

    _installmentsInFlight = () async {
      try {
        final response =
            await _client.get('/payments/my-installments', auth: true);
        final data = response['data'] ?? response;
        final list = _extractList(data);
        final parsed = list.map(StudentInstallmentPlan.fromJson).toList();
        _installmentsCache = parsed;
        _installmentsFetchedAt = DateTime.now();
        return parsed;
      } on ApiException catch (e) {
        if (e.statusCode == 429 && _installmentsCache != null) {
          return _installmentsCache!;
        }
        rethrow;
      } finally {
        _installmentsInFlight = null;
      }
    }();
    return _installmentsInFlight!;
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
