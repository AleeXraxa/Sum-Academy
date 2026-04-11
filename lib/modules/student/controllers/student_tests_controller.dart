import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/student/models/student_test.dart';
import 'package:sum_academy/modules/student/services/student_tests_service.dart';

class StudentTestsController extends GetxController {
  StudentTestsController(this._service);

  final StudentTestsService _service;

  final tests = <StudentTest>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final Rxn<DateTime> lastUpdatedAt = Rxn<DateTime>();

  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    fetchTests();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchTests({bool silent = false}) async {
    if (!silent) {
      isLoading.value = true;
      errorMessage.value = '';
    }
    try {
      final result = await _service.fetchTests();
      tests.assignAll(result);
      lastUpdatedAt.value = DateTime.now();
    } on ApiException catch (e) {
      if (!silent) {
        errorMessage.value = e.message;
        final handled = await handleNetworkError(e);
        if (!handled) {
          await showAppErrorDialog(title: 'Tests', message: e.message);
        }
      }
    } catch (_) {
      if (!silent) {
        errorMessage.value = 'Unable to load tests.';
      }
    } finally {
      if (!silent) {
        isLoading.value = false;
      }
    }
  }

  Future<void> refresh() async {
    await fetchTests();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      searchQuery.value = searchController.text.trim();
    });
  }

  List<StudentTest> get filteredTests {
    final query = searchQuery.value.trim().toLowerCase();
    Iterable<StudentTest> list = tests;
    if (query.isNotEmpty) {
      list = list.where((t) {
        return t.title.toLowerCase().contains(query) ||
            t.description.toLowerCase().contains(query) ||
            t.className.toLowerCase().contains(query);
      });
    }
    final items = list.toList();
    items.sort((a, b) {
      if (a.isActiveNow != b.isActiveNow) return a.isActiveNow ? -1 : 1;
      final aStart = a.startAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bStart = b.startAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aStart.compareTo(bStart);
    });
    return items;
  }
}

