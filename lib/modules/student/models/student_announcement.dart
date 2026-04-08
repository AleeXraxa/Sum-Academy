class StudentAnnouncement {
  final String id;
  final String title;
  final String message;
  final String targetType;
  final String targetId;
  final String targetName;
  final String senderName;
  final DateTime? createdAt;
  final bool isRead;
  final bool isPinned;

  const StudentAnnouncement({
    required this.id,
    required this.title,
    required this.message,
    required this.targetType,
    required this.targetId,
    required this.targetName,
    required this.senderName,
    required this.createdAt,
    required this.isRead,
    required this.isPinned,
  });

  factory StudentAnnouncement.fromJson(Map<String, dynamic> json) {
    final source = _unwrapMap(json);
    final id = _readString(source, const [
      'id',
      '_id',
      'announcementId',
    ]);
    final title = _readString(source, const [
      'title',
      'subject',
      'heading',
    ]);
    final message = _readString(source, const [
      'message',
      'body',
      'content',
      'description',
    ]);
    final targetType = _readString(source, const [
      'targetType',
      'type',
      'scope',
    ]);
    final targetId = _readString(source, const [
      'targetId',
      'classId',
      'courseId',
    ]);
    final targetName = _readString(source, const [
      'targetName',
      'className',
      'courseTitle',
      'courseName',
    ]);
    final senderName = _resolveSenderName(source);
    final createdAt = _readDateTime(source, const [
      'createdAt',
      'created_at',
      'postedAt',
      'sentAt',
    ]);
    final isRead = _readBool(source, const [
          'isRead',
          'read',
          'seen',
        ]) ??
        false;
    final isPinned = _readBool(source, const [
          'isPinned',
          'pinned',
        ]) ??
        false;

    return StudentAnnouncement(
      id: id,
      title: title,
      message: message,
      targetType: targetType,
      targetId: targetId,
      targetName: targetName,
      senderName: senderName,
      createdAt: createdAt,
      isRead: isRead,
      isPinned: isPinned,
    );
  }

  StudentAnnouncement copyWith({
    String? title,
    String? message,
    String? targetName,
    bool? isRead,
    bool? isPinned,
  }) {
    return StudentAnnouncement(
      id: id,
      title: title ?? this.title,
      message: message ?? this.message,
      targetType: targetType,
      targetId: targetId,
      targetName: targetName ?? this.targetName,
      senderName: senderName,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  String get normalizedType {
    final value = targetType.toLowerCase();
    if (_isDirectType(value)) return 'direct';
    if (value.contains('system')) return 'system';
    if (value.contains('class')) return 'class';
    if (value.contains('course') || value.contains('subject')) return 'course';
    return value.isEmpty ? 'system' : value;
  }

  String get displayTarget {
    if (normalizedType == 'direct' ||
        (normalizedType == 'system' && _looksLikeUid(targetId))) {
      return 'Direct Msg';
    }
    if (targetName.isNotEmpty) return targetName;
    if (targetId.isNotEmpty) {
      final label = normalizedType == 'course'
          ? 'Course'
          : normalizedType == 'class'
              ? 'Class'
              : 'System';
      return '$label $targetId';
    }
    if (normalizedType == 'system') return 'System';
    return normalizedType.isEmpty
        ? 'Announcement'
        : normalizedType[0].toUpperCase() + normalizedType.substring(1);
  }
}

Map<String, dynamic> _unwrapMap(Map<String, dynamic> source) {
  final data = source['data'];
  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  return source;
}

String _readString(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return '';
}

String _resolveSenderName(Map<String, dynamic> map) {
  final direct = _readString(map, const [
    'createdByName',
    'createdByFullName',
    'postedBy',
    'authorName',
    'senderName',
    'userName',
    'createdBy',
    'author',
  ]);
  final normalized = _normalizeName(direct);
  if (normalized.isNotEmpty) return normalized;

  const nestedKeys = [
    'createdBy',
    'sender',
    'author',
    'user',
    'postedBy',
    'from',
    'createdByUser',
  ];
  for (final key in nestedKeys) {
    final value = map[key];
    if (value is Map) {
      final nested = Map<String, dynamic>.from(value);
      final nestedName = _readString(nested, const [
        'fullName',
        'name',
        'displayName',
        'username',
        'email',
      ]);
      final normalizedNested = _normalizeName(nestedName);
      if (normalizedNested.isNotEmpty) return normalizedNested;
    } else if (value is String) {
      final normalizedValue = _normalizeName(value);
      if (normalizedValue.isNotEmpty) return normalizedValue;
    }
  }
  return '';
}

String _normalizeName(String value) {
  final text = value.trim();
  if (text.isEmpty) return '';
  if (text.contains('@')) {
    return text.split('@').first;
  }
  if (_looksLikeUid(text)) return '';
  return text;
}

bool _looksLikeUid(String value) {
  final trimmed = value.trim();
  if (trimmed.length < 18) return false;
  if (trimmed.contains(' ')) return false;
  return true;
}

bool _isDirectType(String value) {
  final lower = value.trim().toLowerCase();
  if (lower.contains('single')) return true;
  if (lower.contains('direct')) return true;
  if (lower.contains('user') && !lower.contains('course') && !lower.contains('class')) {
    return true;
  }
  return false;
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

DateTime? _readDateTime(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value == null) continue;
    if (value is DateTime) return value;
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
  }
  return null;
}
