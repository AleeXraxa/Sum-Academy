class AdminAnnouncement {
  final String id;
  final String title;
  final String message;
  final String targetType;
  final String targetId;
  final String targetName;
  final String audienceRole;
  final bool isPinned;
  final bool sendEmail;
  final int emailsSent;
  final int reachedCount;
  final String createdBy;
  final DateTime? createdAt;

  const AdminAnnouncement({
    required this.id,
    required this.title,
    required this.message,
    required this.targetType,
    required this.targetId,
    required this.targetName,
    required this.audienceRole,
    required this.isPinned,
    required this.sendEmail,
    required this.emailsSent,
    required this.reachedCount,
    required this.createdBy,
    required this.createdAt,
  });

  factory AdminAnnouncement.fromJson(Map<String, dynamic> json) {
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
      'target',
    ]);
    final targetId = _readString(source, const [
      'targetId',
      'classId',
      'courseId',
      'userId',
      'studentId',
    ]);
    final targetName = _readString(source, const [
      'targetName',
      'className',
      'courseTitle',
      'courseName',
      'userName',
      'studentName',
    ]);
    final audienceRole = _readString(source, const [
      'audienceRole',
      'audience',
      'role',
      'audienceType',
    ]);
    final isPinned = _readBool(source, const [
          'isPinned',
          'pinned',
        ]) ??
        false;
    final sendEmail = _readBool(source, const [
          'sendEmail',
          'email',
          'emailSent',
        ]) ??
        false;
    final emailsSent = _readInt(source, const [
      'emailsSent',
      'emailCount',
      'sentEmails',
    ]);
    final reachedCount = _readInt(source, const [
      'reachedCount',
      'reachCount',
      'totalReached',
      'recipients',
    ]);
    final createdBy = _readString(source, const [
      'createdByName',
      'postedBy',
      'authorName',
      'senderName',
      'userName',
    ]);
    final createdAt = _readDateTime(source, const [
      'createdAt',
      'created_at',
      'postedAt',
      'sentAt',
    ]);

    return AdminAnnouncement(
      id: id,
      title: title,
      message: message,
      targetType: targetType,
      targetId: targetId,
      targetName: targetName,
      audienceRole: audienceRole,
      isPinned: isPinned,
      sendEmail: sendEmail,
      emailsSent: emailsSent,
      reachedCount: reachedCount,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }

  AdminAnnouncement copyWith({
    String? title,
    String? message,
    String? targetType,
    String? targetId,
    String? targetName,
    String? audienceRole,
    bool? isPinned,
    bool? sendEmail,
    int? emailsSent,
    int? reachedCount,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return AdminAnnouncement(
      id: id,
      title: title ?? this.title,
      message: message ?? this.message,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      targetName: targetName ?? this.targetName,
      audienceRole: audienceRole ?? this.audienceRole,
      isPinned: isPinned ?? this.isPinned,
      sendEmail: sendEmail ?? this.sendEmail,
      emailsSent: emailsSent ?? this.emailsSent,
      reachedCount: reachedCount ?? this.reachedCount,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get normalizedType {
    final value = targetType.toLowerCase();
    if (value.contains('system')) return 'system';
    if (value.contains('class')) return 'class';
    if (value.contains('course') || value.contains('subject')) return 'course';
    if (value.contains('single') || value.contains('user')) return 'single_user';
    return value;
  }

  String get displayTarget {
    if (targetName.isNotEmpty) return targetName;
    if (normalizedType == 'system') return 'System-wide';
    if (normalizedType == 'single_user') return 'Single user';
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

int _readInt(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value == null) continue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
  }
  return 0;
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
