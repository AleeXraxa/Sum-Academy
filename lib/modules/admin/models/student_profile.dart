class StudentProfile {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String address;
  final String caste;
  final String district;
  final String domicile;
  final String fatherName;
  final String fatherOccupation;
  final String fatherPhone;
  final String phoneNumber;
  final DateTime? joinedAt;
  final DateTime? lastLoginAt;
  final String device;
  final String assignedWebDevice;
  final String assignedWebIp;
  final String assignedMobileDevice;
  final String assignedMobileIp;

  const StudentProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.address,
    required this.caste,
    required this.district,
    required this.domicile,
    required this.fatherName,
    required this.fatherOccupation,
    required this.fatherPhone,
    required this.phoneNumber,
    required this.joinedAt,
    required this.lastLoginAt,
    required this.device,
    required this.assignedWebDevice,
    required this.assignedWebIp,
    required this.assignedMobileDevice,
    required this.assignedMobileIp,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    final uid = _readString(json, ['uid', '_id', 'id', 'userId']);
    final fullName = _readString(json, ['fullName', 'name']);
    final email = _readString(json, ['email']);
    final phoneNumber = _readString(json, [
      'phone',
      'phoneNumber',
      'mobile',
      'mobileNumber',
    ]);
    final phone = phoneNumber;
    final role = _readString(json, ['role'], fallback: 'student');
    final address = _readString(json, ['address', 'addr', 'location']);
    final caste = _readString(json, ['caste']);
    final district = _readString(json, ['district']);
    final domicile = _readString(json, ['domicile']);
    final fatherName = _readString(json, ['fatherName', 'father']);
    final fatherOccupation = _readString(json, [
      'fatherOccupation',
      'fatherJob',
    ]);
    final fatherPhone = _readString(json, ['fatherPhone', 'fatherPhoneNumber']);
    final joinedAt = _readDate(json, [
      'createdAt',
      'created_at',
      'joinedAt',
      'joinedDate',
      'joined_date',
      'enrolledAt',
      'enrollmentDate',
    ]);
    final lastLoginAt = _readDate(json, [
      'lastLoginAt',
      'last_login_at',
      'lastLogin',
      'last_login',
      'lastSignInAt',
      'lastSignIn',
    ]);
    var assignedMobileDevice = _readString(json, [
      'assignedMobileDevice',
      'assignedDevice',
      'deviceName',
      'device',
    ]);
    var assignedWebDevice = _readString(json, [
      'assignedWebDevice',
      'assignedWeb',
      'assignedWebDEVICE',
      'assignedWebDeviceName',
      'webDevice',
    ]);
    var assignedMobileIp = _readString(json, [
      'lastKnownMobileIp',
      'mobileIp',
      'mobileIP',
      'assignedMobileIp',
      'assignedMobileIP',
      'lastKnownIP',
    ]);
    var assignedWebIp = _readString(json, [
      'assignedWebIp',
      'assignedWebIP',
      'assignedWebIpAddress',
      'lastKnownWebIp',
      'lastKnownWebIP',
      'webIp',
      'webIP',
      'webIpAddress',
    ]);

    assignedMobileDevice = assignedMobileDevice.isNotEmpty
        ? assignedMobileDevice
        : _readNestedString(json, _securityContainers, [
            'assignedMobileDevice',
            'deviceName',
            'device',
          ]);
    assignedWebDevice = assignedWebDevice.isNotEmpty
        ? assignedWebDevice
        : _readNestedString(json, _securityContainers, [
            'assignedWebDevice',
            'assignedWebDeviceName',
            'webDevice',
          ]);
    assignedMobileIp = assignedMobileIp.isNotEmpty
        ? assignedMobileIp
        : _readNestedString(json, _securityContainers, [
            'assignedMobileIp',
            'mobileIp',
            'mobileIP',
            'lastKnownMobileIp',
          ]);
    assignedWebIp = assignedWebIp.isNotEmpty
        ? assignedWebIp
        : _readNestedString(json, _securityContainers, [
            'assignedWebIp',
            'assignedWebIP',
            'webIp',
            'webIP',
            'lastKnownWebIp',
          ]);
    final device = assignedMobileDevice.isNotEmpty
        ? assignedMobileDevice
        : 'N/A';

    return StudentProfile(
      uid: uid,
      fullName: fullName,
      email: email,
      phone: phone,
      role: role,
      address: address,
      caste: caste,
      district: district,
      domicile: domicile,
      fatherName: fatherName,
      fatherOccupation: fatherOccupation,
      fatherPhone: fatherPhone,
      phoneNumber: phoneNumber,
      joinedAt: joinedAt,
      lastLoginAt: lastLoginAt,
      device: device,
      assignedWebDevice: assignedWebDevice,
      assignedWebIp: assignedWebIp,
      assignedMobileDevice: assignedMobileDevice,
      assignedMobileIp: assignedMobileIp,
    );
  }
}

class StudentProgress {
  final int enrolledCourses;
  final int certificates;
  final int completedCourses;
  final double avgProgress;
  final List<StudentCourseProgress> courses;
  final List<StudentCertificate> certificatesList;

  const StudentProgress({
    required this.enrolledCourses,
    required this.certificates,
    required this.completedCourses,
    required this.avgProgress,
    required this.courses,
    required this.certificatesList,
  });

