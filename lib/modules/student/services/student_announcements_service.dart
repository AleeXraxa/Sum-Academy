import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/modules/student/models/student_announcement.dart';

class StudentAnnouncementsService {
  StudentAnnouncementsService({ApiClient? client})
      : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<StudentAnnouncement>> fetchAnnouncements() async {
    final response = await _client.get('/student/announcements', auth: true);
    final data = response['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => StudentAnnouncement.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    }
    if (data is Map) {
      final items = data['items'] ?? data['announcements'] ?? data['list'];
      if (items is List) {
        return items
            .whereType<Map>()
            .map((item) => StudentAnnouncement.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .toList();
      }
    }
    return [];
  }

  Future<void> markRead(String id) async {
    await _client.patch('/student/announcements/$id/read', auth: true);
  }
}
