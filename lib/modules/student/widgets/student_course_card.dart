import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/student/models/student_course.dart';

class StudentCourseCard extends StatelessWidget {
  final StudentCourse course;
  final VoidCallback? onContinue;

  const StudentCourseCard({
    super.key,
    required this.course,
    this.onContinue,
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
    final progressPercent = (course.progress * 100).clamp(0, 100).round();
    final statusLabel = course.isCompleted ? 'Completed' : 'In Progress';
    final statusColor =
        course.isCompleted ? SumAcademyTheme.success : SumAcademyTheme.brandBlue;
    final statusBg = course.isCompleted
        ? SumAcademyTheme.successLight
        : SumAcademyTheme.brandBluePale;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  course.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  statusLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            course.teacher.isEmpty ? 'Teacher' : course.teacher,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor.withOpacityFloat(0.6),
                ),
          ),
          if (course.category.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              course.category,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor.withOpacityFloat(0.6),
                  ),
            ),
          ],
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: LinearProgressIndicator(
                    value: course.progress,
                    minHeight: 6.h,
                    backgroundColor: SumAcademyTheme.brandBluePale,
                    valueColor:
                        const AlwaysStoppedAnimation(SumAcademyTheme.brandBlue),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '$progressPercent%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textColor.withOpacityFloat(0.7),
                    ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            'Next lecture: ${course.nextLecture}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor.withOpacityFloat(0.7),
                ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onContinue,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: SumAcademyTheme.brandBlue),
                foregroundColor: SumAcademyTheme.brandBlue,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: const Text('Continue Learning'),
            ),
          ),
        ],
      ),
    );
  }
}
