import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/student/models/student_course.dart';
import 'package:sum_academy/modules/student/services/student_courses_service.dart';

class StudentCoursesController extends GetxController {
  StudentCoursesController(this._service);

  final StudentCoursesService _service;

  final courses = <StudentCourse>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final activeFilter = 'All'.obs;

  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchCourses();
    searchController.addListener(_onSearchChanged);
  }

  List<StudentCourse> get filteredCourses {
    final query = searchQuery.value.trim().toLowerCase();
    final filter = activeFilter.value;
    return courses.where((course) {
      if (filter == 'Completed' && !course.isCompleted) {
        return false;
      }
      if (filter == 'In Progress' && course.isCompleted) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final haystack =
          '${course.title} ${course.teacher} ${course.category}'.toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  Future<void> fetchCourses({bool silent = false}) async {
    if (!silent) {
      isLoading.value = true;
    }
    try {
      final result = await _service.fetchCourses();
      courses.assignAll(result);
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showAppErrorDialog(
          title: 'Courses failed',
          message: e.message,
        );
      }
    } catch (_) {
      await showAppErrorDialog(
        title: 'Courses failed',
        message: 'Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    await fetchCourses(silent: true);
  }

  void setFilter(String filter) {
    activeFilter.value = filter;
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text;
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }
}
