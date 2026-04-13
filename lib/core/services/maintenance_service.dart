import 'package:sum_academy/core/services/api_client.dart';

class MaintenanceStatus {
  final bool enabled;
  final String message;

  const MaintenanceStatus({
    required this.enabled,
    required this.message,
  });

  factory MaintenanceStatus.fromAny(dynamic payload) {
    if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);

      // Common patterns:
      // { maintenance: { enabled: true, message: "..." } }
      final maintenance = map['maintenance'];
      if (maintenance is Map) {
        final m = Map<String, dynamic>.from(maintenance);
        final enabled = _readBool(m, const ['enabled', 'isEnabled', 'active']) ??
            _readBool(map, const [
              'maintenanceEnabled',
              'maintenanceMode',
              'isMaintenance',
            ]) ??
            false;
        final message = _readString(m, const ['message', 'text', 'note']) ??
            _readString(map, const ['maintenanceMessage']) ??
            '';
        return MaintenanceStatus(
          enabled: enabled,
          message: message,
        );
      }

      final enabled = _readBool(map, const [
            'maintenanceEnabled',
            'maintenanceMode',
            'isMaintenance',
            'enabled',
          ]) ??
          false;
      final message =
          _readString(map, const ['maintenanceMessage', 'message']) ?? '';

      return MaintenanceStatus(enabled: enabled, message: message);
    }

    return const MaintenanceStatus(enabled: false, message: '');
  }
}

class MaintenanceService {
  MaintenanceService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<MaintenanceStatus> fetchStatus() async {
    // `/settings` is the app-wide settings endpoint already used elsewhere.
    // Maintenance fields are parsed defensively because the payload shape varies
    // between backend versions.
    final response = await _client.get('/settings');
    final data = response['data'] ?? response;
    return MaintenanceStatus.fromAny(data);
  }

  Future<void> toggleMaintenanceAsAdmin() async {
    await _client.put('/admin/settings/maintenance', auth: true);
  }
}

bool? _readBool(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value == null) continue;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.trim().toLowerCase();
      if (lower == 'true' || lower == 'yes' || lower == '1') return true;
      if (lower == 'false' || lower == 'no' || lower == '0') return false;
    }
  }
  return null;
}

String? _readString(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return null;
}

