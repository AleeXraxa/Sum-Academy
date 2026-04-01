import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/admin/models/admin_user.dart';
import 'package:sum_academy/modules/admin/services/admin_teacher_service.dart';
import 'package:sum_academy/modules/auth/services/auth_service.dart';

class AdminTeacherController extends GetxController {
  final AdminTeacherService _service = Get.find<AdminTeacherService>();
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final RxList<AdminTeacherRow> teachers = <AdminTeacherRow>[].obs;
  final RxList<AdminTeacherFilter> filters = <AdminTeacherFilter>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxBool isInitialized = false.obs;
  final RxInt filterIndex = 0.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final RxString currentUserUid = ''.obs;

  Timer? _searchDebounce;
  int _currentPage = 1;
  final int _pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
    searchController.addListener(_onSearchChanged);
    ever<List<AdminTeacherRow>>(teachers, (_) => _refreshFilters());
    _refreshFilters();
    fetchTeachers();
  }

  Future<void> _loadCurrentUser() async {
    currentUserUid.value = _firebaseAuth.currentUser?.uid ?? '';
    await _authService.getCurrentUserName();
  }

  Future<void> fetchTeachers({bool reset = true}) async {
    if (reset) {
      _currentPage = 1;
      hasMore.value = true;
      isLoading.value = true;
      isLoadingMore.value = false;
    } else {
      isLoadingMore.value = true;
    }

    try {
      await _ensureAuthReady();
      final result = await _service.fetchTeachers(
        page: _currentPage,
        limit: _pageSize,
        search: searchQuery.value,
      );
      final rows = result.map(_toRow).toList();
      if (reset) {
        teachers
          ..clear()
          ..addAll(rows);
      } else {
        teachers.addAll(rows);
      }
      if (rows.length < _pageSize) {
        hasMore.value = false;
      }
      _refreshFilters();
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (handled) return;
      await showAppErrorDialog(
        title: 'Teachers',
        message: _formatApiError(e),
      );
    } catch (_) {
      await showAppErrorDialog(
        title: 'Teachers',
        message: 'Failed to load teachers.',
      );
    } finally {
      if (reset) {
        isLoading.value = false;
        if (!isInitialized.value) {
          isInitialized.value = true;
        }
      } else {
        isLoadingMore.value = false;
      }
    }
  }

  Future<void> loadMoreTeachers() async {
    if (isLoadingMore.value || isLoading.value) return;
    if (!hasMore.value) return;
    _currentPage += 1;
    await fetchTeachers(reset: false);
  }

  Future<TeacherActionResult> createTeacher({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    String subject = '',
    String bio = '',
  }) async {
    try {
      final created = await _service.createTeacher(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        subject: subject,
        bio: bio,
      );
      teachers.insert(0, _toRow(created));
      return const TeacherActionResult.success('Teacher created successfully.');
    } on ApiException catch (e) {
      if (e.statusCode == 0) {
        return TeacherActionResult.networkFailure(e.message);
      }
      return TeacherActionResult.failure(_formatApiError(e));
    } catch (_) {
      return const TeacherActionResult.failure('Please try again.');
    }
  }

  Future<TeacherActionResult> updateTeacher({
    required String uid,
    required String fullName,
    required String email,
    required String phone,
    required bool isActive,
    String subject = '',
    String bio = '',
  }) async {
    if (isCurrentUser(uid)) {
      AdminTeacherRow? existing;
      for (final teacher in teachers) {
        if (teacher.uid == uid) {
          existing = teacher;
          break;
        }
      }
      if (existing != null && existing.isActive != isActive) {
        return const TeacherActionResult.failure(
          'You cannot change your own status.',
        );
      }
    }

    try {
      final updated = await _service.updateTeacher(
        uid: uid,
        fullName: fullName,
        email: email,
        phone: phone,
        isActive: isActive,
        subject: subject,
        bio: bio,
      );
      final resolved = updated.copyWith(
        name: fullName,
        email: email,
        phone: phone,
        role: 'teacher',
        isActive: isActive,
        subject: subject,
        bio: bio,
      );
      final index = teachers.indexWhere((t) => t.uid == uid);
      if (index != -1) {
        teachers[index] = _toRow(resolved);
      }
      return const TeacherActionResult.success('Teacher updated successfully.');
    } on ApiException catch (e) {
      if (e.statusCode == 0) {
        return TeacherActionResult.networkFailure(e.message);
      }
      return TeacherActionResult.failure(_formatApiError(e));
    } catch (_) {
      return const TeacherActionResult.failure('Please try again.');
    }
  }

  Future<TeacherActionResult> deleteTeacher(String uid) async {
    try {
      await _service.deleteTeacher(uid);
      teachers.removeWhere((t) => t.uid == uid);
      return const TeacherActionResult.success('Teacher deleted successfully.');
    } on ApiException catch (e) {
      if (e.statusCode == 0) {
        return TeacherActionResult.networkFailure(e.message);
      }
      return TeacherActionResult.failure(_formatApiError(e));
    } catch (_) {
      return const TeacherActionResult.failure('Please try again.');
    }
  }

  void setFilterIndex(int index) {
    filterIndex.value = index;
  }

  List<AdminTeacherRow> get filteredTeachers {
    final index = filterIndex.value;
    final query = searchQuery.value.trim().toLowerCase();
    Iterable<AdminTeacherRow> list = teachers;
    if (query.isNotEmpty) {
      list = list.where(
        (teacher) =>
            teacher.name.toLowerCase().contains(query) ||
            teacher.email.toLowerCase().contains(query) ||
            teacher.subject.toLowerCase().contains(query),
      );
    }
    if (index == 1) {
      list = list.where((t) => t.isActive);
    } else if (index == 2) {
      list = list.where((t) => !t.isActive);
    }
    return list.toList();
  }

  bool isCurrentUser(String uid) {
    final current = currentUserUid.value;
    return current.isNotEmpty && uid == current;
  }

  void _refreshFilters() {
    final all = teachers.length;
    final active = teachers.where((t) => t.isActive).length;
    final inactive = teachers.where((t) => !t.isActive).length;

    filters.assignAll([
      AdminTeacherFilter(label: 'All', count: all),
      AdminTeacherFilter(label: 'Active', count: active),
      AdminTeacherFilter(label: 'Inactive', count: inactive),
    ]);
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = searchController.text.trim();
      fetchTeachers();
    });
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

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }
}

