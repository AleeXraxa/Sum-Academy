import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/modules/admin/models/admin_user.dart';
import 'package:sum_academy/modules/admin/services/admin_user_service.dart';
import 'package:sum_academy/modules/auth/services/auth_service.dart';

class AdminController extends GetxController {
  final RxString userName = 'User'.obs;
  final AuthService _authService = Get.find<AuthService>();
  final AdminUserService _userService = Get.find<AdminUserService>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final RxInt navIndex = 0.obs;
  final RxBool isSearchExpanded = false.obs;
  final TextEditingController searchController = TextEditingController();
  final RxInt userFilterIndex = 0.obs;
  final RxBool isUsersLoading = false.obs;
  final RxString searchQuery = ''.obs;

  final RxList<AdminUserFilter> userFilters = <AdminUserFilter>[].obs;

  final RxList<AdminUserRow> users = <AdminUserRow>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserName();
    searchController.addListener(_onSearchChanged);
    ever<List<AdminUserRow>>(users, (_) => _refreshUserFilters());
    _refreshUserFilters();
    fetchUsers();
  }

  Future<void> _loadUserName() async {
    userName.value = await _authService.getCurrentUserName();
  }

  Future<void> fetchUsers() async {
    isUsersLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 1500));
      await _ensureAuthReady();
      final result = await _userService.fetchUsers();
      users
        ..clear()
        ..addAll(result.map(_toRow));
      _refreshUserFilters();
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        final retry = await _retryFetchUsers();
        if (retry) {
          return;
        }
      }
      Get.snackbar('Users', _formatApiError(e));
    } catch (_) {
      Get.snackbar('Users', 'Failed to load users.');
    } finally {
      isUsersLoading.value = false;
    }
  }

  Future<void> _ensureAuthReady() async {
    if (_firebaseAuth.currentUser != null) return;
    try {
      await _firebaseAuth
          .authStateChanges()
          .firstWhere((user) => user != null)
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      if (_firebaseAuth.currentUser == null) {
        throw ApiException('Authentication required.', statusCode: 401);
      }
    }
  }

  Future<bool> _retryFetchUsers() async {
    try {
      await Future.delayed(const Duration(milliseconds: 900));
      await _ensureAuthReady();
      final result = await _userService.fetchUsers();
      users
        ..clear()
        ..addAll(result.map(_toRow));
      _refreshUserFilters();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<AdminActionResult> createUser({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    try {
      final created = await _userService.createUser(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        role: role,
      );
      users.insert(0, _toRow(created));
      return const AdminActionResult.success('User created successfully.');
    } on ApiException catch (e) {
      return AdminActionResult.failure(_formatApiError(e));
    } catch (_) {
      return const AdminActionResult.failure('Please try again.');
    }
  }

  Future<AdminActionResult> updateUser({
    required String uid,
    required String fullName,
    required String email,
    required String phone,
    required String role,
    required bool isActive,
  }) async {
    try {
      final updated = await _userService.updateUser(
        uid: uid,
        fullName: fullName,
        email: email,
        phone: phone,
        role: role,
        isActive: isActive,
      );
      final resolved = updated.copyWith(
        name: fullName,
        email: email,
        phone: phone,
        role: role,
        isActive: isActive,
      );
      final index = users.indexWhere((user) => user.uid == uid);
      if (index != -1) {
        users[index] = _toRow(resolved);
      }
      return const AdminActionResult.success('User updated successfully.');
    } on ApiException catch (e) {
      return AdminActionResult.failure(_formatApiError(e));
    } catch (_) {
      return const AdminActionResult.failure('Please try again.');
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await _userService.deleteUser(uid);
      users.removeWhere((user) => user.uid == uid);
      Get.snackbar('User removed', 'User deleted successfully.');
    } on ApiException catch (e) {
      Get.snackbar('Delete failed', e.message);
    } catch (_) {
      Get.snackbar('Delete failed', 'Please try again.');
    }
  }

  Future<void> updateUserRole({
    required String uid,
    required String role,
  }) async {
    try {
      final updated = await _userService.updateUserRole(uid: uid, role: role);
      final index = users.indexWhere((user) => user.uid == uid);
      if (index != -1) {
        users[index] = _toRow(updated);
      }
      Get.snackbar('Role updated', 'User role updated.');
    } on ApiException catch (e) {
      Get.snackbar('Role update failed', e.message);
    } catch (_) {
      Get.snackbar('Role update failed', 'Please try again.');
    }
  }

  Future<void> resetUserDevice(String uid) async {
    try {
      await _userService.resetUserDevice(uid);
      Get.snackbar('Device reset', 'User device reset successfully.');
    } on ApiException catch (e) {
      Get.snackbar('Reset failed', e.message);
    } catch (_) {
      Get.snackbar('Reset failed', 'Please try again.');
    }
  }

  void setNavIndex(int index) {
    navIndex.value = index;
    if (isSearchExpanded.value) {
      closeSearch();
    }
  }

  void setUserFilterIndex(int index) {
    userFilterIndex.value = index;
  }

  void toggleSearch() {
    isSearchExpanded.value = !isSearchExpanded.value;
    if (!isSearchExpanded.value) {
      searchController.clear();
    }
  }

  void closeSearch() {
    isSearchExpanded.value = false;
    searchController.clear();
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text.trim();
  }

  void _refreshUserFilters() {
    final all = users.length;
    final students = users.where(_isStudent).length;
    final teachers = users.where(_isTeacher).length;
    final admins = users.where(_isAdmin).length;

    userFilters.assignAll([
      AdminUserFilter(label: 'All', count: all),
      AdminUserFilter(label: 'Students', count: students),
      AdminUserFilter(label: 'Teachers', count: teachers),
      AdminUserFilter(label: 'Admins', count: admins),
    ]);
  }

  List<AdminUserRow> get filteredUsers {
    final query = searchQuery.value.toLowerCase();
    final selected = userFilterIndex.value;

    Iterable<AdminUserRow> list = users;
    if (selected == 1) {
      list = list.where(_isStudent);
    } else if (selected == 2) {
      list = list.where(_isTeacher);
    } else if (selected == 3) {
      list = list.where(_isAdmin);
    }

    if (query.isNotEmpty) {
      list = list.where(
        (user) =>
            user.name.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query),
      );
    }

    return list.toList();
  }

  final stats = <AdminStat>[
    const AdminStat(
      label: 'Total Students',
      value: '1,248',
      icon: Icons.school_rounded,
      tone: SumAcademyTheme.brandBluePale,
      iconColor: SumAcademyTheme.brandBlue,
    ),
    const AdminStat(
      label: 'Total Revenue',
      value: 'PKR 2.4M',
      icon: Icons.account_balance_wallet_rounded,
      tone: SumAcademyTheme.successLight,
      iconColor: SumAcademyTheme.success,
    ),
    const AdminStat(
      label: 'Active Courses',
      value: '36',
      icon: Icons.menu_book_rounded,
      tone: SumAcademyTheme.accentOrangePale,
      iconColor: SumAcademyTheme.accentOrange,
    ),
    const AdminStat(
      label: 'Enrollments today',
      value: '74',
      icon: Icons.how_to_reg_rounded,
      tone: SumAcademyTheme.infoLight,
      iconColor: SumAcademyTheme.info,
    ),
  ];

  final quickActions = <AdminAction>[
    const AdminAction(
      title: 'Add a course',
      subtitle: 'Create a new learning track',
      icon: Icons.add_circle_outline_rounded,
    ),
    const AdminAction(
      title: 'Review payments',
      subtitle: 'Verify pending transactions',
      icon: Icons.payments_outlined,
    ),
    const AdminAction(
      title: 'Send announcement',
      subtitle: 'Notify all learners',
      icon: Icons.campaign_outlined,
    ),
  ];

  final recentActivities = <AdminActivity>[
    const AdminActivity(
      title: 'New student enrolled',
      subtitle: 'Ayesha Khan joined Biology 101',
      time: '2m ago',
      icon: Icons.how_to_reg_rounded,
      tone: SumAcademyTheme.infoLight,
      iconColor: SumAcademyTheme.info,
    ),
    const AdminActivity(
      title: 'Payment received',
      subtitle: 'PKR 12,000 for Class IX',
      time: '18m ago',
      icon: Icons.payments_rounded,
      tone: SumAcademyTheme.successLight,
      iconColor: SumAcademyTheme.success,
    ),
    const AdminActivity(
      title: 'Course updated',
      subtitle: 'Added 4 new lectures to Physics',
      time: '1h ago',
      icon: Icons.menu_book_rounded,
      tone: SumAcademyTheme.accentOrangePale,
      iconColor: SumAcademyTheme.accentOrange,
    ),
  ];
}

String _formatApiError(ApiException exception) {
  final base = exception.message;
  final errors = exception.errors;
  if (errors == null || errors.isEmpty) {
    return base;
  }

  final details = <String>[];
  errors.forEach((key, value) {
    if (value == null) return;
    if (value is List) {
      for (final item in value) {
        details.add('$key: $item');
      }
    } else {
      details.add('$key: $value');
    }
  });

  if (details.isEmpty) {
    return base;
  }

  return '$base\n${details.join('\n')}';
}

class AdminUserFilter {
  final String label;
  final int count;

  const AdminUserFilter({required this.label, required this.count});
}

class AdminUserRow {
  final String uid;
  final String initials;
  final String name;
  final String email;
  final String role;
  final String phone;
  final bool isActive;
  final Color avatarColor;

  const AdminUserRow({
    required this.uid,
    required this.initials,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.isActive,
    required this.avatarColor,
  });
}

AdminUserRow _toRow(AdminUser user) {
  final initials = _buildInitials(
    user.name.isNotEmpty ? user.name : user.email,
  );
  return AdminUserRow(
    uid: user.uid,
    initials: initials,
    name: user.name.isNotEmpty ? user.name : user.email,
    email: user.email,
    role: _formatRole(user.role),
    phone: user.phone,
    isActive: user.isActive,
    avatarColor: _roleColor(user.role),
  );
}

String _formatRole(String role) {
  if (role.isEmpty) return 'Student';
  return '${role[0].toUpperCase()}${role.substring(1).toLowerCase()}';
}

String _buildInitials(String value) {
  final parts = value.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return 'U';
  if (parts.length == 1) {
    final word = parts.first;
    return (word.length >= 2 ? word.substring(0, 2) : word).toUpperCase();
  }
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}

Color _roleColor(String role) {
  switch (role.toLowerCase()) {
    case 'admin':
      return SumAcademyTheme.adminPurple;
    case 'teacher':
      return SumAcademyTheme.teacherBlue;
    case 'student':
      return SumAcademyTheme.studentGreen;
    default:
      return SumAcademyTheme.brandBlue;
  }
}

class AdminStat {
  final String label;
  final String value;
  final IconData icon;
  final Color? tone;
  final Color? iconColor;

  const AdminStat({
    required this.label,
    required this.value,
    required this.icon,
    this.tone,
    this.iconColor,
  });
}

class AdminAction {
  final String title;
  final String subtitle;
  final IconData icon;

  const AdminAction({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class AdminActivity {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color tone;
  final Color iconColor;

  const AdminActivity({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.tone,
    required this.iconColor,
  });
}

class AdminActionResult {
  final bool isSuccess;
  final String message;

  const AdminActionResult._(this.isSuccess, this.message);

  const AdminActionResult.success(this.message) : isSuccess = true;

  const AdminActionResult.failure(this.message) : isSuccess = false;
}

bool _isStudent(AdminUserRow user) => user.role.toLowerCase() == 'student';
bool _isTeacher(AdminUserRow user) => user.role.toLowerCase() == 'teacher';
bool _isAdmin(AdminUserRow user) => user.role.toLowerCase() == 'admin';
