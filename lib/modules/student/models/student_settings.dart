class StudentSettings {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String fatherName;
  final String fatherPhone;
  final String fatherOccupation;
  final String district;
  final String domicile;
  final String caste;
  final String address;

  const StudentSettings({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.fatherName,
    required this.fatherPhone,
    required this.fatherOccupation,
    required this.district,
    required this.domicile,
    required this.caste,
    required this.address,
  });

  bool get isComplete =>
      fullName.trim().isNotEmpty &&
      email.trim().isNotEmpty &&
      phoneNumber.trim().isNotEmpty &&
      fatherName.trim().isNotEmpty &&
      fatherPhone.trim().isNotEmpty &&
      district.trim().isNotEmpty &&
      domicile.trim().isNotEmpty &&
      caste.trim().isNotEmpty &&
      address.trim().isNotEmpty;

  factory StudentSettings.fromJson(Map<String, dynamic> json) {
    return StudentSettings(
      fullName: _readString(json, const ['fullName', 'name', 'studentName']),
      email: _readString(json, const ['email', 'emailAddress']),
      phoneNumber:
          _readString(json, const ['phoneNumber', 'phone', 'mobile']),
      fatherName:
          _readString(json, const ['fatherName', 'guardianName']),
      fatherPhone:
          _readString(json, const ['fatherPhone', 'guardianPhone']),
      fatherOccupation:
          _readString(json, const ['fatherOccupation', 'guardianOccupation']),
      district: _readString(json, const ['district']),
      domicile: _readString(json, const ['domicile']),
      caste: _readString(json, const ['caste']),
      address: _readString(json, const ['address', 'location', 'city']),
    );
  }

  Map<String, dynamic> toUpdatePayload() {
    return {
      'fullName': fullName.trim(),
      'email': email.trim(),
      'phoneNumber': phoneNumber.trim(),
      'fatherName': fatherName.trim(),
      'fatherPhone': fatherPhone.trim(),
      'fatherOccupation': fatherOccupation.trim(),
      'district': district.trim(),
      'domicile': domicile.trim(),
      'caste': caste.trim(),
      'address': address.trim(),
    };
  }
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return '';
}
