import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/core/widgets/confirmation_dialog.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';
import 'package:sum_academy/modules/admin/controllers/admin_course_controller.dart';
import 'package:sum_academy/modules/admin/models/admin_course.dart';
import 'package:sum_academy/modules/admin/views/courses/admin_course_content_view.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_ui.dart';
import 'package:sum_academy/modules/admin/widgets/courses/course_form_dialog.dart';
import 'package:sum_academy/modules/admin/widgets/users/role_pill.dart';

class CourseListCard extends StatelessWidget {
  final AdminCourse course;
  final Color surface;
  final Color borderColor;
  final Color textColor;

  const CourseListCard({
    super.key,
    required this.course,
    required this.surface,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final muted = textColor.withOpacityFloat(0.6);
    final statusColor = _statusColor(course.status, isArchived: course.isArchived);
    final statusTone = statusColor.withOpacityFloat(0.12);
    final discounted = _discountedPrice(course.price, course.discount);
    final subjectLabel =
        '${course.subjectCount} Subject${course.subjectCount == 1 ? '' : 's'}';
    final teacherLabel =
        '${course.teacherCount} Teacher${course.teacherCount == 1 ? '' : 's'}';
    final enrolledLabel =
        '${course.enrolledCount} Enrolled';

    return Container(
      decoration: AdminUi.cardDecoration(
        surface: surface,
        border: borderColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AdminUi.cardRadiusR())),
            child: Container(
              height: 92.h,
              width: double.infinity,
              padding: EdgeInsets.all(12.r),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE8F0FF),
                    Color(0xFFDCE8FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              alignment: Alignment.topRight,
              child: RolePill(
                label: course.isArchived
                    ? 'Archived'
                    : course.status.isNotEmpty
                        ? _capitalize(course.status)
                        : 'Draft',
                color: statusColor,
                background: statusTone,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title.isNotEmpty ? course.title : 'Untitled course',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _CourseTag(
                      label:
                          course.category.isNotEmpty ? course.category : 'Category',
                    ),
                    _CourseTag(
                      label: subjectLabel,
                    ),
                    _CourseTag(
                      label: teacherLabel,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Text(
                      enrolledLabel,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: muted),
                    ),
                    const Spacer(),
                    Text(
                      course.level.isNotEmpty ? course.level : 'Level',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: muted),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Text(
                      _formatPrice(discounted),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: SumAcademyTheme.brandBlue,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    if (course.discount > 0) ...[
                      SizedBox(width: 8.w),
                      Text(
                        _formatPrice(course.price),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: muted,
                              decoration: TextDecoration.lineThrough,
                            ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: _OutlineActionButton(
                        label: 'Edit',
                        onPressed: () =>
                            showEditCourseDialog(context, course: course),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _OutlineActionButton(
                        label: 'Manage Content',
                        onPressed: () => Get.to(
                          () => AdminCourseContentView(course: course),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: _OutlineActionButton(
                        label: course.isArchived ? 'Publish' : 'Archive',
                        color: course.isArchived
                            ? SumAcademyTheme.success
                            : SumAcademyTheme.darkBase,
                        borderColor: course.isArchived
                            ? SumAcademyTheme.success.withOpacityFloat(0.4)
                            : SumAcademyTheme.brandBluePale,
                        onPressed: () => course.isArchived
                            ? _confirmPublish(context)
                            : _confirmArchive(context),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _OutlineActionButton(
                        label: 'Delete',
                        color: SumAcademyTheme.error,
                        borderColor: SumAcademyTheme.error.withOpacityFloat(0.4),
                        onPressed: () => _confirmDelete(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final controller = Get.find<AdminCourseController>();
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Delete course',
      message: 'Are you sure you want to delete this course?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      confirmColor: SumAcademyTheme.error,
    );

    if (confirmed == true) {
      final overlayContext = Get.context ?? context;
      showLoadingDialog(overlayContext, message: 'Deleting course...');
      late final result;
      try {
        result = await controller.deleteCourse(course.id);
      } finally {
        if (Navigator.of(overlayContext, rootNavigator: true).canPop()) {
          Navigator.of(overlayContext, rootNavigator: true).pop();
        }
      }
      if (result.isSuccess) {
        await showSuccessDialog(
          overlayContext,
          title: 'Course Deleted',
          message: result.message,
        );
      } else {
        if (result.isNetworkError) {
          await showNoInternetDialogOnce(message: result.message);
          return;
        }
        await showErrorDialog(
          overlayContext,
          title: 'Delete Failed',
          message: result.message,
        );
      }
    }
  }

  Future<void> _confirmArchive(BuildContext context) async {
    final controller = Get.find<AdminCourseController>();
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Archive course',
      message: 'Archived courses are hidden from learners.',
      confirmText: 'Archive',
      cancelText: 'Cancel',
      confirmColor: SumAcademyTheme.warning,
    );

    if (confirmed == true) {
      final overlayContext = Get.context ?? context;
      showLoadingDialog(overlayContext, message: 'Archiving course...');
      late final result;
      try {
        result = await controller.archiveCourse(course.id);
      } finally {
        if (Navigator.of(overlayContext, rootNavigator: true).canPop()) {
          Navigator.of(overlayContext, rootNavigator: true).pop();
        }
      }
      if (result.isSuccess) {
        await showSuccessDialog(
          overlayContext,
          title: 'Course Archived',
          message: result.message,
        );
      } else {
        if (result.isNetworkError) {
          await showNoInternetDialogOnce(message: result.message);
          return;
        }
        await showErrorDialog(
          overlayContext,
          title: 'Archive Failed',
          message: result.message,
        );
      }
    }
  }

  Future<void> _confirmPublish(BuildContext context) async {
    final controller = Get.find<AdminCourseController>();
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Publish course',
      message: 'This course will be visible to learners.',
      confirmText: 'Publish',
      cancelText: 'Cancel',
      confirmColor: SumAcademyTheme.success,
    );

    if (confirmed == true) {
      final overlayContext = Get.context ?? context;
      showLoadingDialog(overlayContext, message: 'Publishing course...');
      late final result;
      try {
        result = await controller.publishCourse(course.id);
      } finally {
        if (Navigator.of(overlayContext, rootNavigator: true).canPop()) {
          Navigator.of(overlayContext, rootNavigator: true).pop();
        }
      }
      if (result.isSuccess) {
        await showSuccessDialog(
          overlayContext,
          title: 'Course Published',
          message: result.message,
        );
      } else {
        if (result.isNetworkError) {
          await showNoInternetDialogOnce(message: result.message);
          return;
        }
        await showErrorDialog(
          overlayContext,
          title: 'Publish Failed',
          message: result.message,
        );
      }
    }
  }
}

class _CourseTag extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _CourseTag({
    required this.label,
    this.color = SumAcademyTheme.brandBlue,
    this.background = SumAcademyTheme.brandBluePale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusPill.r),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final Color borderColor;

  const _OutlineActionButton({
    required this.label,
    required this.onPressed,
    this.color = SumAcademyTheme.darkBase,
    Color? borderColor,
  }) : borderColor = borderColor ?? SumAcademyTheme.brandBluePale;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: borderColor),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      child: Text(label, textAlign: TextAlign.center),
    );
  }
}

Color _statusColor(String status, {bool isArchived = false}) {
  if (isArchived) {
    return SumAcademyTheme.error;
  }
  final normalized = status.toLowerCase();
  if (normalized.contains('publish') || normalized.contains('active')) {
    return SumAcademyTheme.success;
  }
  if (normalized.contains('arch') || normalized.contains('inactive')) {
    return SumAcademyTheme.error;
  }
  return SumAcademyTheme.warning;
}

String _capitalize(String text) {
  if (text.isEmpty) return text;
  return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
}

double _discountedPrice(double price, double discount) {
  if (price <= 0 || discount <= 0) return price;
  return price - (price * (discount / 100));
}

String _formatPrice(double value) {
  final fixed = value.toStringAsFixed(0);
  return 'PKR $fixed';
}
