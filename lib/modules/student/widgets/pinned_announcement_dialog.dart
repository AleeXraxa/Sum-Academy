import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/student/models/student_announcement.dart';

class PinnedAnnouncementDialog extends StatelessWidget {
  final StudentAnnouncement announcement;
  final VoidCallback onClose;

  const PinnedAnnouncementDialog({
    super.key,
    required this.announcement,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border =
        isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;
    final muted = textColor.withOpacityFloat(0.68);

    final title = announcement.title.trim().isEmpty
        ? 'Announcement'
        : announcement.title.trim();
    final sender = announcement.senderName.trim();
    final target = announcement.displayTarget.trim();

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      backgroundColor: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22.r),
        side: BorderSide(color: border),
      ),
      child: Padding(
        padding: EdgeInsets.all(18.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: SumAcademyTheme.brandBlue.withOpacityFloat(0.12),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: SumAcademyTheme.brandBlue.withOpacityFloat(0.18),
                    ),
                  ),
                  child: Icon(
                    Icons.push_pin_rounded,
                    size: 22.sp,
                    color: SumAcademyTheme.brandBlue,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Announcement',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        target.isEmpty ? 'SUM Academy' : target,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: muted,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            SizedBox(height: 8.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 260.h),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  announcement.message.trim(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: muted,
                        height: 1.45,
                      ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 8.h,
              children: [
                if (sender.isNotEmpty)
                  _MetaChip(icon: Icons.person, text: sender),
              ],
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SumAcademyTheme.brandBlue,
                  foregroundColor: SumAcademyTheme.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      SumAcademyTheme.radiusButton.r,
                    ),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark
        ? SumAcademyTheme.darkElevated
        : SumAcademyTheme.surfaceTertiary;
    final border =
        isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: textColor.withOpacityFloat(0.7)),
          SizedBox(width: 6.w),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor.withOpacityFloat(0.82),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
