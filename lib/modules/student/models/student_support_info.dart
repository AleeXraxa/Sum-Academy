class StudentSupportInfo {
  final String email;
  final String whatsapp;
  final String phone;
  final String officeHours;

  const StudentSupportInfo({
    required this.email,
    required this.whatsapp,
    required this.phone,
    required this.officeHours,
  });

  factory StudentSupportInfo.empty() => const StudentSupportInfo(
        email: 'support@sumacademy.com',
        whatsapp: '+92 300 0000000',
        phone: '+92 300 0000000',
        officeHours: 'Monday to Saturday 9AM to 6PM PKT',
      );

  factory StudentSupportInfo.fromAny(dynamic data) {
    if (data is Map<String, dynamic>) {
      final email = _readString(data, const [
        'supportEmail',
        'contactEmail',
        'contact_email',
        'email',
        'contactEmail',
        'support_email',
      ]);
      final whatsapp = _readString(data, const [
        'whatsapp',
        'whatsApp',
        'whatsappNumber',
        'whatsappNo',
        'contactWhatsapp',
        'contact_whatsapp',
        'whatsappNumber',
        'supportWhatsapp',
        'support_whatsapp',
      ]);
      final phone = _readString(data, const [
        'phone',
        'phoneNumber',
        'contactPhone',
        'contactNumber',
        'supportNumber',
        'supportPhone',
        'support_phone',
      ]);
      final officeHours = _readString(data, const [
        'officeHours',
        'workingHours',
        'supportHours',
        'hours',
        'office_hours',
        'office_hours',
      ]);

      return StudentSupportInfo(
        email: email.isEmpty ? StudentSupportInfo.empty().email : email,
        whatsapp: whatsapp.isEmpty ? StudentSupportInfo.empty().whatsapp : whatsapp,
        phone: phone.isEmpty ? StudentSupportInfo.empty().phone : phone,
        officeHours: officeHours.isEmpty
            ? StudentSupportInfo.empty().officeHours
            : officeHours,
      );
    }

    return StudentSupportInfo.empty();
  }
}

String _readString(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = _searchKey(map, key);
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return '';
}

dynamic _searchKey(Map<String, dynamic> map, String key) {
  if (map.containsKey(key)) {
    return map[key];
  }
  for (final entry in map.entries) {
    final value = entry.value;
    if (value is Map<String, dynamic>) {
      final nested = _searchKey(value, key);
      if (nested != null) return nested;
    }
  }
  return null;
}
