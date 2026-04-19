import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/student/controllers/student_announcements_controller.dart';
import 'package:sum_academy/modules/student/controllers/student_shell_controller.dart';
import 'package:sum_academy/modules/student/models/student_announcement.dart';

class StudentNotificationBell extends StatelessWidget {
  final Color? iconColor;

  const StudentNotificationBell({super.key, this.iconColor});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentAnnouncementsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Obx(() {
      final count = controller.unreadCount;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            onPressed: () => _showNotifications(context, controller),
            icon: Icon(
              Icons.notifications_none_rounded,
              color: iconColor ?? defaultColor,
            ),
          ),
          if (count > 0)
            Positioned(
              right: 6.w,
              top: 6.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: SumAcademyTheme.accentOrange,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  count > 9 ? '9+' : count.toString(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: SumAcademyTheme.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

void _showNotifications(
  BuildContext context,
  StudentAnnouncementsController controller,
) {
  controller.fetchAnnouncements(silent: true);
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Notifications',
    barrierColor: Colors.black.withOpacity(0.08),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (context, anim1, anim2, child) {
      final width = MediaQuery.of(context).size.width;
      final dialogWidth = width < 420 ? width - 32.w : 360.w;

      return Transform.translate(
        offset: Offset(0, 10.h * (1 - anim1.value)),
        child: FadeTransition(
          opacity: anim1,
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(top: 66.h, right: 16.w),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: dialogWidth,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white,
                    borderRadius: BorderRadius.circular(22.r),
                    boxShadow: [
                      BoxShadow(
                        color: SumAcademyTheme.darkBase.withOpacityFloat(isDark ? 0.3 : 0.12),
                        blurRadius: 24.r,
                        offset: Offset(0, 10.h),
                      ),
                    ],
                    border: Border.all(
                      color: isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Accent Banner
                      Container(
                        height: 4.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              SumAcademyTheme.brandBlue,
                              SumAcademyTheme.brandBlue.withOpacityFloat(0.7),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20.r),
                        child: _NotificationPanel(controller: controller),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _NotificationPanel extends StatelessWidget {
  final StudentAnnouncementsController controller;

  const _NotificationPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Obx(() {
      final unread = controller.unreadAnnouncements;
      final items = unread.take(4).toList();

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notifications',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              if (items.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: SumAcademyTheme.brandBlue.withOpacityFloat(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${unread.length} NEW',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: SumAcademyTheme.brandBlue,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          if (items.isEmpty)
            _EmptyNotifications(textColor: textColor)
          else
            ...items.map(
              (announcement) => _NotificationTile(
                announcement: announcement,
                onTap: () {
                  controller.markRead(announcement);
                  Navigator.of(context).pop();
                  _openAnnouncements();
                },
              ),
            ),
          SizedBox(height: 12.h),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _openAnnouncements();
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'View All Announcements',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: SumAcademyTheme.brandBlue,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _EmptyNotifications extends StatelessWidget {
  final Color textColor;
  const _EmptyNotifications({required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Row(
        children: [
          Icon(
            Icons.notifications_off_rounded,
            color: textColor.withOpacityFloat(0.3),
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Text(
            'Inbox is clear!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor.withOpacityFloat(0.5),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final StudentAnnouncement announcement;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.announcement,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;
    final surface = isDark ? SumAcademyTheme.darkBase : SumAcademyTheme.surfaceSecondary;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: SumAcademyTheme.brandBlue.withOpacityFloat(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.campaign_rounded,
                  size: 16.sp,
                  color: SumAcademyTheme.brandBlue,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.title.isEmpty ? 'Announcement' : announcement.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      announcement.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: textColor.withOpacityFloat(0.6),
                            height: 1.3,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _openAnnouncements() {
  if (Get.isRegistered<StudentShellController>()) {
    final shell = Get.find<StudentShellController>();
    shell.setActiveLabel('Announcements');
  }
}
