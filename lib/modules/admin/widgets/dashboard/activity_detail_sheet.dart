import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/controllers/admin_controller.dart';

Future<void> showActivityDetailSheet(
  BuildContext context,
  AdminActivity activity,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final surface = isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
  final textColor = isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;
  final borderColor =
      isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale;

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46.r,
                height: 46.r,
                decoration: BoxDecoration(
                  color: activity.tone,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  activity.icon,
                  color: activity.iconColor,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      activity.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: textColor.withOpacityFloat(0.7),
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: SumAcademyTheme.surfaceTertiary,
                  borderRadius:
                      BorderRadius.circular(SumAcademyTheme.radiusPill.r),
                ),
                child: Text(
                  activity.time,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: textColor.withOpacityFloat(0.65),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Details',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: textColor.withOpacityFloat(0.85),
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: isDark
                  ? SumAcademyTheme.darkElevated
                  : SumAcademyTheme.surfaceSecondary,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              activity.subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor.withOpacityFloat(0.75),
                  ),
            ),
          ),
          if ((activity.userName ?? '').trim().isNotEmpty ||
              (activity.ipAddress ?? '').trim().isNotEmpty) ...[
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((activity.userName ?? '').trim().isNotEmpty)
                    _DetailRow(
                      label: 'User',
                      value: activity.userName!.trim(),
                      textColor: textColor,
                    ),
                  if ((activity.userName ?? '').trim().isNotEmpty &&
                      (activity.ipAddress ?? '').trim().isNotEmpty)
                    SizedBox(height: 10.h),
                  if ((activity.ipAddress ?? '').trim().isNotEmpty)
                    _DetailRow(
                      label: 'IP Address',
                      value: activity.ipAddress!.trim(),
                      textColor: textColor,
                      mono: true,
                    ),
                ],
              ),
            ),
          ],
          SizedBox(height: 18.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: SumAcademyTheme.brandBlue,
                foregroundColor: SumAcademyTheme.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(SumAcademyTheme.radiusButton.r),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  final bool mono;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.textColor,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
          color: textColor.withOpacityFloat(0.6),
          fontWeight: FontWeight.w600,
        );
    final baseStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: textColor,
        );
    final valueStyle = mono
        ? GoogleFonts.jetBrainsMono(textStyle: baseStyle)
        : baseStyle;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90.w,
          child: Text(label, style: labelStyle),
        ),
        Expanded(child: Text(value, style: valueStyle)),
      ],
    );
  }
}
