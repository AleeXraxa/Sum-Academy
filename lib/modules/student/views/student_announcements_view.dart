import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/student/controllers/student_announcements_controller.dart';
import 'package:sum_academy/modules/student/models/student_announcement.dart';
import 'package:sum_academy/modules/student/widgets/student_dashboard_header.dart';

class StudentAnnouncementsView extends GetView<StudentAnnouncementsController> {
  const StudentAnnouncementsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [SumAcademyTheme.darkBase, SumAcademyTheme.darkSurface]
                : [SumAcademyTheme.surfaceSecondary, SumAcademyTheme.white],
          ),
        ),
        child: RefreshIndicator(
          color: SumAcademyTheme.brandBlue,
          onRefresh: controller.refresh,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            children: [
              StudentDashboardHeader(
                subtitle: 'Announcements',
                actions: [
                  if (controller.unreadCount > 0) ...[
                    SizedBox(width: 4.w),
                    IconButton(
                      tooltip: 'Mark all as read',
                      onPressed: controller.markAllRead,
                      icon: Icon(
                        Icons.done_all_rounded,
                        size: 20.sp,
                        color: textColor.withOpacityFloat(0.75),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 6.h),
              _HeaderMeta(controller: controller),
              SizedBox(height: 14.h),
              _FilterRow(controller: controller),
              SizedBox(height: 12.h),
              SizedBox(height: 16.h),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: SumAcademyTheme.brandBlue.withOpacityFloat(0.06),
                        blurRadius: 18.r,
                        offset: Offset(0, 8.h),
                      ),
                  ],
                ),
                child: TextField(
                  controller: controller.searchController,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? SumAcademyTheme.white
                        : SumAcademyTheme.darkBase,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search announcements',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          (isDark
                                  ? SumAcademyTheme.white
                                  : SumAcademyTheme.darkBase)
                              .withOpacityFloat(0.4),
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 20.sp,
                      color: SumAcademyTheme.brandBlue,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? SumAcademyTheme.darkSurface
                        : SumAcademyTheme.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: isDark
                            ? SumAcademyTheme.darkBorder
                            : SumAcademyTheme.brandBluePale,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: isDark
                            ? SumAcademyTheme.darkBorder
                            : SumAcademyTheme.brandBluePale,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: const BorderSide(
                        color: SumAcademyTheme.brandBlue,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              if (controller.isLoading.value)
                const _AnnouncementsSkeleton()
              else if (controller.errorMessage.value.isNotEmpty)
                _ErrorState(
                  message: controller.errorMessage.value,
                  onRetry: controller.fetchAnnouncements,
                )
              else if (controller.filteredAnnouncements.isEmpty)
                const _EmptyState()
              else
                Column(
                  children: controller.filteredAnnouncements
                      .map(
                        (announcement) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _AnnouncementCard(
                            announcement: announcement,
                            onTap: () => controller.markRead(announcement),
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ),
      );
    });
  }
}

class _HeaderMeta extends StatelessWidget {
  final StudentAnnouncementsController controller;

  const _HeaderMeta({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    final updated = controller.lastUpdatedAt.value;
    final updatedLabel = _updatedLabel(updated);

    return Row(
      children: [
        Expanded(
          child: Text(
            'Course, class, system, and direct announcements.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor.withOpacityFloat(0.65),
            ),
          ),
        ),
        if (updatedLabel.isNotEmpty)
          Text(
            updatedLabel,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor.withOpacityFloat(0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  String _updatedLabel(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 5) return 'Updated just now';
    if (diff.inSeconds < 60) return 'Updated ${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes}m ago';
    return 'Updated ${diff.inHours}h ago';
  }
}

class _FilterRow extends StatelessWidget {
  final StudentAnnouncementsController controller;

  const _FilterRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.filterIndex.value;
      return Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: [
          for (var i = 0; i < controller.filters.length; i++)
            _FilterChip(
              label: controller.filters[i].label,
              count: controller.countForType(controller.filters[i].type),
              isActive: selected == i,
              onTap: () => controller.setFilterIndex(i),
            ),
        ],
      );
    });
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SumAcademyTheme.radiusButton.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive
              ? SumAcademyTheme.brandBlue
              : (isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white),
          borderRadius: BorderRadius.circular(SumAcademyTheme.radiusButton.r),
          border: Border.all(
            color: isActive
                ? SumAcademyTheme.brandBlue
                : (isDark
                      ? SumAcademyTheme.darkBorder
                      : SumAcademyTheme.brandBluePale),
            width: 1.2,
          ),
          boxShadow: [
            if (isActive && !isDark)
              BoxShadow(
                color: SumAcademyTheme.brandBlue.withOpacityFloat(0.2),
                blurRadius: 8.r,
                offset: Offset(0, 4.h),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isActive
                    ? SumAcademyTheme.white
                    : (isDark
                              ? SumAcademyTheme.white
                              : SumAcademyTheme.darkBase)
                          .withOpacityFloat(0.7),
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: isActive
                    ? SumAcademyTheme.white.withOpacityFloat(0.2)
                    : (isDark
                          ? SumAcademyTheme.brandBlue.withOpacityFloat(0.15)
                          : SumAcademyTheme.brandBluePale),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                count.toString(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isActive
                      ? SumAcademyTheme.white
                      : SumAcademyTheme.brandBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final StudentAnnouncement announcement;
  final VoidCallback onTap;

  const _AnnouncementCard({required this.announcement, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(announcement.normalizedType);
    final initials = _initialsFor(announcement.senderName);
    final dateLabel = _formatDate(announcement.createdAt);
    final relativeLabel = _relativeLabel(announcement.createdAt);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark
        ? SumAcademyTheme.darkSurface
        : SumAcademyTheme.white;
    final borderColor = isDark
        ? SumAcademyTheme.darkBorder
        : SumAcademyTheme.brandBluePale;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
          border: Border.all(
            color: announcement.isPinned
                ? SumAcademyTheme.accentOrange.withOpacityFloat(0.5)
                : borderColor,
            width: announcement.isPinned ? 1.5 : 1,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: SumAcademyTheme.brandBlue.withOpacityFloat(0.06),
                blurRadius: 20.r,
                offset: Offset(0, 10.h),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top gradient banner
            Container(
              height: 6.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accent.withOpacityFloat(0.8)],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(18.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withOpacityFloat(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          announcement.displayTarget,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      if (announcement.isPinned) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: SumAcademyTheme.accentOrange
                                .withOpacityFloat(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.push_pin_rounded,
                                size: 12.sp,
                                color: SumAcademyTheme.accentOrange,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Pinned',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: SumAcademyTheme.accentOrange,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (!announcement.isRead)
                        Container(
                          width: 8.r,
                          height: 8.r,
                          decoration: const BoxDecoration(
                            color: SumAcademyTheme.brandBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    announcement.title.isEmpty
                        ? 'Announcement'
                        : announcement.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isDark
                          ? SumAcademyTheme.white
                          : SumAcademyTheme.darkBase,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    announcement.message.isEmpty
                        ? 'No announcement message.'
                        : announcement.message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          (isDark
                                  ? SumAcademyTheme.white
                                  : SumAcademyTheme.darkBase)
                              .withOpacityFloat(0.7),
                      height: 1.6,
                    ),
                  ),
                  if (announcement.normalizedType == 'direct') ...[
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Icon(
                          Icons.mail_outline_rounded,
                          size: 14.sp,
                          color: SumAcademyTheme.brandBlue,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Direct Message to You',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: SumAcademyTheme.brandBlue,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 18.h),
                  Row(
                    children: [
                      Container(
                        width: 38.r,
                        height: 38.r,
                        decoration: BoxDecoration(
                          color: SumAcademyTheme.brandBlue.withOpacityFloat(
                            0.1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: SumAcademyTheme.brandBlue,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              announcement.senderName.isEmpty
                                  ? 'SUM Academy'
                                  : announcement.senderName,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color:
                                        (isDark
                                                ? SumAcademyTheme.white
                                                : SumAcademyTheme.darkBase)
                                            .withOpacityFloat(0.9),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            if (dateLabel.isNotEmpty)
                              Text(
                                dateLabel,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color:
                                          (isDark
                                                  ? SumAcademyTheme.white
                                                  : SumAcademyTheme.darkBase)
                                              .withOpacityFloat(0.5),
                                    ),
                              ),
                          ],
                        ),
                      ),
                      if (relativeLabel.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: SumAcademyTheme.brandBluePale,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            relativeLabel,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: SumAcademyTheme.brandBlue,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementsSkeleton extends StatelessWidget {
  const _AnnouncementsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: SumAcademyTheme.white,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: SumAcademyTheme.brandBluePale),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 140.w,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: SumAcademyTheme.surfaceTertiary,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  width: double.infinity,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: SumAcademyTheme.surfaceTertiary,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: SumAcademyTheme.surfaceTertiary,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(
          color: isDark
              ? SumAcademyTheme.darkBorder
              : SumAcademyTheme.brandBluePale,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.notifications_off_rounded,
            size: 64.sp,
            color: SumAcademyTheme.brandBlue.withOpacityFloat(0.2),
          ),
          SizedBox(height: 16.h),
          Text(
            'No announcements yet.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: (isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase)
                  .withOpacityFloat(0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "We'll notify you when something important comes up.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: (isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase)
                  .withOpacityFloat(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

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
          SizedBox(height: 10.h),
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

Color _accentColor(String type) {
  switch (type) {
    case 'course':
      return SumAcademyTheme.accentOrange;
    case 'class':
      return SumAcademyTheme.brandBlue;
    case 'system':
      return SumAcademyTheme.success;
    default:
      return SumAcademyTheme.brandBlue;
  }
}

String _initialsFor(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return 'SA';
  final parts = trimmed.split(RegExp(r'\s+'));
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  final first = parts.first.substring(0, 1).toUpperCase();
  final last = parts.last.substring(0, 1).toUpperCase();
  return '$first$last';
}

String _formatDate(DateTime? date) {
  if (date == null) return '';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final month = months[date.month - 1];
  return '$month ${date.day}, ${date.year}';
}

String _relativeLabel(DateTime? date) {
  if (date == null) return '';
  final now = DateTime.now();
  if (now.year == date.year && now.month == date.month && now.day == date.day) {
    return 'Today';
  }
  return '';
}
