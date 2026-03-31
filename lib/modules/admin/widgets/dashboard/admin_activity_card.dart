import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/controllers/admin_controller.dart';

class AdminActivityCard extends StatelessWidget {
  final AdminActivity activity;
  final Color surface;
  final Color textColor;
  final VoidCallback? onTap;

  const AdminActivityCard({
    super.key,
    required this.activity,
    required this.surface,
    required this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final muted = textColor.withOpacityFloat(0.6);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
            border: Border.all(color: SumAcademyTheme.brandBluePale),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: activity.tone,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child:
                    Icon(activity.icon, color: activity.iconColor, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      activity.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: muted,
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
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
                        color: muted,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
