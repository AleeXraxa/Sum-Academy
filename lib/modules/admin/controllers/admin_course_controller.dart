import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';
import 'package:sum_academy/modules/admin/models/admin_course.dart';
import 'package:sum_academy/modules/admin/services/admin_course_service.dart';

class AdminCourseController extends GetxController {
  final AdminCourseService _service = Get.find<AdminCourseService>();

  final RxList<AdminCourse> courses = <AdminCourse>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  Timer? _searchDebounce;

  int _currentPage = 1;
  final int _pageSize = 20;
  bool _initialDelayShown = false;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    fetchCourses();
  }

  Future<void> fetchCourses({bool reset = true}) async {
    if (reset) {
      _currentPage = 1;
      hasMore.value = true;
      isLoading.value = true;
      isLoadingMore.value = false;
    } else {
      isLoadingMore.value = true;
    }

    try {
      if (reset && !_initialDelayShown) {
        await Future.delayed(const Duration(milliseconds: 1200));
        _initialDelayShown = true;
      }
      final result = await _service.fetchCourses(
        page: _currentPage,
        limit: _pageSize,
        search: searchQuery.value,
      );
      if (reset) {
        courses
          ..clear()
          ..addAll(result);
      } else {
        courses.addAll(result);
      }
      if (result.length < _pageSize) {
        hasMore.value = false;
      }
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
      Get.snackbar('Courses', _formatApiError(e));
    } catch (_) {
      Get.snackbar('Courses', 'Failed to load courses.');
    } finally {
      if (reset) {
        isLoading.value = false;
      } else {
        isLoadingMore.value = false;
      }
    }
  }

  Future<void> loadMoreCourses() async {
    if (isLoadingMore.value || isLoading.value) return;
    if (!hasMore.value) return;
    _currentPage += 1;
    await fetchCourses(reset: false);
  }

  Future<CourseActionResult> createCourse({
    required String title,
    required String shortDescription,
    required String description,
    required String category,
    required String level,
    required double price,
    required double discount,
    required String status,
    required bool certificateEnabled,
    String? thumbnailUrl,
    List<CourseSubjectInput> subjects = const [],
  }) async {
    try {
      final created = await _service.createCourse(
        title: title,
        shortDescription: shortDescription,
        description: description,
        category: category,
        level: level,
        price: price,
        discount: discount,
        status: status,
        certificateEnabled: certificateEnabled,
        thumbnailUrl: thumbnailUrl,
        subjects: subjects,
      );
      courses.insert(0, created);
      return const CourseActionResult.success('Course created successfully.');
    } on ApiException catch (e) {
      if (e.statusCode == 0) {
        return CourseActionResult.networkFailure(e.message);
      }
      return CourseActionResult.failure(_formatApiError(e));
    } catch (_) {
      return const CourseActionResult.failure('Please try again.');
    }
  }

  Future<CourseActionResult> updateCourse({
    required String courseId,
    required String title,
    required String shortDescription,
    required String description,
    required String category,
    required String level,
    required double price,
    required double discount,
    required String status,
    required bool certificateEnabled,
    String? thumbnailUrl,
  }) async {
    try {
      final updated = await _service.updateCourse(
        courseId: courseId,
        title: title,
        shortDescription: shortDescription,
        description: description,
        category: category,
        level: level,
        price: price,
        discount: discount,
        status: status,
        certificateEnabled: certificateEnabled,
        thumbnailUrl: thumbnailUrl,
      );
      final index = courses.indexWhere((course) => course.id == courseId);
      if (index != -1) {
        courses[index] = updated;
      }
      return const CourseActionResult.success('Course updated successfully.');
    } on ApiException catch (e) {
      if (e.statusCode == 0) {
        return CourseActionResult.networkFailure(e.message);
      }
      return CourseActionResult.failure(_formatApiError(e));
    } catch (_) {
      return const CourseActionResult.failure('Please try again.');
    }
  }

  Future<CourseActionResult> deleteCourse(String courseId) async {
    try {
      await _service.deleteCourse(courseId);
      courses.removeWhere((course) => course.id == courseId);
      return const CourseActionResult.success('Course deleted successfully.');
    } on ApiException catch (e) {
      if (e.statusCode == 0) {
        return CourseActionResult.networkFailure(e.message);
      }
      return CourseActionResult.failure(_formatApiError(e));
    } catch (_) {
      return const CourseActionResult.failure('Please try again.');
    }
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = searchController.text.trim();
      fetchCourses();
    });
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }
}

class CourseSubjectInput {
  final String name;
  final String teacherId;
  final int order;

  const CourseSubjectInput({
    required this.name,
    required this.teacherId,
    required this.order,
  });
}

class CourseActionResult {
  final bool isSuccess;
  final bool isNetworkError;
  final String message;

  const CourseActionResult._(
    this.isSuccess,
    this.message, {
    this.isNetworkError = false,
  });

  const CourseActionResult.success(this.message)
      : isSuccess = true,
        isNetworkError = false;

  const CourseActionResult.failure(this.message)
      : isSuccess = false,
        isNetworkError = false;

  const CourseActionResult.networkFailure(this.message)
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
