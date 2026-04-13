import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/student/controllers/student_courses_controller.dart';
import 'package:sum_academy/modules/student/controllers/student_explore_courses_controller.dart';
import 'package:sum_academy/modules/student/models/student_announcement.dart';
import 'package:sum_academy/modules/student/models/student_class.dart';
import 'package:sum_academy/modules/student/models/student_course.dart';
import 'package:sum_academy/modules/student/models/student_explore_course.dart';
import 'package:sum_academy/modules/student/services/student_announcements_service.dart';
import 'package:sum_academy/modules/student/widgets/pinned_announcement_dialog.dart';

class StudentAnnouncementsController extends GetxController {
  StudentAnnouncementsController(this._service);

  final StudentAnnouncementsService _service;

  final RxList<StudentAnnouncement> announcements =
      <StudentAnnouncement>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt filterIndex = 0.obs;
  final Rxn<DateTime> lastUpdatedAt = Rxn<DateTime>();

  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  Timer? _searchDebounce;
  Timer? _autoRefreshTimer;
  static const Duration _autoRefreshInterval = Duration(seconds: 30);
  bool _isAutoRefreshing = false;
  final List<Worker> _workers = [];
  final Set<String> _shownPinnedPopupIds = <String>{};
  bool _pinnedPopupQueued = false;

