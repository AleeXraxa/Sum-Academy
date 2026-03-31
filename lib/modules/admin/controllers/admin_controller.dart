import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';
import 'package:sum_academy/modules/admin/models/admin_activity_payload.dart';
import 'package:sum_academy/modules/admin/models/admin_stats.dart';
import 'package:sum_academy/modules/admin/models/admin_user.dart';
import 'package:sum_academy/modules/admin/services/admin_activity_service.dart';
import 'package:sum_academy/modules/admin/services/admin_stats_service.dart';
import 'package:sum_academy/modules/admin/services/admin_user_service.dart';
import 'package:sum_academy/modules/auth/services/auth_service.dart';

class AdminController extends GetxController {
  final RxString userName = 'User'.obs;
  final AuthService _authService = Get.find<AuthService>();
  final AdminUserService _userService = Get.find<AdminUserService>();
  final AdminActivityService _activityService =
      Get.find<AdminActivityService>();
  final AdminStatsService _statsService = Get.find<AdminStatsService>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final RxInt navIndex = 0.obs;
  final RxBool isSearchExpanded = false.obs;
  final TextEditingController searchController = TextEditingController();
  final RxInt userFilterIndex = 0.obs;
  final RxBool isUsersLoading = false.obs;
  final RxBool isUsersLoadingMore = false.obs;
  final RxString searchQuery = ''.obs;
  Timer? _searchDebounce;
  final RxBool hasMoreUsers = true.obs;
  int _currentPage = 1;
  final int _pageSize = 20;
  final RxString currentUserUid = ''.obs;
  bool _initialUsersDelayShown = false;
  int _usersRequestId = 0;
  final RxBool isStatsLoading = false.obs;
  final RxBool isActivitiesLoading = false.obs;

  final RxList<AdminUserFilter> userFilters = <AdminUserFilter>[].obs;

  final RxList<AdminUserRow> users = <AdminUserRow>[].obs;

