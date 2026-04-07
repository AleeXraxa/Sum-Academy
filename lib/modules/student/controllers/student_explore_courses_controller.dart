import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/student/controllers/student_courses_controller.dart';
import 'package:sum_academy/modules/student/models/student_explore_course.dart';
import 'package:sum_academy/modules/student/models/student_course.dart';
import 'package:sum_academy/modules/student/services/student_explore_courses_service.dart';

class StudentExploreCoursesController extends GetxController {
  StudentExploreCoursesController(this._service);

  final StudentExploreCoursesService _service;

  final courses = <StudentExploreCourse>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final activeFilter = 'All'.obs;

  final searchController = TextEditingController();
  bool _coursesLinked = false;

  @override
  void onInit() {
    super.onInit();
    fetchCourses();
    _linkMyCourses();
    searchController.addListener(_onSearchChanged);
  }

  List<String> get filterOptions {
    final buckets = courses
        .map((course) =>
            (course.level.isNotEmpty ? course.level : course.category).trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();
    buckets.sort();
    return ['All', ...buckets];
  }

  List<StudentExploreCourse> get filteredCourses {
    final query = searchQuery.value.trim().toLowerCase();
    final filter = activeFilter.value;
    return courses.where((course) {
      final bucket =
          course.level.isNotEmpty ? course.level : course.category;
      if (filter != 'All' && bucket != filter) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final subjects = course.subjects
          .map((subject) => subject.title)
          .join(' ')
          .toLowerCase();
      final haystack =
          '${course.title} ${course.category} ${course.level} ${course.code} ${course.teacher} $subjects'
              .toLowerCase();
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
      _applyEnrollmentStatus(_enrolledCoursesSnapshot());
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

  void _linkMyCourses() {
    if (_coursesLinked) return;
    if (!Get.isRegistered<StudentCoursesController>()) return;
    _coursesLinked = true;
    final coursesController = Get.find<StudentCoursesController>();
    ever<List<StudentCourse>>(coursesController.courses, (list) {
      if (list.isNotEmpty && courses.isNotEmpty) {
        _applyEnrollmentStatus(list);
      }
    });
  }

  List<StudentCourse> _enrolledCoursesSnapshot() {
    if (!Get.isRegistered<StudentCoursesController>()) {
      return const [];
    }
    return Get.find<StudentCoursesController>().courses.toList();
  }

  void _applyEnrollmentStatus(List<StudentCourse> enrolledCourses) {
    if (enrolledCourses.isEmpty || courses.isEmpty) return;
    final enrolledIds = enrolledCourses
        .map((course) => course.id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();
    final enrolledClassIds = enrolledCourses
        .map((course) => course.classId.trim())
        .where((id) => id.isNotEmpty)
        .toSet();
    final enrolledClassNames = enrolledCourses
        .map((course) => course.className.trim().toLowerCase())
        .where((name) => name.isNotEmpty)
        .toSet();
    final enrolledTitles = enrolledCourses
        .map((course) => course.title.trim().toLowerCase())
        .where((title) => title.isNotEmpty)
        .toSet();

    final updated = courses.map((course) {
      if (course.isEnrolled || course.isFullyEnrolled || course.isPartiallyEnrolled) {
        return course;
      }
      final idMatch =
          course.id.isNotEmpty && enrolledIds.contains(course.id.trim());
      final classIdMatch =
          course.id.isNotEmpty && enrolledClassIds.contains(course.id.trim());
      final titleMatch = course.title.isNotEmpty &&
          enrolledTitles.contains(course.title.trim().toLowerCase());
      final classNameMatch = course.title.isNotEmpty &&
          enrolledClassNames.contains(course.title.trim().toLowerCase());
      final shouldMark = idMatch || classIdMatch || titleMatch || classNameMatch;
      return shouldMark ? course.copyWith(isEnrolled: true) : course;
    }).toList();

    courses.assignAll(updated);
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }
}