AdminTeacherRow _toRow(AdminUser teacher) {
  final initials = _buildInitials(
    teacher.name.isNotEmpty ? teacher.name : teacher.email,
  );
  return AdminTeacherRow(
    uid: teacher.uid,
    initials: initials,
    name: teacher.name.isNotEmpty ? teacher.name : teacher.email,
    email: teacher.email,
    role: _formatRole(teacher.role),
    phone: teacher.phone,
    isActive: teacher.isActive,
    avatarColor: SumAcademyTheme.teacherBlue,
    subject: teacher.subject,
    bio: teacher.bio,
  );
}

String _formatRole(String role) {
  if (role.isEmpty) return 'Teacher';
  return '${role[0].toUpperCase()}${role.substring(1).toLowerCase()}';
}

String _buildInitials(String value) {
  final parts = value.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return 'T';
  if (parts.length == 1) {
    final word = parts.first;
    return (word.length >= 2 ? word.substring(0, 2) : word).toUpperCase();
  }
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}

class AdminTeacherFilter {
  final String label;
  final int count;

  const AdminTeacherFilter({required this.label, required this.count});
}

class AdminTeacherRow {
  final String uid;
  final String initials;
  final String name;
  final String email;
  final String role;
  final String phone;
  final bool isActive;
  final Color avatarColor;
  final String subject;
  final String bio;

  const AdminTeacherRow({
    required this.uid,
    required this.initials,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.isActive,
    required this.avatarColor,
    required this.subject,
    required this.bio,
  });
}

class TeacherActionResult {
  final bool isSuccess;
  final bool isNetworkError;
  final String message;

  const TeacherActionResult._(
    this.isSuccess,
    this.message, {
    this.isNetworkError = false,
  });

  const TeacherActionResult.success(this.message)
      : isSuccess = true,
        isNetworkError = false;

  const TeacherActionResult.failure(this.message)
      : isSuccess = false,
        isNetworkError = false;

  const TeacherActionResult.networkFailure(this.message)
      : isSuccess = false,
        isNetworkError = true;
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