  final RxList<AdminStat> stats = <AdminStat>[].obs;
  final RxList<AdminActivity> recentActivities = <AdminActivity>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserName();
    _seedStats();
    searchController.addListener(_onSearchChanged);
    ever<List<AdminUserRow>>(users, (_) => _refreshUserFilters());
    _refreshUserFilters();
    fetchUsers();
    fetchDashboardStats();
    fetchRecentActivities();
  }

  Future<void> _loadUserName() async {
    userName.value = await _authService.getCurrentUserName();
    currentUserUid.value = _firebaseAuth.currentUser?.uid ?? '';
  }

  void _seedStats() {
    stats.assignAll(
      _buildStatsList(
        totalStudents: '-',
        totalRevenue: 'PKR -',
        activeCourses: '-',
        enrollmentsToday: '-',
      ),
    );
  }

  Future<void> fetchDashboardStats() async {
    isStatsLoading.value = true;
    try {
      await _ensureAuthReady();
      final payload = await _statsService.fetchStats();
      stats.assignAll(
        _buildStatsList(
          totalStudents: payload.totalStudents.toString(),
          totalRevenue: _formatCurrency(payload.totalRevenue),
          activeCourses: payload.activeCourses.toString(),
          enrollmentsToday: payload.enrollmentsToday.toString(),
        ),
      );
    } on ApiException catch (e) {
      if (e.statusCode == 0) {
        final context = Get.context;
        if (context != null) {
          await showNoInternetDialog(context);
        } else {
          Get.snackbar('No internet', e.message);
        }
        return;
      }
      Get.snackbar('Stats', _formatApiError(e));
    } catch (_) {
      Get.snackbar('Stats', 'Failed to load stats.');
    } finally {
      isStatsLoading.value = false;
    }
  }

  Future<void> fetchRecentActivities() async {
    isActivitiesLoading.value = true;
    try {
      await _ensureAuthReady();
      final payloads = await _activityService.fetchRecentActivity();
      recentActivities.assignAll(payloads.map(_mapActivity));
    } on ApiException catch (e) {
      if (e.statusCode == 0) {
        final context = Get.context;
        if (context != null) {
          await showNoInternetDialog(context);
        } else {
          Get.snackbar('No internet', e.message);
        }
        return;
      }
      Get.snackbar('Recent activity', _formatApiError(e));
    } catch (_) {
      Get.snackbar('Recent activity', 'Failed to load activity.');
    } finally {
      isActivitiesLoading.value = false;
    }
  }

  Future<void> refreshDashboard() async {
    await fetchDashboardStats();
    await fetchRecentActivities();
  }

  Future<void> fetchUsers({bool reset = true}) async {
    final requestId = ++_usersRequestId;
    if (reset) {
      _currentPage = 1;
      hasMoreUsers.value = true;
      isUsersLoading.value = true;
      isUsersLoadingMore.value = false;
    } else {
      isUsersLoadingMore.value = true;
    }
    try {
      if (reset && !_initialUsersDelayShown) {
        await Future.delayed(const Duration(milliseconds: 1500));
        _initialUsersDelayShown = true;
      }
      await _ensureAuthReady();
      final result = await _userService.fetchUsers(
        page: _currentPage,
        limit: _pageSize,
        search: searchQuery.value,
        role: _selectedRoleFilter(),
      );
      if (requestId != _usersRequestId) {
        return;
      }
      final rows = result.map(_toRow).toList();
      if (reset) {
        users
          ..clear()
          ..addAll(rows);
      } else {
        users.addAll(rows);
      }
      if (rows.length < _pageSize) {
        hasMoreUsers.value = false;
      }
      _refreshUserFilters();
    } on ApiException catch (e) {
      if (requestId != _usersRequestId) {
        return;
      }
      if (e.statusCode == 0) {
        final context = Get.context;
        if (context != null) {
          await showNoInternetDialog(context);
        } else {
          Get.snackbar('No internet', e.message);
        }
        return;
      }
      if (e.statusCode == 401) {
        final retry = await _retryFetchUsers(
          requestId: requestId,
          reset: reset,
        );
        if (retry) {
          return;
        }
      }
      Get.snackbar('Users', _formatApiError(e));
    } catch (_) {
      if (requestId != _usersRequestId) {
        return;
      }
      Get.snackbar('Users', 'Failed to load users.');
    } finally {
      if (requestId != _usersRequestId) {
        return;
      }
      if (reset) {
        isUsersLoading.value = false;
      } else {
        isUsersLoadingMore.value = false;
      }
    }
  }

  Future<void> loadMoreUsers() async {
    if (isUsersLoadingMore.value || isUsersLoading.value) return;
    if (!hasMoreUsers.value) return;
    _currentPage += 1;
    await fetchUsers(reset: false);
  }

  Future<void> _ensureAuthReady() async {
    if (_firebaseAuth.currentUser != null) {
      currentUserUid.value = _firebaseAuth.currentUser?.uid ?? '';
      return;
    }
    try {
      await _firebaseAuth
          .authStateChanges()
          .firstWhere((user) => user != null)
          .timeout(const Duration(seconds: 5));
      currentUserUid.value = _firebaseAuth.currentUser?.uid ?? '';
    } catch (_) {
      if (_firebaseAuth.currentUser == null) {
        throw ApiException('Authentication required.', statusCode: 401);
      }
    }
  }

  Future<bool> _retryFetchUsers({
    required int requestId,
    required bool reset,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 900));
      await _ensureAuthReady();
      final result = await _userService.fetchUsers(
        page: _currentPage,
        limit: _pageSize,
        search: searchQuery.value,
        role: _selectedRoleFilter(),
      );
      if (requestId != _usersRequestId) {
        return false;
      }
      final rows = result.map(_toRow).toList();
      if (reset) {
        users
          ..clear()
          ..addAll(rows);
      } else {
        users.addAll(rows);
      }
      if (rows.length < _pageSize) {
        hasMoreUsers.value = false;
      }
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
    if (isCurrentUser(uid)) {
      AdminUserRow? existing;
      for (final user in users) {
        if (user.uid == uid) {
          existing = user;
          break;
        }
      }
      if (existing != null &&
          (existing.role.toLowerCase() != role.toLowerCase() ||
              existing.isActive != isActive)) {
        return const AdminActionResult.failure(
          'You cannot change your own role or status.',
        );
      }
    }
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

  Future<AdminActionResult> deleteUser(String uid) async {
    try {
      await _userService.deleteUser(uid);
      users.removeWhere((user) => user.uid == uid);
      return const AdminActionResult.success('User deleted successfully.');
    } on ApiException catch (e) {
      return AdminActionResult.failure(_formatApiError(e));
    } catch (_) {
      return const AdminActionResult.failure('Please try again.');
    }
  }

  Future<AdminActionResult> updateUserRole({
    required String uid,
    required String role,
  }) async {
    if (isCurrentUser(uid)) {
      return const AdminActionResult.failure(
        'You cannot change your own role.',
      );
    }
    try {
      final updated = await _userService.updateUserRole(uid: uid, role: role);
      final index = users.indexWhere((user) => user.uid == uid);
      if (index != -1) {
        users[index] = _toRow(updated);
      }
      return const AdminActionResult.success('Role updated successfully.');
    } on ApiException catch (e) {
      return AdminActionResult.failure(_formatApiError(e));
    } catch (_) {
      return const AdminActionResult.failure('Please try again.');
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
    fetchUsers();
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
    _searchDebounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = searchController.text.trim();
      fetchUsers();
    });
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
    return users.toList();
  }

  String? _selectedRoleFilter() {
    switch (userFilterIndex.value) {
      case 1:
        return 'student';
      case 2:
        return 'teacher';
      case 3:
        return 'admin';
      default:
        return null;
    }
  }

  bool isCurrentUser(String uid) {
    final current = currentUserUid.value;
    return current.isNotEmpty && uid == current;
  }

  List<AdminStat> _buildStatsList({
    required String totalStudents,
    required String totalRevenue,
    required String activeCourses,
    required String enrollmentsToday,
  }) {
    return [
      AdminStat(
        label: 'Total Students',
        value: totalStudents,
        icon: Icons.school_rounded,
        tone: SumAcademyTheme.brandBluePale,
        iconColor: SumAcademyTheme.brandBlue,
      ),
      AdminStat(
        label: 'Total Revenue',
        value: totalRevenue,
        icon: Icons.account_balance_wallet_rounded,
        tone: SumAcademyTheme.successLight,
        iconColor: SumAcademyTheme.success,
      ),
      AdminStat(
        label: 'Active Courses',
        value: activeCourses,
        icon: Icons.menu_book_rounded,
        tone: SumAcademyTheme.accentOrangePale,
        iconColor: SumAcademyTheme.accentOrange,
      ),
      AdminStat(
        label: 'Enrollments today',
        value: enrollmentsToday,
        icon: Icons.how_to_reg_rounded,
        tone: SumAcademyTheme.infoLight,
        iconColor: SumAcademyTheme.info,
      ),
    ];
  }

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

  AdminActivity _mapActivity(AdminActivityPayload payload) {
    final mapping = _activityStyle(
      '${payload.type} ${payload.title} ${payload.subtitle}',
    );
    final timeLabel =
        payload.timeLabel ?? _formatRelativeTime(payload.createdAt);
    final subtitle = payload.subtitle.isNotEmpty
        ? payload.subtitle
        : (payload.type.isNotEmpty ? payload.type : 'Activity update');
    return AdminActivity(
      title: payload.title,
      subtitle: subtitle,
      time: timeLabel,
      icon: mapping.icon,
      tone: mapping.tone,
      iconColor: mapping.iconColor,
    );
  }

  _ActivityStyle _activityStyle(String source) {
    final normalized = source.toLowerCase();
    if (normalized.contains('payment') ||
        normalized.contains('transaction') ||
        normalized.contains('fee') ||
        normalized.contains('revenue')) {
      return const _ActivityStyle(
        icon: Icons.payments_rounded,
        tone: SumAcademyTheme.successLight,
        iconColor: SumAcademyTheme.success,
      );
    }
    if (normalized.contains('enroll') ||
        normalized.contains('student') ||
        normalized.contains('admission')) {
      return const _ActivityStyle(
        icon: Icons.how_to_reg_rounded,
        tone: SumAcademyTheme.infoLight,
        iconColor: SumAcademyTheme.info,
      );
    }
    if (normalized.contains('course') ||
        normalized.contains('lecture') ||
        normalized.contains('class') ||
        normalized.contains('chapter')) {
      return const _ActivityStyle(
        icon: Icons.menu_book_rounded,
        tone: SumAcademyTheme.accentOrangePale,
        iconColor: SumAcademyTheme.accentOrange,
      );
    }
    if (normalized.contains('announcement') ||
        normalized.contains('notice') ||
        normalized.contains('alert')) {
      return const _ActivityStyle(
        icon: Icons.campaign_rounded,
        tone: SumAcademyTheme.brandBluePale,
        iconColor: SumAcademyTheme.brandBlue,
      );
    }
    return const _ActivityStyle(
      icon: Icons.bolt_rounded,
      tone: SumAcademyTheme.surfaceTertiary,
      iconColor: SumAcademyTheme.darkBase,
    );
  }
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

