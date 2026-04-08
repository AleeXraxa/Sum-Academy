import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/admin/models/admin_announcement.dart';
import 'package:sum_academy/modules/admin/services/admin_announcement_service.dart';

class AdminAnnouncementFilter {
  final String label;
  final String type;

  const AdminAnnouncementFilter({required this.label, required this.type});
}

class AdminAnnouncementController extends GetxController {
  AdminAnnouncementController(this._service);

  final AdminAnnouncementService _service;

  final RxList<AdminAnnouncement> announcements = <AdminAnnouncement>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt filterIndex = 0.obs;

  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  Timer? _searchDebounce;

  final List<AdminAnnouncementFilter> filters = const [
    AdminAnnouncementFilter(label: 'All', type: 'all'),
    AdminAnnouncementFilter(label: 'System', type: 'system'),
    AdminAnnouncementFilter(label: 'Class', type: 'class'),
    AdminAnnouncementFilter(label: 'Course', type: 'course'),
    AdminAnnouncementFilter(label: 'Single User', type: 'single_user'),
  ];

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    fetchAnnouncements();
  }

  @override
  void onClose() {
    searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _searchDebounce?.cancel();
    super.onClose();
  }

  Future<void> fetchAnnouncements() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _service.fetchAnnouncements();
      announcements.assignAll(_sortAnnouncements(result));
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showAppErrorDialog(
          title: 'Announcements',
          message: e.message,
        );
      }
    } catch (_) {
      errorMessage.value = 'Unable to load announcements.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    await fetchAnnouncements();
  }

  void setFilterIndex(int value) {
    filterIndex.value = value;
  }

  List<AdminAnnouncement> get filteredAnnouncements {
    final query = searchQuery.value.trim().toLowerCase();
    final filterType = filters[filterIndex.value].type;
    Iterable<AdminAnnouncement> list = announcements;
    if (filterType != 'all') {
      list = list.where(
        (item) => item.normalizedType == filterType,
      );
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

  int countForFilter(String type) {
    if (type == 'all') return announcements.length;
    return announcements.where((item) => item.normalizedType == type).length;
  }

  int get totalCount => announcements.length;

  int get pinnedCount =>
      announcements.where((item) => item.isPinned).length;

  int get emailCount => announcements
      .where((item) => item.sendEmail || item.emailsSent > 0)
      .length;

  Future<void> createAnnouncement({
    required String title,
    required String message,
    required String targetType,
    required String audienceRole,
    String? targetId,
    bool sendEmail = false,
    bool isPinned = false,
  }) async {
    try {
      final created = await _service.createAnnouncement(
        title: title,
        message: message,
        targetType: targetType,
        audienceRole: audienceRole,
        targetId: targetId,
        sendEmail: sendEmail,
        isPinned: isPinned,
      );
      announcements.insert(0, created);
      announcements.assignAll(_sortAnnouncements(announcements));
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showAppErrorDialog(
          title: 'Announcement',
          message: e.message,
        );
      }
      rethrow;
    } catch (_) {
      await showAppErrorDialog(
        title: 'Announcement',
        message: 'Unable to post announcement.',
      );
      rethrow;
    }
  }

  Future<void> updateAnnouncement({
    required AdminAnnouncement announcement,
    required String title,
    required String message,
    required bool isPinned,
  }) async {
    try {
      await _service.updateAnnouncement(
        id: announcement.id,
        title: title,
        message: message,
        isPinned: isPinned,
      );
      final index = announcements.indexWhere((item) => item.id == announcement.id);
      if (index >= 0) {
        announcements[index] = announcement.copyWith(
          title: title,
          message: message,
          isPinned: isPinned,
        );
        announcements.assignAll(_sortAnnouncements(announcements));
      }
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showAppErrorDialog(
          title: 'Announcement',
          message: e.message,
        );
      }
      rethrow;
    } catch (_) {
      await showAppErrorDialog(
        title: 'Announcement',
        message: 'Unable to update announcement.',
      );
      rethrow;
    }
  }

  Future<void> deleteAnnouncement(AdminAnnouncement announcement) async {
    try {
      await _service.deleteAnnouncement(announcement.id);
      announcements.removeWhere((item) => item.id == announcement.id);
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showAppErrorDialog(
          title: 'Announcement',
          message: e.message,
        );
      }
      rethrow;
    } catch (_) {
      await showAppErrorDialog(
        title: 'Announcement',
        message: 'Unable to delete announcement.',
      );
      rethrow;
    }
  }

  Future<void> togglePinned(AdminAnnouncement announcement) async {
    try {
      final updatedPinned = !announcement.isPinned;
      await _service.togglePin(
        id: announcement.id,
        isPinned: updatedPinned,
      );
      final index = announcements.indexWhere((item) => item.id == announcement.id);
      if (index >= 0) {
        announcements[index] =
            announcement.copyWith(isPinned: updatedPinned);
        announcements.assignAll(_sortAnnouncements(announcements));
      }
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showAppErrorDialog(
          title: 'Announcement',
          message: e.message,
        );
      }
      rethrow;
    } catch (_) {
      await showAppErrorDialog(
        title: 'Announcement',
        message: 'Unable to update pin status.',
      );
      rethrow;
    }
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      searchQuery.value = searchController.text;
    });
  }

  List<AdminAnnouncement> _sortAnnouncements(
    Iterable<AdminAnnouncement> items,
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
}
