import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/home/models/course.dart';

class ProgressCard extends StatelessWidget {
  final Course course;
  final double weeklyGoalHours;
  final double weeklyProgressHours;

  const ProgressCard({
    super.key,
    required this.course,
    required this.weeklyGoalHours,
    required this.weeklyProgressHours,
  });

  @override
  Widget build(BuildContext context) {
    final progress = weeklyGoalHours <= 0
        ? 0.0
        : math.min(weeklyProgressHours / weeklyGoalHours, 1.0);
    final progressPercent = (course.progress * 100).round();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedText = (isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase)
        .withOpacityFloat(0.7);
    final trackColor =
        isDark ? SumAcademyTheme.darkElevated : SumAcademyTheme.surfaceTertiary;

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusLargeCard.r),
        boxShadow: [
          BoxShadow(
            color: SumAcademyTheme.darkBase.withOpacityFloat(isDark ? 0.12 : 0.08),
            blurRadius: 24.r,
            offset: Offset(0, 16.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Continue learning',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${weeklyProgressHours.toStringAsFixed(1)}/${weeklyGoalHours.toStringAsFixed(0)}h',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: mutedText,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            course.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 20.sp,
                ),
          ),
          SizedBox(height: 4.h),
          Text(
            course.subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 14.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(SumAcademyTheme.radiusPill.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8.h,
              backgroundColor: trackColor,
              valueColor: const AlwaysStoppedAnimation<Color>(
                SumAcademyTheme.brandBlue,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$progressPercent% complete',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: mutedText,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Resume'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
