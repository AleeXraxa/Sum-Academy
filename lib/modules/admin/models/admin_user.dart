class AdminUser {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String phone;
  final bool isActive;

  const AdminUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.isActive,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    final uid = (json['uid'] ??
            json['_id'] ??
            json['id'] ??
            json['userId'] ??
            '')
        .toString();
    final name = (json['fullName'] ?? json['name'] ?? '').toString();
    final email = (json['email'] ?? '').toString();
    final role = (json['role'] ?? 'student').toString();
    final phone =
        (json['phone'] ?? json['phoneNumber'] ?? json['mobile'] ?? '')
            .toString();
    final isActive = _readBool(json['isActive'] ?? json['active'] ?? true);

    return AdminUser(
      uid: uid,
      name: name,
      email: email,
      role: role,
      phone: phone,
      isActive: isActive,
    );
  }

  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'yes';
    }
    return false;
  }

  AdminUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? phone,
    bool? isActive,
  }) {
    return AdminUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
    );
  }
}