  final List<StudentAnnouncementFilter> filters = const [
    StudentAnnouncementFilter(label: 'All', type: 'all'),
    StudentAnnouncementFilter(label: 'Course Announcements', type: 'course'),
    StudentAnnouncementFilter(label: 'Class Announcements', type: 'class'),
    StudentAnnouncementFilter(label: 'System', type: 'system'),
    StudentAnnouncementFilter(label: 'Direct', type: 'direct'),
  ];

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    fetchAnnouncements();
    _linkTargetNames();
    _startAutoRefresh();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    _autoRefreshTimer?.cancel();
    for (final worker in _workers) {
      worker.dispose();
    }
    _workers.clear();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchAnnouncements({bool silent = false}) async {
    if (!silent) {
      isLoading.value = true;
      errorMessage.value = '';
    }
    try {
      final result = await _service.fetchAnnouncements();
      final sorted = _sortAnnouncements(result);
      final updated = _applyTargetNameOverrides(sorted);
      announcements.assignAll(
        silent ? _mergeAnnouncements(announcements.toList(), updated) : updated,
      );
      lastUpdatedAt.value = DateTime.now();
      if (!silent) {
        errorMessage.value = '';
      }
      _maybeShowPinnedAnnouncementPopup();
    } on ApiException catch (e) {
      if (silent) {
        return;
      }
      errorMessage.value = e.message;
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showAppErrorDialog(
          title: 'Announcements',
          message: e.message,
        );
      }
    } catch (_) {
      if (!silent) {
        errorMessage.value = 'Unable to load announcements.';
      }
    } finally {
      if (!silent) {
        isLoading.value = false;
      }
    }
  }

  void _maybeShowPinnedAnnouncementPopup() {
    if (_pinnedPopupQueued) return;
    if (Get.isDialogOpen ?? false) return;
    if (announcements.isEmpty) return;

    StudentAnnouncement? candidate;
    for (final item in announcements) {
      if (!item.isPinned) continue;
      if (item.isRead) continue;
      if (item.id.isEmpty) continue;
      if (_shownPinnedPopupIds.contains(item.id)) continue;
      candidate = item;
      break;
    }
    if (candidate == null) return;
    final pinned = candidate;

    // Avoid showing during rebuilds and repeated auto-refreshes.
    _pinnedPopupQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (Get.isDialogOpen ?? false) return;
        final context = Get.context;
        if (context == null) return;

        await Get.dialog<void>(
          PinnedAnnouncementDialog(
            announcement: pinned,
            onClose: () => Get.back<void>(),
          ),
          barrierDismissible: true,
        );
        _shownPinnedPopupIds.add(pinned.id);
        await markRead(pinned);
      } finally {
        _pinnedPopupQueued = false;
      }
    });
  }

  Future<void> refresh() async {
    await fetchAnnouncements();
  }

  void setFilterIndex(int index) {
    filterIndex.value = index;
  }

  List<StudentAnnouncement> get filteredAnnouncements {
    final query = searchQuery.value.trim().toLowerCase();
    final filterType = filters[filterIndex.value].type;
    Iterable<StudentAnnouncement> list = announcements;
    if (filterType != 'all') {
      list = list.where((item) => item.normalizedType == filterType);
    }
    if (query.isNotEmpty) {
      list = list.where(
        (item) =>
            item.title.toLowerCase().contains(query) ||
            item.message.toLowerCase().contains(query) ||
            item.displayTarget.toLowerCase().contains(query),
      );
    }
    return list.toList();
  }

  List<StudentAnnouncement> get unreadAnnouncements {
    return announcements
        .where((item) => !item.isRead)
        .toList();
  }

  int get unreadCount => unreadAnnouncements.length;

  int countForType(String type) {
    if (type == 'all') return announcements.length;
    return announcements.where((item) => item.normalizedType == type).length;
  }

  Future<void> markRead(StudentAnnouncement announcement) async {
    if (announcement.isRead || announcement.id.isEmpty) return;
    try {
      await _service.markRead(announcement.id);
      final index =
          announcements.indexWhere((item) => item.id == announcement.id);
      if (index >= 0) {
        announcements[index] = announcements[index].copyWith(isRead: true);
      }
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    final unread = unreadAnnouncements;
    if (unread.isEmpty) return;

    for (final item in unread) {
      await markRead(item);
    }
  }

  List<StudentAnnouncement> _mergeAnnouncements(
    List<StudentAnnouncement> existing,
    List<StudentAnnouncement> incoming,
  ) {
    if (existing.isEmpty) return incoming;
    if (incoming.isEmpty) return existing;

    final existingById = <String, StudentAnnouncement>{};
    for (final item in existing) {
      if (item.id.isNotEmpty) {
        existingById[item.id] = item;
      }
    }

    return incoming.map((next) {
      final previous = existingById[next.id];
      if (previous == null) return next;
      return previous.copyWith(
        title: next.title,
        message: next.message,
        targetName: next.targetName,
        isPinned: next.isPinned,
        isRead: previous.isRead || next.isRead,
      );
    }).toList();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = searchController.text.trim();
    });
  }

  List<StudentAnnouncement> _sortAnnouncements(
    Iterable<StudentAnnouncement> items,
  ) {
    final list = items.toList();
    list.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return list;
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(_autoRefreshInterval, (_) async {
      if (isLoading.value || _isAutoRefreshing) return;
      _isAutoRefreshing = true;
      try {
        await fetchAnnouncements(silent: true);
      } finally {
        _isAutoRefreshing = false;
      }
    });
  }

  void _linkTargetNames() {
    if (Get.isRegistered<StudentCoursesController>()) {
      final coursesController = Get.find<StudentCoursesController>();
      _workers.add(
        ever<List<StudentCourse>>(coursesController.courses, (_) {
          _refreshTargetNames();
        }),
      );
      _workers.add(
        ever<List<StudentEnrolledClass>>(coursesController.classes, (_) {
          _refreshTargetNames();
        }),
      );
    }
    if (Get.isRegistered<StudentExploreCoursesController>()) {
      final exploreController = Get.find<StudentExploreCoursesController>();
      _workers.add(
        ever<List<StudentExploreCourse>>(exploreController.courses, (_) {
          _refreshTargetNames();
        }),
      );
    }
  }

  void _refreshTargetNames() {
    if (announcements.isEmpty) return;
    final updated = _applyTargetNameOverrides(announcements.toList());
    if (_hasTargetNameChanges(updated)) {
      announcements.assignAll(updated);
    }
  }

  List<StudentAnnouncement> _applyTargetNameOverrides(
    List<StudentAnnouncement> items,
  ) {
    if (items.isEmpty) return items;
    final courseNames = _courseNameLookup();
    final classNames = _classNameLookup();
    if (courseNames.isEmpty && classNames.isEmpty) return items;

    return items.map((item) {
      if (item.targetName.isNotEmpty && !_looksLikeId(item.targetName)) {
        return item;
      }
      final normalized = item.normalizedType;
      String resolved = '';
      if (normalized == 'course') {
        resolved = courseNames[item.targetId.trim()] ?? '';
      } else if (normalized == 'class') {
        resolved = classNames[item.targetId.trim()] ?? '';
      }
      return resolved.isNotEmpty ? item.copyWith(targetName: resolved) : item;
    }).toList();
  }

  bool _looksLikeId(String value) {
    final trimmed = value.trim();
    if (trimmed.length < 18) return false;
    if (trimmed.contains(' ')) return false;
    return true;
  }

  bool _hasTargetNameChanges(List<StudentAnnouncement> next) {
    if (next.length != announcements.length) return true;
    for (var i = 0; i < next.length; i++) {
      if (next[i].targetName != announcements[i].targetName) return true;
    }
    return false;
  }

  Map<String, String> _courseNameLookup() {
    final lookup = <String, String>{};
    if (Get.isRegistered<StudentCoursesController>()) {
      final courses = Get.find<StudentCoursesController>().courses;
      for (final course in courses) {
        final id = course.id.trim();
        final title = course.title.trim();
        if (id.isNotEmpty && title.isNotEmpty) {
          lookup[id] = title;
        }
      }
    }
    if (Get.isRegistered<StudentExploreCoursesController>()) {
      final explore = Get.find<StudentExploreCoursesController>().courses;
      for (final item in explore) {
        for (final subject in item.subjects) {
          final id = subject.id.trim();
          final title = subject.title.trim();
          if (id.isNotEmpty && title.isNotEmpty) {
            lookup[id] = title;
          }
        }
      }
    }
    return lookup;
  }

  Map<String, String> _classNameLookup() {
    final lookup = <String, String>{};
    if (Get.isRegistered<StudentCoursesController>()) {
      final classes = Get.find<StudentCoursesController>().classes;
      for (final item in classes) {
        final id = item.id.trim();
        final name = item.name.trim();
        if (id.isNotEmpty && name.isNotEmpty) {
          lookup[id] = name;
        }
      }
    }
    if (Get.isRegistered<StudentExploreCoursesController>()) {
      final explore = Get.find<StudentExploreCoursesController>().courses;
      for (final item in explore) {
        final id = item.id.trim();
        final name = item.title.trim();
        if (id.isNotEmpty && name.isNotEmpty) {
          lookup[id] = name;
        }
      }
    }
    return lookup;
  }
}

class StudentAnnouncementFilter {
  final String label;
  final String type;

  const StudentAnnouncementFilter({required this.label, required this.type});
}