  factory StudentProgress.fromJson(Map<String, dynamic> json) {
    final root = _extractMap(json, ['data', 'progress']) ?? json;
    final stats = _extractMap(root, ['stats', 'summary', 'metrics']) ?? root;
    final coursesList = _extractList(root, [
      'courses',
      'enrolledCourses',
      'courseProgress',
      'progress',
      'items',
      'list',
    ]);
    final certsList = _extractList(root, [
      'certificates',
      'certificatesList',
      'awards',
      'items',
      'list',
    ]);

    final enrolled = _readInt(stats, [
      'enrolledCourses',
      'totalCourses',
      'courseCount',
    ], fallback: coursesList.length);
    final certificates = _readInt(stats, [
      'certificates',
      'certificatesCount',
      'earnedCertificates',
    ], fallback: certsList.length);
    final completed = _readInt(stats, [
      'completedCourses',
      'completedCount',
      'coursesCompleted',
    ]);
    final avg = _readDouble(stats, [
      'avgProgress',
      'averageProgress',
      'progressAverage',
    ]);

    return StudentProgress(
      enrolledCourses: enrolled,
      certificates: certificates,
      completedCourses: completed,
      avgProgress: avg,
      courses: coursesList.map(StudentCourseProgress.fromJson).toList(),
      certificatesList: certsList.map(StudentCertificate.fromJson).toList(),
    );
  }
}

class StudentCourseProgress {
  final String id;
  final String title;
  final double progress;
  final DateTime? enrolledAt;

  const StudentCourseProgress({
    required this.id,
    required this.title,
    required this.progress,
    required this.enrolledAt,
  });

  factory StudentCourseProgress.fromJson(Map<String, dynamic> json) {
    return StudentCourseProgress(
      id: _readString(json, ['courseId', 'id', '_id']),
      title: _readString(json, ['courseName', 'title', 'name'], fallback: '—'),
      progress: _readDouble(json, [
        'progress',
        'completion',
        'percent',
        'percentage',
      ], fallback: 0),
      enrolledAt: _readDate(json, ['enrolledAt', 'createdAt', 'joinedAt']),
    );
  }

  double get progressValue {
    final value = progress <= 1 ? progress * 100 : progress;
    return (value / 100).clamp(0, 1);
  }

  String get progressLabel {
    final value = progress <= 1 ? progress * 100 : progress;
    return '${value.round()}%';
  }
}

class StudentCertificate {
  final String id;
  final String courseName;
  final DateTime? issuedAt;

  const StudentCertificate({
    required this.id,
    required this.courseName,
    required this.issuedAt,
  });

  factory StudentCertificate.fromJson(Map<String, dynamic> json) {
    return StudentCertificate(
      id: _readString(json, ['certId', 'certificateId', 'id', '_id', 'code']),
      courseName: _readString(json, ['courseName', 'course', 'title', 'name']),
      issuedAt: _readDate(json, ['issuedAt', 'createdAt']),
    );
  }
}

class StudentProfileData {
  final StudentProfile profile;
  final StudentProgress progress;

  const StudentProfileData({required this.profile, required this.progress});
}

String _readString(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return fallback;
}

const List<String> _securityContainers = [
  'security',
  'device',
  'devices',
  'meta',
  'profile',
  'user',
  'account',
  'auth',
  'session',
  'sessions',
  'lastDevice',
  'last_device',
  'deviceInfo',
  'ip',
  'ips',
];

String _readNestedString(
  Map<String, dynamic> json,
  List<String> containerKeys,
  List<String> keys,
) {
  for (final containerKey in containerKeys) {
    final container = json[containerKey];
    if (container is Map<String, dynamic>) {
      final value = _readString(container, keys);
      if (value.isNotEmpty) return value;
    }
  }
  return '';
}

int _readInt(Map<String, dynamic> json, List<String> keys, {int fallback = 0}) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    if (value is num) return value.toInt();
    final parsed = int.tryParse(value.toString());
    if (parsed != null) return parsed;
  }
  return fallback;
}

double _readDouble(
  Map<String, dynamic> json,
  List<String> keys, {
  double fallback = 0,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    if (value is num) return value.toDouble();
    final raw = value.toString().trim();
    if (raw.isEmpty) continue;
    final cleaned = raw.replaceAll('%', '');
    final parsed = double.tryParse(cleaned);
    if (parsed != null) return parsed;
  }
  return fallback;
}

DateTime? _readDate(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    if (value is DateTime) return value;
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    if (value is int) {
      final parsed = value > 1000000000000
          ? DateTime.fromMillisecondsSinceEpoch(value)
          : DateTime.fromMillisecondsSinceEpoch(value * 1000);
      return parsed;
    }
    if (value is Map) {
      final seconds = value['seconds'] ?? value['_seconds'];
      final nanos = value['nanoseconds'] ?? value['_nanoseconds'] ?? 0;
      if (seconds is int) {
        return DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanos is int ? (nanos / 1000000).round() : 0),
        );
      }
    }
  }
  return null;
}

Map<String, dynamic>? _extractMap(
  Map<String, dynamic> json,
  List<String> keys,
) {
  for (final key in keys) {
    final value = json[key];
    if (value is Map<String, dynamic>) return value;
  }
  return null;
}

List<Map<String, dynamic>> _extractList(
  Map<String, dynamic> json,
  List<String> keys,
) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
  }
  return [];
}
