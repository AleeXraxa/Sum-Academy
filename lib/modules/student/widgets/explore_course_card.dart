import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/student/models/student_explore_course.dart';

class ExploreCourseCard extends StatelessWidget {
  final StudentExploreCourse course;
  final VoidCallback? onEnrollClass;

  const ExploreCourseCard({
    super.key,
    required this.course,
    this.onEnrollClass,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark
        ? SumAcademyTheme.darkSurface
        : SumAcademyTheme.white;
    final border = isDark
        ? SumAcademyTheme.darkBorder
        : SumAcademyTheme.brandBluePale;
    final textColor = isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;
    final hasDiscount = course.discount > 0;
    final classPrice = course.remainingPrice > 0
        ? course.remainingPrice
        : (course.totalPrice > 0 ? course.totalPrice : course.price);
    final discountedPrice = hasDiscount
        ? classPrice * (1 - (course.discount / 100))
        : classPrice;
    final isFullyEnrolled =
        course.isFullyEnrolled ||
        (course.coursesCount > 0 && course.paidCourses >= course.coursesCount);
    final isPartiallyEnrolled =
        course.isPartiallyEnrolled ||
        (!isFullyEnrolled && course.paidCourses > 0);
    final canEnroll = course.canEnroll && !isFullyEnrolled;
    final actionLabel = isFullyEnrolled
        ? 'Enrolled'
        : !canEnroll
        ? 'Enrollment Closed'
        : isPartiallyEnrolled
        ? 'Enroll Remaining - ${_formatPkr(discountedPrice)}'
        : 'Enroll Full Class - ${_formatPkr(discountedPrice)}';
    final actionColor = isFullyEnrolled
        ? SumAcademyTheme.success
        : !canEnroll
        ? SumAcademyTheme.brandBluePale
        : SumAcademyTheme.brandBlue;
    final statusLabel = _statusLabel(course.status);
    final statusTone = _statusTone(course.status);
    final visibleSubjects = course.subjects.take(3).toList();

    final isActionDisabled = isFullyEnrolled || !canEnroll;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: border),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: SumAcademyTheme.brandBlue.withOpacityFloat(0.08),
              blurRadius: 22.r,
              offset: Offset(0, 12.h),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top gradient banner
          Container(
            height: 6.h,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  SumAcademyTheme.brandBlue,
                  SumAcademyTheme.brandBlueDarker,
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 112.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        gradient: course.thumbnailUrl.isEmpty
                            ? LinearGradient(
                                colors: [
                                  SumAcademyTheme.brandBluePale,
                                  SumAcademyTheme.brandBlueLight
                                      .withOpacityFloat(0.45),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        image: course.thumbnailUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(course.thumbnailUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      alignment: course.thumbnailUrl.isEmpty
                          ? Alignment.center
                          : null,
                      child: course.thumbnailUrl.isEmpty
                          ? Container(
                              width: 44.r,
                              height: 44.r,
                              decoration: BoxDecoration(
                                color: SumAcademyTheme.white,
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: SumAcademyTheme.brandBlue
                                        .withOpacityFloat(0.2),
                                    blurRadius: 8.r,
                                    offset: Offset(0, 4.h),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.school_rounded,
                                size: 26.sp,
                                color: SumAcademyTheme.brandBlue,
                              ),
                            )
                          : null,
                    ),
                    if (course.code.isNotEmpty)
                      Positioned(
                        left: 12.w,
                        bottom: 10.h,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: SumAcademyTheme.white.withOpacityFloat(0.95),
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: SumAcademyTheme.darkBase
                                    .withOpacityFloat(0.1),
                                blurRadius: 4.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          child: Text(
                            course.code,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: SumAcademyTheme.brandBlue,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                    if (statusLabel.isNotEmpty)
                      Positioned(
                        right: 12.w,
                        top: 10.h,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: statusTone.withOpacityFloat(0.18),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: statusTone.withOpacityFloat(0.4),
                            ),
                          ),
                          child: Text(
                            statusLabel,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: statusTone,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 14.h),
                Text(
                  course.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: 14.sp,
                      color: textColor.withOpacityFloat(0.55),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        course.teacher.isNotEmpty
                            ? course.teacher
                            : (course.level.isEmpty
                                  ? 'Instructor'
                                  : course.level),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColor.withOpacityFloat(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
                if (course.level.isNotEmpty || course.category.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 6.h,
                    children: [
                      if (course.level.isNotEmpty)
                        _TagChip(label: course.level, textColor: textColor),
                      if (course.category.isNotEmpty &&
                          course.category != course.level)
                        _TagChip(label: course.category, textColor: textColor),
                    ],
                  ),
                ],
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    if (course.spotsLeft > 0)
                      _MetaChip(
                        icon: Icons.event_seat_rounded,
                        label: '${course.spotsLeft} spots left',
                        textColor: textColor,
                      ),
                    if (course.shiftsCount > 0)
                      _MetaChip(
                        icon: Icons.schedule_rounded,
                        label: '${course.shiftsCount} shift(s)',
                        textColor: textColor,
                      ),
                    if (course.daysToStart > 0)
                      _MetaChip(
                        icon: Icons.hourglass_bottom_rounded,
                        label: '${course.daysToStart} day(s) to start',
                        textColor: textColor,
                      ),
                  ],
                ),
                if (visibleSubjects.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: visibleSubjects.map((subject) {
                      final priceLabel = subject.discountedPrice > 0
                          ? _formatPkr(subject.discountedPrice)
                          : (subject.price > 0
                                ? _formatPkr(subject.price)
                                : '');
                      final label = priceLabel.isEmpty
                          ? subject.title
                          : '${subject.title} - $priceLabel';
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? SumAcademyTheme.darkBase.withOpacityFloat(0.3)
                              : SumAcademyTheme.surfaceSecondary,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isDark
                                ? SumAcademyTheme.darkBorder
                                : SumAcademyTheme.brandBluePale,
                          ),
                        ),
                        child: Text(
                          label,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: isDark
                                    ? SumAcademyTheme.white.withOpacityFloat(
                                        0.85,
                                      )
                                    : SumAcademyTheme.brandBlue,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                if (course.coursesCount > 0) ...[
                  SizedBox(height: 12.h),
                  Text(
                    'Paid subjects: ${course.paidCourses}/${course.coursesCount}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isPartiallyEnrolled
                          ? SumAcademyTheme.brandBlue
                          : textColor.withOpacityFloat(0.6),
                      fontWeight: isPartiallyEnrolled ? FontWeight.w600 : null,
                    ),
                  ),
                ],
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isActionDisabled ? null : onEnrollClass,
                    icon: Icon(
                      isFullyEnrolled
                          ? Icons.check_circle_rounded
                          : Icons.how_to_reg_rounded,
                      size: 18.sp,
                      color: SumAcademyTheme.white,
                    ),
                    label: Text(actionLabel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: actionColor,
                      foregroundColor: SumAcademyTheme.white,
                      disabledBackgroundColor: actionColor.withOpacityFloat(
                        0.4,
                      ),
                      disabledForegroundColor: SumAcademyTheme.darkBase
                          .withOpacityFloat(0.6),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          SumAcademyTheme.radiusButton.r,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color textColor;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? SumAcademyTheme.darkBase.withOpacityFloat(0.3)
        : SumAcademyTheme.surfaceSecondary;
    final border = isDark
        ? SumAcademyTheme.darkBorder
        : SumAcademyTheme.brandBluePale;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: textColor.withOpacityFloat(0.7)),
          SizedBox(width: 6.w),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor.withOpacityFloat(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color textColor;

  const _TagChip({required this.label, required this.textColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? SumAcademyTheme.darkBase.withOpacityFloat(0.35)
        : SumAcademyTheme.brandBluePale;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isDark
              ? textColor.withOpacityFloat(0.85)
              : SumAcademyTheme.brandBlue,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String _formatPkr(double value) {
  final rounded = value.isNaN ? 0 : value.round();
  return 'PKR $rounded';
}

String _statusLabel(String status) {
  final normalized = status.trim().toLowerCase();
  if (normalized.isEmpty) return '';
  switch (normalized) {
    case 'upcoming':
      return 'Upcoming';
    case 'active':
      return 'Active';
    case 'full':
      return 'Full';
    case 'expired':
      return 'Expired';
    default:
      return status;
  }
}

Color _statusTone(String status) {
  final normalized = status.trim().toLowerCase();
  switch (normalized) {
    case 'upcoming':
      return SumAcademyTheme.warning;
    case 'full':
    case 'expired':
      return SumAcademyTheme.error;
    case 'active':
      return SumAcademyTheme.success;
    default:
      return SumAcademyTheme.brandBlue;
  }
}
