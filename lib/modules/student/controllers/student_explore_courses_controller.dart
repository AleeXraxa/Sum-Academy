import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/student/models/student_explore_course.dart';
import 'package:sum_academy/modules/student/services/student_explore_courses_service.dart';

class StudentExploreCoursesController extends GetxController {
  StudentExploreCoursesController(this._service);

  final StudentExploreCoursesService _service;

  final courses = <StudentExploreCourse>[].obs;
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

  List<String> get filterOptions {
    final levels = courses
        .map((course) => course.level.trim())
        .where((level) => level.isNotEmpty)
        .toSet()
        .toList();
    levels.sort();
    return ['All', ...levels];
  }

  List<StudentExploreCourse> get filteredCourses {
    final query = searchQuery.value.trim().toLowerCase();
    final filter = activeFilter.value;
    return courses.where((course) {
      if (filter != 'All' && course.level != filter) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final haystack =
          '${course.title} ${course.category} ${course.level}'.toLowerCase();
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
          title: 'Explore failed',
          message: e.message,
        );
      }
    } catch (_) {
      await showAppErrorDialog(
        title: 'Explore failed',
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
