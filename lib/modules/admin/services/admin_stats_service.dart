import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/modules/admin/models/admin_stats.dart';

class AdminStatsService {
  AdminStatsService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<AdminStatsPayload> fetchStats() async {
    final response = await _client.get('/admin/stats', auth: true);
    final data = response['data'] ?? response;
    return AdminStatsPayload.fromAny(data);
  }
}
