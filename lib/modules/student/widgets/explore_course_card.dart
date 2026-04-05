import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/student/models/student_explore_course.dart';

class ExploreCourseCard extends StatelessWidget {
  final StudentExploreCourse course;
  final VoidCallback? onEnroll;

  const ExploreCourseCard({
    super.key,
    required this.course,
    this.onEnroll,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border = isDark
        ? SumAcademyTheme.darkBorder
        : SumAcademyTheme.brandBluePale;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;
    final hasDiscount = course.discount > 0;
    final discountedPrice = hasDiscount
        ? course.price * (1 - (course.discount / 100))
        : course.price;
    final isEnrolled = course.isEnrolled;
    final actionLabel = isEnrolled ? 'Enrolled' : 'Enroll';
    final actionColor =
        isEnrolled ? SumAcademyTheme.success : SumAcademyTheme.brandBlue;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 96.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: SumAcademyTheme.brandBluePale,
              borderRadius: BorderRadius.circular(18.r),
            ),
            alignment: Alignment.center,
            child: Text(
              course.category.isEmpty ? 'Course' : course.category,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: SumAcademyTheme.brandBlue,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            course.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 6.h),
          Text(
            course.level.isEmpty ? 'Teacher' : course.level,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor.withOpacityFloat(0.6),
                ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Rating 0.0  ${course.enrolledCount} enrolled',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor.withOpacityFloat(0.6),
                ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text(
                _formatPkr(discountedPrice),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (hasDiscount) ...[
                SizedBox(width: 8.w),
                Text(
                  _formatPkr(course.price),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textColor.withOpacityFloat(0.5),
                        decoration: TextDecoration.lineThrough,
                      ),
                ),
              ],
            ],
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onEnroll,
              style: ElevatedButton.styleFrom(
                backgroundColor: actionColor,
                foregroundColor: SumAcademyTheme.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatPkr(double value) {
  final rounded = value.isNaN ? 0 : value.round();
  return 'PKR $rounded';
}
