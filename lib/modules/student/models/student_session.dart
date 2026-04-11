class StudentSession {
  final String id;
  final String topic;
  final String classId;
  final String className;
  final String batchCode;
  final String teacherId;
  final String teacherName;
  final String platform;
  final String meetingLink;
  final String status; // upcoming | active | ended | completed | cancelled (backend-defined)
  final bool canJoin;
  final int joinedCount;
  final int totalStudents;
  final int elapsedSeconds;
  final int remainingSeconds;
  final bool isLocked;
  final String recordingUrl;
  final DateTime? joinOpensAt;
  final DateTime? joinClosesAt;
  final DateTime? startAt;
  final DateTime? endAt;

  const StudentSession({
    required this.id,
    required this.topic,
    required this.classId,
    required this.className,
    required this.batchCode,
    required this.teacherId,
    required this.teacherName,
    required this.platform,
    required this.meetingLink,
    required this.status,
    required this.canJoin,
    required this.joinedCount,
    required this.totalStudents,
    required this.elapsedSeconds,
    required this.remainingSeconds,
    required this.isLocked,
    required this.recordingUrl,
    required this.joinOpensAt,
    required this.joinClosesAt,
    required this.startAt,
    required this.endAt,
  });

  factory StudentSession.empty({String id = ''}) {
    return StudentSession(
      id: id,
      topic: '',
      classId: '',
      className: '',
      batchCode: '',
      teacherId: '',
      teacherName: '',
      platform: '',
      meetingLink: '',
      status: '',
      canJoin: false,
      joinedCount: 0,
      totalStudents: 0,
      elapsedSeconds: 0,
      remainingSeconds: 0,
      isLocked: false,
      recordingUrl: '',
      joinOpensAt: null,
      joinClosesAt: null,
      startAt: null,
      endAt: null,
    );
  }

  factory StudentSession.fromAny(dynamic value) {
    if (value is Map<String, dynamic>) return StudentSession.fromJson(value);
    if (value is Map) return StudentSession.fromJson(Map<String, dynamic>.from(value));
    return StudentSession.empty();
  }

  factory StudentSession.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] is Map) ? Map<String, dynamic>.from(json['data'] as Map) : json;
    final joinWindow = data['joinWindow'] is Map
        ? Map<String, dynamic>.from(data['joinWindow'] as Map)
        : null;
    final timing = data['timing'] is Map ? Map<String, dynamic>.from(data['timing'] as Map) : null;

    DateTime? readDate(dynamic raw) {
      if (raw == null) return null;
      if (raw is DateTime) return raw;
      final text = raw.toString().trim();
      if (text.isEmpty) return null;
      return DateTime.tryParse(text);
    }

    DateTime? readDateTimeFromDateAndTime(dynamic rawDate, dynamic rawTime) {
      final dateText = rawDate?.toString().trim() ?? '';
      final timeText = rawTime?.toString().trim() ?? '';
      if (dateText.isEmpty || timeText.isEmpty) return null;

      final parsedDate = DateTime.tryParse(dateText);
      if (parsedDate == null) return null;

      final cleanedTime = timeText
          .replaceAll('AM', '')
          .replaceAll('PM', '')
          .replaceAll('am', '')
          .replaceAll('pm', '')
          .trim();
      final timeParts = cleanedTime.split(':');
      if (timeParts.length < 2) return null;
      final hours = int.tryParse(timeParts[0]) ?? 0;
      final minutes = int.tryParse(timeParts[1]) ?? 0;
      return DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
        hours,
        minutes,
      );
    }

    String readString(String key) => data[key]?.toString().trim() ?? '';
    bool readBool(String key) => data[key] == true;
    String readFirstString(List<String> keys) {
      for (final key in keys) {
        final text = readString(key);
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    int readInt(String key) {
      final value = data[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim()) ?? 0;
      return 0;
    }

    final dateText = readFirstString(const [
      'date',
      'sessionDate',
      'day',
    ]);
    final startTimeText = readFirstString(const [
      'startTime',
      'start_time',
      'startsAt',
      'startAt',
    ]);
    final endTimeText = readFirstString(const [
      'endTime',
      'end_time',
      'endsAt',
      'endAt',
    ]);

    final startAt = readDate(
          timing?['startAt'] ?? data['startAt'] ?? data['startsAt'],
        ) ??
        readDateTimeFromDateAndTime(dateText, startTimeText);
    final endAt = readDate(
          timing?['endAt'] ?? data['endAt'] ?? data['endsAt'],
        ) ??
        readDateTimeFromDateAndTime(dateText, endTimeText);

    final id = readFirstString(const [
      'id',
      '_id',
      'sessionId',
      'session_id',
    ]);
    final meetingLink = readFirstString(const [
      'meetingLink',
      'meetingUrl',
      'link',
      'url',
    ]);
    final recordingUrl = readFirstString(const [
      'recordingUrl',
      'recordingURL',
      'playbackUrl',
      'playbackURL',
      'signedUrl',
      'signedURL',
      'streamUrl',
      'streamURL',
    ]);

    var joinOpensAt = readDate(joinWindow?['opensAt'] ?? data['opensAt']);
    var joinClosesAt = readDate(joinWindow?['closesAt'] ?? data['closesAt']);
    // Fallback: join opens 10 minutes before start, closes at start.
    if (joinOpensAt == null && startAt != null) {
      joinOpensAt = startAt.subtract(const Duration(minutes: 10));
    }
    if (joinClosesAt == null && startAt != null) {
      joinClosesAt = startAt;
    }

    return StudentSession(
      id: id,
      topic: readString('topic'),
      classId: readString('classId'),
      className: readString('className'),
      batchCode: readString('batchCode'),
      teacherId: readString('teacherId'),
      teacherName: readString('teacherName'),
      platform: readString('platform'),
      meetingLink: meetingLink,
      status: readString('status'),
      canJoin: readBool('canJoin'),
      joinedCount: readInt('joinedCount'),
      totalStudents: readInt('totalStudents'),
      elapsedSeconds: readInt('elapsedSeconds'),
      remainingSeconds: readInt('remainingSeconds'),
      isLocked: readBool('isLocked'),
      recordingUrl: recordingUrl,
      joinOpensAt: joinOpensAt,
      joinClosesAt: joinClosesAt,
      startAt: startAt,
      endAt: endAt,
    );
  }

  bool get isLive {
    final now = DateTime.now();
    if (status.toLowerCase() == 'active') return true;
    if (startAt == null || endAt == null) return false;
    return now.isAfter(startAt!) && now.isBefore(endAt!);
  }

  bool get hasEnded {
    final now = DateTime.now();
    final statusLower = status.toLowerCase();
    if (statusLower == 'ended' || statusLower == 'completed' || statusLower == 'cancelled') {
      return true;
    }
    if (endAt == null) return false;
    return now.isAfter(endAt!);
  }
}
