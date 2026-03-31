import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/modules/admin/models/admin_activity_payload.dart';

class AdminActivityService {
  AdminActivityService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<AdminActivityPayload>> fetchRecentActivity() async {
    final response = await _client.get('/admin/recent-activity', auth: true);
    final data = response['data'] ?? response;
    final items = _extractList(data);
    return items.map(AdminActivityPayload.fromJson).toList();
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final list = data['activity'] ?? data['activities'] ?? data['data'];
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
