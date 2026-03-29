import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/home/models/course.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final bool showProgress;

  const CourseCard({
    super.key,
    required this.course,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseTone =
        isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.surfaceSecondary;
    final textColor = isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;
    final chipColor = isDark
        ? SumAcademyTheme.darkElevated.withOpacityFloat(0.7)
        : SumAcademyTheme.white.withOpacityFloat(0.55);
    final pillColor =
        isDark ? SumAcademyTheme.darkElevated : SumAcademyTheme.white;

    return Container(
      width: 240.w,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            course.accent.withOpacityFloat(0.92),
            course.accent.withOpacityFloat(0.72),
            baseTone.withOpacityFloat(isDark ? 0.18 : 0.25),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusLargeCard.r),
        boxShadow: [
          BoxShadow(
            color: course.accent.withOpacityFloat(isDark ? 0.12 : 0.18),
            blurRadius: 24.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            course.subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor.withOpacityFloat(0.8),
                ),
          ),
          const Spacer(),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: course.tags
                .map(
                  (tag) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: chipColor,
                      borderRadius: BorderRadius.circular(
                        SumAcademyTheme.radiusTag.r,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                )
                .toList(),
          ),
          if (showProgress) ...[
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(SumAcademyTheme.radiusPill.r),
              child: LinearProgressIndicator(
                value: course.progress,
                minHeight: 6.h,
                backgroundColor:
                    SumAcademyTheme.white.withOpacityFloat(isDark ? 0.2 : 0.4),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(SumAcademyTheme.white),
              ),
            ),
            SizedBox(height: 10.h),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                course.duration,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: textColor.withOpacityFloat(0.8),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: pillColor,
                  borderRadius: BorderRadius.circular(
                    SumAcademyTheme.radiusButton.r,
                  ),
                ),
                child: Text(
                  'Resume',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
