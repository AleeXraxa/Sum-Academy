import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/models/admin_announcement.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_ui.dart';

class AnnouncementCard extends StatelessWidget {
  final AdminAnnouncement announcement;
  final Color surface;
  final Color textColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.surface,
    required this.textColor,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePin,
  });

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(announcement.normalizedType);
    final createdLabel = _formatDateTime(announcement.createdAt);
    final subtitlePieces = <String>[];
    if (announcement.createdBy.isNotEmpty) {
      subtitlePieces.add('Posted by ${announcement.createdBy}');
    }
    if (createdLabel.isNotEmpty) {
      subtitlePieces.add(createdLabel);
    }
    if (announcement.reachedCount > 0) {
      subtitlePieces.add('${announcement.reachedCount} reached');
    }
    final subtitle = subtitlePieces.join('  ');

    return Container(
      decoration: AdminUi.cardDecoration(
        surface: surface,
        border: AdminUi.borderColor(context),
      ).copyWith(
        borderRadius: BorderRadius.circular(18.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 6.w,
            child: Container(color: accent),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w + 6.w, 14.h, 16.w, 16.h),
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
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      if (announcement.isPinned) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: SumAcademyTheme.brandBluePale,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Pinned',
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: SumAcademyTheme.brandBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      _ActionIcon(
                        icon: Icons.edit_outlined,
                        onTap: onEdit,
                      ),
                      SizedBox(width: 8.w),
                      _ActionIcon(
                        icon: announcement.isPinned
                            ? Icons.push_pin
                            : Icons.push_pin_outlined,
                        onTap: onTogglePin,
                      ),
                      SizedBox(width: 8.w),
                      _ActionIcon(
                        icon: Icons.delete_outline,
                        onTap: onDelete,
                        color: SumAcademyTheme.error,
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    announcement.title.isEmpty
                        ? 'Announcement'
                        : announcement.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    announcement.message.isEmpty
                        ? 'No message provided.'
                        : announcement.message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColor.withOpacityFloat(0.7),
                          height: 1.5,
                        ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: textColor.withOpacityFloat(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _ActionIcon({
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? SumAcademyTheme.darkBase;
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: onTap,
      child: Container(
        width: 34.r,
        height: 34.r,
        decoration: BoxDecoration(
          color: SumAcademyTheme.surfaceTertiary,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: SumAcademyTheme.brandBluePale,
          ),
        ),
        child: Icon(icon, size: 18.sp, color: iconColor),
      ),
    );
  }
}

Color _accentColor(String type) {
  switch (type) {
    case 'system':
      return SumAcademyTheme.brandBlue;
    case 'class':
      return SumAcademyTheme.accentOrange;
    case 'course':
      return SumAcademyTheme.success;
    case 'single_user':
      return SumAcademyTheme.adminPurple;
    default:
      return SumAcademyTheme.brandBlue;
  }
}

String _formatDateTime(DateTime? date) {
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
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$month ${date.day}, ${date.year}  $hour:$minute';
}
