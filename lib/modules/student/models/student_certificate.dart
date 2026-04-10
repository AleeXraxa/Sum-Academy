class StudentCertificate {
  final String id;
  final String certificateId;
  final String title;
  final String studentName;
  final String className;
  final String classCode;
  final String subjectName;
  final String courseName;
  final String authorizedBy;
  final DateTime? issuedAt;
  final String pdfUrl;

  const StudentCertificate({
    required this.id,
    required this.certificateId,
    required this.title,
    required this.studentName,
    required this.className,
    required this.classCode,
    required this.subjectName,
    required this.courseName,
    required this.authorizedBy,
    required this.issuedAt,
    required this.pdfUrl,
  });

  factory StudentCertificate.fromJson(Map<String, dynamic> map) {
    final id = _readFirstString([
      _readString(map, const ['id', '_id', 'certId', 'certificateId']),
      _readNestedString(map, const ['id', '_id', 'certId', 'certificateId']),
    ]);
    final certificateId = _readFirstString([
      _readString(map, const ['certificateId', 'certId', 'code']),
      _readNestedString(map, const ['certificateId', 'certId', 'code']),
    ]);
    final completionTitle = _readFirstString([
      _readString(map, const ['completionTitle']),
      _readNestedString(map, const ['completionTitle']),
    ]);
    final title = _readString(
      map,
      const ['title', 'courseTitle', 'subjectTitle', 'courseName', 'subjectName'],
    );
    final studentName = _readFirstString([
      _readString(map, const [
        'studentName',
        'fullName',
        'name',
        'student',
      ]),
      _readNestedString(map, const [
        'studentName',
        'fullName',
        'name',
        'student',
      ]),
    ]);
    final className = _readFirstString([
      _readString(map, const [
        'className',
        'batchName',
        'cohortName',
        'groupName',
      ]),
      _readNestedString(map, const [
        'className',
        'batchName',
        'cohortName',
        'groupName',
      ]),
    ]);
    final classCode = _readFirstString([
      _readString(map, const [
        'classCode',
        'batchCode',
        'code',
        'classRef',
      ]),
      _readNestedString(map, const [
        'classCode',
        'batchCode',
        'code',
        'classRef',
      ]),
    ]);
    final subjectName = _readFirstString([
      _readString(map, const [
        'subjectName',
        'courseName',
        'courseTitle',
        'subjectTitle',
      ]),
      _readNestedString(map, const [
        'subjectName',
        'courseName',
        'courseTitle',
        'subjectTitle',
      ]),
    ]);
    final courseName = _readFirstString([
      _readString(map, const [
        'courseName',
        'courseTitle',
        'subjectName',
        'subjectTitle',
      ]),
      _readNestedString(map, const [
        'courseName',
        'courseTitle',
        'subjectName',
        'subjectTitle',
      ]),
    ]);
    final authorizedBy = _readFirstString([
      _readString(map, const [
        'authorizedBy',
        'issuer',
        'issuedBy',
        'organization',
        'orgName',
      ]),
      _readNestedString(map, const [
        'authorizedBy',
        'issuer',
        'issuedBy',
        'organization',
        'orgName',
      ]),
    ]);
    final issuedAt = _readDate(map, const [
      'issuedAt',
      'issueDate',
      'createdAt',
      'date',
    ]);
    final verificationUrl = _readFirstString([
      _readString(map, const ['verificationUrl', 'verifyUrl', 'verifyURL']),
      _readNestedString(map, const ['verificationUrl', 'verifyUrl', 'verifyURL']),
    ]);
    final pdfUrl = _readFirstString([
      _readString(map, const [
        'pdfUrl',
        'pdfURL',
        'downloadUrl',
        'downloadURL',
        'fileUrl',
        'fileURL',
        'certificateUrl',
        'certificateURL',
        'url',
        'link',
        'pdf',
        'certificatePdf',
        'certificatePDF',
      ]),
      _readNestedString(map, const [
        'pdfUrl',
        'pdfURL',
        'downloadUrl',
        'downloadURL',
        'fileUrl',
        'fileURL',
        'certificateUrl',
        'certificateURL',
        'url',
        'link',
        'pdf',
        'certificatePdf',
        'certificatePDF',
      ]),
    ]);

    return StudentCertificate(
      id: id,
      certificateId: certificateId.isNotEmpty ? certificateId : id,
      title: completionTitle.isNotEmpty ? completionTitle : title,
      studentName: studentName,
      className: className,
      classCode: classCode,
      subjectName: subjectName,
      courseName: courseName,
      authorizedBy: authorizedBy.isNotEmpty ? authorizedBy : 'SUM Academy',
      issuedAt: issuedAt,
      pdfUrl: pdfUrl.isNotEmpty ? pdfUrl : verificationUrl,
    );
  }

  String get displayTitle {
    if (title.isNotEmpty) return title;
    if (subjectName.isNotEmpty) return subjectName;
    if (courseName.isNotEmpty) return courseName;
    return 'Certificate';
  }

  String get displayProgramLine {
    final classLabel = className.isNotEmpty ? className : '';
    final codeLabel = classCode.isNotEmpty ? '($classCode)' : '';
    final subjectLabel =
        subjectName.isNotEmpty ? ' - $subjectName' : '';
    final combined = [classLabel, codeLabel].where((t) => t.isNotEmpty).join(' ');
    if (combined.isEmpty) {
      return displayTitle;
    }
    return '$combined$subjectLabel';
  }
}

