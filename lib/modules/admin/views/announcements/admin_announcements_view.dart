import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';
import 'package:sum_academy/modules/admin/controllers/admin_announcement_controller.dart';
import 'package:sum_academy/modules/admin/widgets/announcements/announcement_card.dart';
import 'package:sum_academy/modules/admin/widgets/announcements/announcement_skeleton.dart';
import 'package:sum_academy/modules/admin/widgets/announcements/announcement_stat_card.dart';
import 'package:sum_academy/modules/admin/widgets/announcements/post_announcement_dialog.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_filter_panel.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_ui.dart';
import 'package:sum_academy/modules/admin/widgets/header/admin_header_row.dart';
import 'package:sum_academy/modules/admin/widgets/users/user_filter_chip.dart';
import 'package:sum_academy/modules/auth/widgets/auth_text_field.dart';

class AdminAnnouncementsView extends StatefulWidget {
  final AdminAnnouncementController controller;
  final Color textColor;
  final Color surface;
  final bool isDark;
  final String userName;

  const AdminAnnouncementsView({
    super.key,
    required this.controller,
    required this.textColor,
    required this.surface,
    required this.isDark,
    required this.userName,
  });

  @override
  State<AdminAnnouncementsView> createState() => _AdminAnnouncementsViewState();
}

class _AdminAnnouncementsViewState extends State<AdminAnnouncementsView> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.controller.refresh,
      color: widget.textColor,
      child: ListView(
        padding: AdminUi.pagePadding(),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          AdminHeaderRow(
            textColor: widget.textColor,
            userName: widget.userName,
            isSearchExpanded: false,
            onSearchTap: () {},
            onSearchClose: () {},
            searchController: widget.controller.searchController,
            showSearch: false,
            showProfile: false,
            showNotifications: false,
          ),
          SizedBox(height: 18.h),
          AdminSectionHeader(
            title: 'Announcements',
            subtitle:
                'Broadcast updates by system, class, course, or single user with pin and email control.',
            textColor: widget.textColor,
            isPageHeader: true,
            trailing: _PostButton(
              onPressed: () => showPostAnnouncementDialog(
                context,
                controller: widget.controller,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Obx(() => _StatsRow(
                total: widget.controller.totalCount,
                pinned: widget.controller.pinnedCount,
                emailed: widget.controller.emailCount,
                surface: widget.surface,
                textColor: widget.textColor,
              )),
          SizedBox(height: 14.h),
          AdminFilterPanel(
            surface: widget.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  final selected = widget.controller.filterIndex.value;
                  return Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: [
                      for (var i = 0;
                          i < widget.controller.filters.length;
                          i++)
                        UserFilterChip(
                          label: widget.controller.filters[i].label,
                          count: widget.controller.countForFilter(
                            widget.controller.filters[i].type,
                          ),
                          isSelected: selected == i,
                          onTap: () =>
                              widget.controller.setFilterIndex(i),
                        ),
                    ],
                  );
                }),
                SizedBox(height: 12.h),
                AuthTextField(
                  controller: widget.controller.searchController,
                  label: 'Search',
                  hint: 'Search title or message...',
                  icon: Icons.search_rounded,
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: (_) {},
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Obx(() {
            if (widget.controller.isLoading.value) {
              return const AnnouncementSkeletonList(count: 3);
            }
            if (widget.controller.errorMessage.value.isNotEmpty) {
              return _ErrorState(
                message: widget.controller.errorMessage.value,
                onRetry: widget.controller.fetchAnnouncements,
              );
            }
            final items = widget.controller.filteredAnnouncements;
            if (items.isEmpty) {
              return _EmptyState(
                onPost: () => showPostAnnouncementDialog(
                  context,
                  controller: widget.controller,
                ),
              );
            }
            return Column(
              children: items
                  .map(
                    (announcement) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: AnnouncementCard(
                        announcement: announcement,
                        surface: widget.surface,
                        textColor: widget.textColor,
                        onEdit: () => showPostAnnouncementDialog(
                          context,
                          controller: widget.controller,
                          announcement: announcement,
                        ),
                        onDelete: () => _confirmDelete(
                          context,
                          announcement.id,
                          announcement.title,
                        ),
                        onTogglePin: () =>
                            widget.controller.togglePinned(announcement),
                      ),
                    ),
                  )
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String id,
    String title,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Announcement'),
        content: Text(
          'Delete "${title.isEmpty ? 'this announcement' : title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: SumAcademyTheme.error,
              foregroundColor: SumAcademyTheme.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await showLoadingDialog(context, message: 'Deleting announcement...');
    try {
      await widget.controller.deleteAnnouncement(
        widget.controller.announcements
            .firstWhere((item) => item.id == id),
      );
    } finally {
      Navigator.of(context).pop();
    }
  }
}

class _PostButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _PostButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.campaign_rounded),
      label: const Text('Post Announcement'),
      style: ElevatedButton.styleFrom(
        backgroundColor: SumAcademyTheme.brandBlue,
        foregroundColor: SumAcademyTheme.white,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            SumAcademyTheme.radiusButton.r,
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int total;
  final int pinned;
  final int emailed;
  final Color surface;
  final Color textColor;

  const _StatsRow({
    required this.total,
    required this.pinned,
    required this.emailed,
    required this.surface,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final spacing = 12.w;
      final isWide = width > 820;
      final cardWidth = isWide
          ? (width - (spacing * 2)) / 3
          : width;
      return Wrap(
        spacing: spacing,
        runSpacing: 12.h,
        children: [
          SizedBox(
            width: cardWidth,
            child: AnnouncementStatCard(
              label: 'Total',
              value: total.toString(),
              accent: SumAcademyTheme.brandBlue,
              surface: surface,
              textColor: textColor,
            ),
          ),
          SizedBox(
            width: cardWidth,
            child: AnnouncementStatCard(
              label: 'Pinned',
              value: pinned.toString(),
              accent: SumAcademyTheme.accentOrange,
              surface: surface,
              textColor: textColor,
            ),
          ),
          SizedBox(
            width: cardWidth,
            child: AnnouncementStatCard(
              label: 'Sent via Email',
              value: emailed.toString(),
              accent: SumAcademyTheme.success,
              surface: surface,
              textColor: textColor,
            ),
          ),
        ],
      );
    });
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onPost;

  const _EmptyState({required this.onPost});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No announcements yet.',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: SumAcademyTheme.darkBase,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Post your first announcement to keep everyone informed.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                ),
          ),
          SizedBox(height: 12.h),
          ElevatedButton(
            onPressed: onPost,
            style: ElevatedButton.styleFrom(
              backgroundColor: SumAcademyTheme.brandBlue,
              foregroundColor: SumAcademyTheme.white,
            ),
            child: const Text('Post Announcement'),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.errorLight,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: SumAcademyTheme.error.withOpacityFloat(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unable to load announcements',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: SumAcademyTheme.error,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 6.h),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                ),
          ),
          SizedBox(height: 12.h),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: SumAcademyTheme.brandBlue,
              side: const BorderSide(color: SumAcademyTheme.brandBluePale),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
