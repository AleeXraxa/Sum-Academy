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
  if (data is List) {
    return data
        .whereType<Map>()
        .map((item) => StudentCertificate.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
  if (data is Map<String, dynamic>) {
    final list = data['data'] ?? data['items'] ?? data['certificates'];
    if (list is List) {
      return parseCertificates(list);
    }
  }
  return const [];
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
