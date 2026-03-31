class AdminActivityPayload {
  final String title;
  final String subtitle;
  final String type;
  final DateTime? createdAt;
  final String? timeLabel;

  const AdminActivityPayload({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.createdAt,
    required this.timeLabel,
  });

  factory AdminActivityPayload.fromJson(Map<String, dynamic> json) {
    final data = _resolveActivityMap(json);
    final title = _readString(
      data,
      const ['title', 'activity', 'action', 'event', 'name', 'label'],
    );
    final subtitle = _readString(
      data,
      const [
        'subtitle',
        'description',
        'message',
        'summary',
        'detail',
        'body',
      ],
    );
    final type = _readString(
      data,
      const ['type', 'category', 'kind', 'eventType'],
    );
    final createdAt = _readDate(
      data,
      const ['createdAt', 'created_at', 'timestamp', 'time', 'date'],
    );
    final timeLabel = _readString(
      data,
      const ['timeLabel', 'time_text', 'timeText'],
    );

    return AdminActivityPayload(
      title: title.isNotEmpty ? title : 'Activity update',
      subtitle: subtitle,
      type: type,
      createdAt: createdAt,
      timeLabel: timeLabel.isNotEmpty ? timeLabel : null,
    );
  }
}

Map<String, dynamic> _resolveActivityMap(Map<String, dynamic> data) {
  final nestedKeys = ['activity', 'log', 'item', 'data'];
  for (final key in nestedKeys) {
    final value = data[key];
    if (value is Map<String, dynamic>) {
      return value;
    }
  }
  return data;
}

String _readString(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = data[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return '';
}

DateTime? _readDate(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = data[key];
    final parsed = _parseDate(value);
    if (parsed != null) {
      return parsed;
    }
  }
  return null;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) {
    if (value > 1000000000000) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.fromMillisecondsSinceEpoch(value * 1000);
  }
  if (value is num) {
    return _parseDate(value.toInt());
  }
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) return parsed;
    final asInt = int.tryParse(trimmed);
    if (asInt != null) return _parseDate(asInt);
  }
  if (value is Map) {
    final nestedKeys = ['_seconds', 'seconds', 'value'];
    for (final key in nestedKeys) {
      final parsed = _parseDate(value[key]);
      if (parsed != null) return parsed;
    }
  }
  return null;
}
