import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/admin/models/admin_class.dart';
import 'package:sum_academy/modules/admin/services/admin_class_service.dart';

class AdminClassController extends GetxController {
  final AdminClassService _service = Get.find<AdminClassService>();

  final RxList<AdminClass> classes = <AdminClass>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxBool isInitialized = false.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final RxString statusFilter = 'All Status'.obs;

  Timer? _searchDebounce;
  int _currentPage = 1;
  final int _pageSize = 20;

  static const List<String> statusOptions = [
    'All Status',
    'Active',
    'Inactive',
    'Upcoming',
    'Archived',
    'Completed',
  ];

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    fetchClasses();
  }

  Future<void> fetchClasses({bool reset = true}) async {
    if (reset) {
      _currentPage = 1;
      hasMore.value = true;
      isLoading.value = true;
      isLoadingMore.value = false;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final result = await _service.fetchClasses(
        page: _currentPage,
        limit: _pageSize,
        search: searchQuery.value,
        status: _statusQueryValue(),
      );
      if (reset) {
        classes
          ..clear()
          ..addAll(result);
      } else {
        classes.addAll(result);
      }
      if (result.length < _pageSize) {
        hasMore.value = false;
      }
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (handled) return;
      await showAppErrorDialog(
        title: 'Classes',
        message: _formatApiError(e),
      );
    } catch (_) {
      await showAppErrorDialog(
        title: 'Classes',
        message: 'Failed to load classes.',
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

  Future<void> loadMoreClasses() async {
    if (isLoadingMore.value || isLoading.value) return;
    if (!hasMore.value) return;
    _currentPage += 1;
    await fetchClasses(reset: false);
  }

  void setStatusFilter(String value) {
    statusFilter.value = value;
    fetchClasses();
  }

  List<AdminClass> get filteredClasses {
    final query = searchQuery.value.trim().toLowerCase();
    final filter = statusFilter.value;
    Iterable<AdminClass> list = classes;
    if (query.isNotEmpty) {
      list = list.where(
        (item) =>
            item.name.toLowerCase().contains(query) ||
            item.code.toLowerCase().contains(query),
      );
    }
    if (filter != 'All Status') {
      if (filter == 'Upcoming') {
        list = list.where(_isUpcoming);
      } else {
        final normalized = filter.toLowerCase();
        list = list.where(
          (item) => item.status.toLowerCase().contains(normalized),
        );
      }
    }
    return list.toList();
  }

  int get totalClasses => classes.length;

  int get activeClasses => classes.where(_isActive).length;

  int get upcomingClasses => classes.where(_isUpcoming).length;

  int get totalStudentsEnrolled =>
      classes.fold(0, (sum, item) => sum + item.enrolledCount);

  Future<ClassActionResult> createClass({
    required String name,
    String description = '',
    required int capacity,
    required String status,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? courseIds,
    List<Map<String, dynamic>>? shifts,
  }) async {
    try {
      final created = await _service.createClass(
        name: name,
        description: description,
        capacity: capacity,
        status: status,
        startDate: startDate,
        endDate: endDate,
        courseIds: courseIds,
        shifts: shifts,
      );
      classes.insert(0, created);
      return ClassActionResult.success(
        'Class created successfully.',
        classItem: created,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 0) {
        return ClassActionResult.networkFailure(e.message);
      }
      return ClassActionResult.failure(_formatApiError(e));
    } catch (_) {
      return ClassActionResult.failure('Please try again.');
    }
  }

  Future<ClassActionResult> updateClass({
    required String classId,
    required String name,
    String description = '',
    required int capacity,
    required String status,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? courseIds,
    List<Map<String, dynamic>>? shifts,
  }) async {
    try {
      final updated = await _service.updateClass(
        classId: classId,
        name: name,
        description: description,
        capacity: capacity,
        status: status,
        startDate: startDate,
        endDate: endDate,
        courseIds: courseIds,
        shifts: shifts,
      );
      final index = classes.indexWhere((item) => item.id == classId);
      if (index != -1) {
        classes[index] = updated;
      }
      return ClassActionResult.success(
        'Class updated successfully.',
        classItem: updated,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 0) {
        return ClassActionResult.networkFailure(e.message);
      }
      return ClassActionResult.failure(_formatApiError(e));
    } catch (_) {
      return ClassActionResult.failure('Please try again.');
    }
  }

  Future<ClassActionResult> deleteClass(String classId) async {
    try {
      await _service.deleteClass(classId);
      classes.removeWhere((item) => item.id == classId);
      return ClassActionResult.success('Class deleted successfully.');
    } on ApiException catch (e) {
      if (e.statusCode == 0) {
        return ClassActionResult.networkFailure(e.message);
      }
      return ClassActionResult.failure(_formatApiError(e));
    } catch (_) {
      return ClassActionResult.failure('Please try again.');
    }
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = searchController.text.trim();
      fetchClasses();
    });
  }

  String? _statusQueryValue() {
    final filter = statusFilter.value;
    if (filter == 'All Status') return null;
    return filter.toLowerCase();
  }

  bool _isActive(AdminClass item) {
    final status = item.status.toLowerCase();
    if (status.contains('active') || status.contains('ongoing')) {
      return true;
    }
    if (status.contains('inactive') || status.contains('arch')) {
      return false;
    }
    final now = DateTime.now();
    if (item.startDate != null && item.endDate != null) {
      return now.isAfter(item.startDate!) && now.isBefore(item.endDate!);
    }
    return false;
  }

  bool _isUpcoming(AdminClass item) {
    final status = item.status.toLowerCase();
    if (status.contains('upcoming')) return true;
    if (item.startDate != null) {
      return item.startDate!.isAfter(DateTime.now());
    }
    return false;
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }
}

class ClassActionResult {
  final bool isSuccess;
  final bool isNetworkError;
  final String message;
  final AdminClass? classItem;

  ClassActionResult.success(
    this.message, {
    this.classItem,
  })  : isSuccess = true,
        isNetworkError = false;

  ClassActionResult.failure(this.message)
      : isSuccess = false,
        isNetworkError = false,
        classItem = null;

  ClassActionResult.networkFailure(this.message)
      : isSuccess = false,
        isNetworkError = true,
        classItem = null;
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
