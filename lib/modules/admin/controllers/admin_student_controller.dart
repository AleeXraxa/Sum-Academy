import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';
import 'package:sum_academy/modules/admin/models/admin_user.dart';
import 'package:sum_academy/modules/admin/services/admin_student_service.dart';
import 'package:sum_academy/modules/auth/services/auth_service.dart';

class AdminStudentController extends GetxController {
  final AdminStudentService _service = Get.find<AdminStudentService>();
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final RxList<AdminStudentRow> students = <AdminStudentRow>[].obs;
  final RxList<AdminStudentFilter> filters = <AdminStudentFilter>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxInt filterIndex = 0.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final RxString currentUserUid = ''.obs;

  Timer? _searchDebounce;
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _initialStudentsDelayShown = false;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
    searchController.addListener(_onSearchChanged);
    ever<List<AdminStudentRow>>(students, (_) => _refreshFilters());
    _refreshFilters();
    fetchStudents();
  }

  Future<void> _loadCurrentUser() async {
    currentUserUid.value = _firebaseAuth.currentUser?.uid ?? '';
    await _authService.getCurrentUserName();
  }

  Future<void> fetchStudents({bool reset = true}) async {
    if (reset) {
      _currentPage = 1;
      hasMore.value = true;
      isLoading.value = true;
      isLoadingMore.value = false;
    } else {
      isLoadingMore.value = true;
    }

    try {
      if (reset && !_initialStudentsDelayShown) {
        await Future.delayed(const Duration(milliseconds: 1500));
        _initialStudentsDelayShown = true;
      }
      await _ensureAuthReady();
      final result = await _service.fetchStudents(
        page: _currentPage,
        limit: _pageSize,
        search: searchQuery.value,
      );
      final rows = result.map(_toRow).toList();
      if (reset) {
        students
          ..clear()
          ..addAll(rows);
      } else {
        students.addAll(rows);
      }
      if (rows.length < _pageSize) {
        hasMore.value = false;
      }
      _refreshFilters();
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
      Get.snackbar('Students', _formatApiError(e));
    } catch (_) {
      Get.snackbar('Students', 'Failed to load students.');
    } finally {
      if (reset) {
        isLoading.value = false;
      } else {
        isLoadingMore.value = false;
      }
    }
  }

  Future<void> loadMoreStudents() async {
    if (isLoadingMore.value || isLoading.value) return;
    if (!hasMore.value) return;
    _currentPage += 1;
    await fetchStudents(reset: false);
  }

  Future<StudentActionResult> createStudent({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final created = await _service.createStudent(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
      );
      students.insert(0, _toRow(created));
      return const StudentActionResult.success('Student created successfully.');
    } on ApiException catch (e) {
      if (e.statusCode == 0) {
        return StudentActionResult.networkFailure(e.message);
      }
      return StudentActionResult.failure(_formatApiError(e));
    } catch (_) {
      return const StudentActionResult.failure('Please try again.');
    }
  }

  Future<StudentActionResult> updateStudent({
    required String uid,
    required String fullName,
    required String email,
    required String phone,
    required bool isActive,
  }) async {
    if (isCurrentUser(uid)) {
      AdminStudentRow? existing;
      for (final student in students) {
        if (student.uid == uid) {
          existing = student;
          break;
        }
      }
      if (existing != null && existing.isActive != isActive) {
        return const StudentActionResult.failure(
          'You cannot change your own status.',
        );
      }
    }

    try {
      final updated = await _service.updateStudent(
        uid: uid,
        fullName: fullName,
        email: email,
        phone: phone,
        isActive: isActive,
      );
      final resolved = updated.copyWith(
        name: fullName,
        email: email,
        phone: phone,
        role: 'student',
        isActive: isActive,
      );
      final index = students.indexWhere((t) => t.uid == uid);
      if (index != -1) {
        students[index] = _toRow(resolved);
      }
      return const StudentActionResult.success('Student updated successfully.');
    } on ApiException catch (e) {
      if (e.statusCode == 0) {
        return StudentActionResult.networkFailure(e.message);
      }
      return StudentActionResult.failure(_formatApiError(e));
    } catch (_) {
      return const StudentActionResult.failure('Please try again.');
    }
  }

  Future<StudentActionResult> deleteStudent(String uid) async {
    try {
      await _service.deleteStudent(uid);
      students.removeWhere((t) => t.uid == uid);
      return const StudentActionResult.success('Student deleted successfully.');
    } on ApiException catch (e) {
      if (e.statusCode == 0) {
        return StudentActionResult.networkFailure(e.message);
      }
      return StudentActionResult.failure(_formatApiError(e));
    } catch (_) {
      return const StudentActionResult.failure('Please try again.');
    }
  }

  void setFilterIndex(int index) {
    filterIndex.value = index;
  }

  List<AdminStudentRow> get filteredStudents {
    final index = filterIndex.value;
    final query = searchQuery.value.trim().toLowerCase();
    Iterable<AdminStudentRow> list = students;
    if (query.isNotEmpty) {
      list = list.where(
        (student) =>
            student.name.toLowerCase().contains(query) ||
            student.email.toLowerCase().contains(query) ||
            student.phone.toLowerCase().contains(query),
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
    final all = students.length;
    final active = students.where((t) => t.isActive).length;
    final inactive = students.where((t) => !t.isActive).length;

    filters.assignAll([
      AdminStudentFilter(label: 'All', count: all),
      AdminStudentFilter(label: 'Active', count: active),
      AdminStudentFilter(label: 'Inactive', count: inactive),
    ]);
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = searchController.text.trim();
      fetchStudents();
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

AdminStudentRow _toRow(AdminUser student) {
  final initials = _buildInitials(
    student.name.isNotEmpty ? student.name : student.email,
  );
  return AdminStudentRow(
    uid: student.uid,
    initials: initials,
    name: student.name.isNotEmpty ? student.name : student.email,
    email: student.email,
    phone: student.phone,
    isActive: student.isActive,
    avatarColor: SumAcademyTheme.studentGreen,
  );
}

String _buildInitials(String value) {
  final parts = value.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return 'S';
  if (parts.length == 1) {
    final word = parts.first;
    return (word.length >= 2 ? word.substring(0, 2) : word).toUpperCase();
  }
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}

class AdminStudentFilter {
  final String label;
  final int count;

  const AdminStudentFilter({required this.label, required this.count});
}

class AdminStudentRow {
  final String uid;
  final String initials;
  final String name;
  final String email;
  final String phone;
  final bool isActive;
  final Color avatarColor;

  const AdminStudentRow({
    required this.uid,
    required this.initials,
    required this.name,
    required this.email,
    required this.phone,
    required this.isActive,
    required this.avatarColor,
  });
}

class StudentActionResult {
  final bool isSuccess;
  final bool isNetworkError;
  final String message;

  const StudentActionResult._(
    this.isSuccess,
    this.message, {
    this.isNetworkError = false,
  });

  const StudentActionResult.success(this.message)
      : isSuccess = true,
        isNetworkError = false;

  const StudentActionResult.failure(this.message)
      : isSuccess = false,
        isNetworkError = false;

  const StudentActionResult.networkFailure(this.message)
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