class _ActivityStyle {
  final IconData icon;
  final Color tone;
  final Color iconColor;

  const _ActivityStyle({
    required this.icon,
    required this.tone,
    required this.iconColor,
  });
}

bool _isStudent(AdminUserRow user) => user.role.toLowerCase() == 'student';
bool _isTeacher(AdminUserRow user) => user.role.toLowerCase() == 'teacher';
bool _isAdmin(AdminUserRow user) => user.role.toLowerCase() == 'admin';

String _formatCurrency(num value) {
  final formatted = _formatCompactNumber(value);
  return 'PKR $formatted';
}

String _formatCompactNumber(num value) {
  final absValue = value.abs();
  if (absValue >= 1000000000) {
    return '${(value / 1000000000).toStringAsFixed(1)}B';
  }
  if (absValue >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (absValue >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}K';
  }
  return value.toStringAsFixed(0);
}

String _formatRelativeTime(DateTime? date) {
  if (date == null) return 'Just now';
  final now = DateTime.now();
  var diff = now.difference(date);
  if (diff.isNegative) {
    diff = Duration.zero;
  }
  if (diff.inSeconds < 60) {
    return '${diff.inSeconds}s ago';
  }
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes}m ago';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours}h ago';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays}d ago';
  }
  if (diff.inDays < 30) {
    return '${(diff.inDays / 7).floor()}w ago';
  }
  return _formatDate(date);
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final month = months[date.month - 1];
  return '$month ${date.day}, ${date.year}';
}
