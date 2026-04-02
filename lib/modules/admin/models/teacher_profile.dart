import 'package:sum_academy/modules/admin/models/student_profile.dart';

class TeacherProfileData {
  final StudentProfile profile;
  final String subject;
  final String bio;

  const TeacherProfileData({
    required this.profile,
    required this.subject,
    required this.bio,
  });

  factory TeacherProfileData.fromJson(Map<String, dynamic> json) {
    final profile = StudentProfile.fromJson(json);
    final subject = _readString(json, [
      'subject',
      'specialization',
      'department',
      'expertise',
      'topic',
    ]);
    final bio = _readString(json, [
      'bio',
      'about',
      'summary',
      'description',
      'profileBio',
    ]);
    return TeacherProfileData(
      profile: profile,
      subject: subject,
      bio: bio,
    );
  }
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