List<StudentCertificate> parseCertificates(dynamic data) {
  final list = _findCertificateList(data);
  if (list == null || list.isEmpty) return const [];
  return list
      .map((item) => StudentCertificate.fromJson(item))
      .toList();
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

String _readFirstString(List<String> values) {
  for (final value in values) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) return trimmed;
  }
  return '';
}

String _readNestedString(Map<String, dynamic> map, List<String> keys) {
  for (final entry in map.entries) {
    final value = entry.value;
    if (value is Map<String, dynamic>) {
      final direct = _readString(value, keys);
      if (direct.isNotEmpty) return direct;
      final nested = _readNestedString(value, keys);
      if (nested.isNotEmpty) return nested;
    } else if (value is Map) {
      final nestedMap = Map<String, dynamic>.from(value);
      final direct = _readString(nestedMap, keys);
      if (direct.isNotEmpty) return direct;
      final nested = _readNestedString(nestedMap, keys);
      if (nested.isNotEmpty) return nested;
    }
  }
  return '';
}

DateTime? _readDate(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value == null) continue;
    if (value is DateTime) return value;
    final text = value.toString().trim();
    if (text.isEmpty) continue;
    try {
      return DateTime.parse(text);
    } catch (_) {}
  }
  return null;
}

List<Map<String, dynamic>>? _findCertificateList(dynamic data, {int depth = 0}) {
  if (depth > 6 || data == null) return null;

  if (data is List) {
    final mapped = data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    if (mapped.isNotEmpty && _looksLikeCertificateList(mapped)) {
      return mapped;
    }
    for (final item in data) {
      final found = _findCertificateList(item, depth: depth + 1);
      if (found != null && found.isNotEmpty) return found;
    }
    return null;
  }

  if (data is Map) {
    final map = Map<String, dynamic>.from(data);
    final directList = map['data'] ??
        map['items'] ??
        map['certificates'] ??
        map['results'] ??
        map['rows'] ??
        map['payload'];
    if (directList is List) {
      final found = _findCertificateList(directList, depth: depth + 1);
      if (found != null && found.isNotEmpty) return found;
    }
    for (final value in map.values) {
      final found = _findCertificateList(value, depth: depth + 1);
      if (found != null && found.isNotEmpty) return found;
    }
  }

  return null;
}

bool _looksLikeCertificateList(List<Map<String, dynamic>> list) {
  for (final item in list) {
    if (_looksLikeCertificate(item)) return true;
  }
  return false;
}

bool _looksLikeCertificate(Map<String, dynamic> map) {
  final keys = map.keys.map((k) => k.toString()).toSet();
  const certKeys = [
    'certId',
    'certificateId',
    'verificationUrl',
    'pdfUrl',
    'downloadUrl',
    'completionTitle',
    'studentName',
    'issuedAt',
    'courseName',
    'className',
    'subjectName',
  ];
  var hits = 0;
  for (final key in certKeys) {
    if (keys.contains(key)) hits++;
  }
  return hits >= 2;
}
