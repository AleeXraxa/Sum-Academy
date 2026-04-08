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
    return Obx(() {
      final count = controller.unreadCount;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            onPressed: () => _showNotifications(context, controller),
            icon: Icon(
              Icons.notifications_none_rounded,
              color: iconColor ?? SumAcademyTheme.darkBase,
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
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.08),
    builder: (context) {
      final width = MediaQuery.of(context).size.width;
      final dialogWidth = width < 420 ? width - 32.w : 360.w;
      return Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.only(top: 66.h, right: 16.w),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: dialogWidth,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: SumAcademyTheme.white,
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: SumAcademyTheme.darkBase.withOpacityFloat(0.12),
                    blurRadius: 18.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
                border: Border.all(color: SumAcademyTheme.brandBluePale),
              ),
              child: _NotificationPanel(controller: controller),
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
    return Obx(() {
      final unread = controller.unreadAnnouncements;
      final items = unread.take(4).toList();
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: SumAcademyTheme.darkBase,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 12.h),
          if (items.isEmpty)
            Text(
              'No new announcements right now.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                  ),
            )
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
          SizedBox(height: 10.h),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              _openAnnouncements();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Text(
                'See all announcements',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: SumAcademyTheme.brandBlue,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
      );
    });
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
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: SumAcademyTheme.surfaceTertiary,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: SumAcademyTheme.brandBluePale),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                announcement.title.isEmpty
                    ? 'Announcement'
                    : announcement.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SumAcademyTheme.darkBase,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              SizedBox(height: 4.h),
              Text(
                announcement.message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
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
