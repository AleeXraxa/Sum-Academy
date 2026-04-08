import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/modules/admin/models/admin_announcement.dart';

class AdminAnnouncementService {
  AdminAnnouncementService({ApiClient? client})
      : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<AdminAnnouncement>> fetchAnnouncements() async {
    final response = await _client.get('/admin/announcements', auth: true);
    final data = response['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => AdminAnnouncement.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    }
    if (data is Map) {
      final items = data['items'] ?? data['announcements'] ?? data['list'];
      if (items is List) {
        return items
            .whereType<Map>()
            .map((item) => AdminAnnouncement.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .toList();
      }
    }
    return [];
  }

  Future<AdminAnnouncement> createAnnouncement({
    required String title,
    required String message,
    required String targetType,
    required String audienceRole,
    String? targetId,
    bool sendEmail = false,
    bool isPinned = false,
  }) async {
    final body = {
      'title': title,
      'message': message,
      'targetType': targetType,
      'audienceRole': audienceRole,
      'sendEmail': sendEmail,
      'isPinned': isPinned,
    };
    if (targetId != null && targetId.trim().isNotEmpty) {
      body['targetId'] = targetId.trim();
    }
    final response =
        await _client.post('/admin/announcements', auth: true, body: body);
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return AdminAnnouncement.fromJson(data);
    }
    return AdminAnnouncement.fromJson(body);
  }

  Future<void> updateAnnouncement({
    required String id,
    required String title,
    required String message,
    bool isPinned = false,
  }) async {
    final body = {
      'title': title,
      'message': message,
      'isPinned': isPinned,
    };
    await _client.put('/admin/announcements/$id', auth: true, body: body);
  }

  Future<void> deleteAnnouncement(String id) async {
    await _client.delete('/admin/announcements/$id', auth: true);
  }

  Future<void> togglePin({
    required String id,
    required bool isPinned,
  }) async {
    final body = {'isPinned': isPinned};
    await _client.patch('/admin/announcements/$id/pin', auth: true, body: body);
  }
}
