import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/student/models/student_class.dart';
import 'package:sum_academy/modules/student/models/student_course.dart';
import 'package:sum_academy/modules/student/services/student_courses_service.dart';

class StudentCoursesController extends GetxController {
  StudentCoursesController(this._service);

  final StudentCoursesService _service;

  final courses = <StudentCourse>[].obs;
  final classes = <StudentEnrolledClass>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final activeFilter = 'All'.obs;
  final selectedClassId = ''.obs;

  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchCourses();
    searchController.addListener(_onSearchChanged);
  }

  List<StudentCourse> get filteredCourses {
    final selected = _selectedClass;
    final source = selected?.courses ?? courses;
    final query = searchQuery.value.trim().toLowerCase();
    final filter = activeFilter.value;
    return source.where((course) {
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

  StudentEnrolledClass? get _selectedClass {
    final id = selectedClassId.value;
    if (id.isEmpty && classes.isNotEmpty) return classes.first;
    for (final item in classes) {
      if (item.id == id) return item;
    }
    return null;
  }

  StudentEnrolledClass? get selectedClass => _selectedClass;

  Future<void> fetchCourses({bool silent = false}) async {
    if (!silent) {
      isLoading.value = true;
    }
    try {
      final result = await _service.fetchCourses();
      courses.assignAll(result);
      _rebuildClasses(result);
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

  void selectClass(String classId) {
    if (classId.isEmpty) return;
    selectedClassId.value = classId;
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text;
  }

  void _rebuildClasses(List<StudentCourse> items) {
    if (items.isEmpty) {
      classes.clear();
      selectedClassId.value = '';
      return;
    }

    final grouped = <String, List<StudentCourse>>{};
    for (final course in items) {
      final key = course.classId.isNotEmpty
          ? course.classId
          : (course.className.isNotEmpty ? course.className : 'all');
      grouped.putIfAbsent(key, () => []).add(course);
    }

    final built = <StudentEnrolledClass>[];
    grouped.forEach((key, courses) {
      final enrolledCourses =
          courses.where((course) => course.isEnrolled).toList();
      final visibleCourses =
          enrolledCourses.isNotEmpty ? enrolledCourses : courses;
      final totalCourses = courses
          .map((course) => course.classTotalCourses)
          .where((value) => value > 0)
          .fold<int>(0, (maxValue, value) => value > maxValue ? value : maxValue);
      final paidCourses = courses
          .map((course) => course.classPaidCourses)
          .where((value) => value > 0)
          .fold<int>(0, (maxValue, value) => value > maxValue ? value : maxValue);
      final computedPaid = paidCourses > 0 ? paidCourses : enrolledCourses.length;
      final computedTotal =
          totalCourses > 0 ? totalCourses : visibleCourses.length;
      final classProgress = visibleCourses.isEmpty
          ? 0.0
          : visibleCourses
                  .map((course) => course.progress)
                  .fold<double>(0, (sum, value) => sum + value) /
              visibleCourses.length;
      final sample = courses.first;
      final thumbnail = courses
          .map((course) => course.thumbnailUrl)
          .firstWhere((value) => value.isNotEmpty, orElse: () => '');

      built.add(
        StudentEnrolledClass(
          id: sample.classId.isNotEmpty ? sample.classId : key,
          code: sample.classCode,
          name: sample.className.isNotEmpty ? sample.className : 'My Class',
          teacher: sample.classTeacher.isNotEmpty
              ? sample.classTeacher
              : sample.teacher,
          progress: classProgress,
          paidCourses: computedPaid,
          totalCourses: computedTotal,
          courses: visibleCourses,
          thumbnailUrl: thumbnail,
        ),
      );
    });

    built.sort((a, b) => a.name.compareTo(b.name));
    classes.assignAll(built);

    final current = selectedClassId.value;
    if (current.isEmpty ||
        classes.indexWhere((item) => item.id == current) == -1) {
      selectedClassId.value = classes.first.id;
    }
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }
}
