import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/core/widgets/confirmation_dialog.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';
import 'package:sum_academy/modules/admin/controllers/admin_class_controller.dart';
import 'package:sum_academy/modules/admin/models/admin_class.dart';
import 'package:sum_academy/modules/admin/views/classes/admin_class_manage_view.dart';
import 'package:sum_academy/modules/admin/widgets/classes/class_form_dialog.dart';
import 'package:sum_academy/modules/admin/widgets/users/status_pill.dart';

class ClassListCard extends StatelessWidget {
  final AdminClass classItem;
  final Color surface;
  final Color borderColor;
  final Color textColor;

  const ClassListCard({
    super.key,
    required this.classItem,
    required this.surface,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final muted = textColor.withOpacityFloat(0.6);
    final statusColor = _statusColor(classItem.status);
    final statusTone = statusColor.withOpacityFloat(0.12);
    final capacity = classItem.capacity;
    final enrolled = classItem.enrolledCount;
    final progress = capacity > 0 ? enrolled / capacity : 0.0;
    final clampedProgress = progress.clamp(0.0, 1.0);
    final progressLabel = capacity > 0
        ? '${(clampedProgress * 100).round()}% full'
        : 'N/A';
    final studentsLabel = capacity > 0
        ? '$enrolled / $capacity students'
        : '$enrolled students';

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: SumAcademyTheme.darkBase.withOpacityFloat(0.05),
            blurRadius: 16.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  classItem.name.isNotEmpty ? classItem.name : 'Class',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              StatusPill(
                label: _capitalize(classItem.status.isNotEmpty
                    ? classItem.status
                    : 'Active'),
                color: statusColor,
                background: statusTone,
              ),
            ],
          ),
          if (classItem.code.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _MetaChip(label: classItem.code),
          ],
          SizedBox(height: 12.h),
          Row(
            children: [
              Text(
                studentsLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: muted,
                    ),
              ),
              const Spacer(),
              Text(
                progressLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: muted,
                    ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              minHeight: 6.h,
              value: clampedProgress,
              backgroundColor: SumAcademyTheme.brandBluePale,
              valueColor:
                  const AlwaysStoppedAnimation(SumAcademyTheme.brandBlue),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _DateTile(
                  label: 'Start',
                  value: _formatDate(classItem.startDate) ?? 'N/A',
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _DateTile(
                  label: 'End',
                  value: _formatDate(classItem.endDate) ?? 'N/A',
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _MetaChip(
                label:
                    '${classItem.courseCount} Course${classItem.courseCount == 1 ? '' : 's'}',
                background: SumAcademyTheme.surfaceTertiary,
                color: SumAcademyTheme.brandBlue,
              ),
              _MetaChip(
                label:
                    '${classItem.shiftCount} Shift${classItem.shiftCount == 1 ? '' : 's'}',
                background: SumAcademyTheme.surfaceTertiary,
                color: SumAcademyTheme.brandBlue,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _ClassAvatar(label: _buildInitials(classItem.name, classItem.code)),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _OutlineActionButton(
                  label: 'Manage',
                  onPressed: () => Get.to(
                    () => AdminClassManageView(classItem: classItem),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _OutlineActionButton(
                  label: 'Edit',
                  onPressed: () =>
                      showEditClassDialog(context, classItem: classItem),
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
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final controller = Get.find<AdminClassController>();
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Delete class',
      message: 'Are you sure you want to delete this class?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      confirmColor: SumAcademyTheme.error,
    );

    if (confirmed == true) {
      final overlayContext = Get.context ?? context;
      showLoadingDialog(overlayContext, message: 'Deleting class...');
      late final result;
      try {
        result = await controller.deleteClass(classItem.id);
      } finally {
        if (Navigator.of(overlayContext, rootNavigator: true).canPop()) {
          Navigator.of(overlayContext, rootNavigator: true).pop();
        }
      }
      if (result.isSuccess) {
        await showSuccessDialog(
          overlayContext,
          title: 'Class Deleted',
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
}

class _MetaChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color color;

  const _MetaChip({
    required this.label,
    this.background = SumAcademyTheme.brandBluePale,
    this.color = SumAcademyTheme.brandBlue,
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
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final String value;

  const _DateTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: SumAcademyTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: SumAcademyTheme.darkBase,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _ClassAvatar extends StatelessWidget {
  final String label;

  const _ClassAvatar({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36.r,
      height: 36.r,
      decoration: BoxDecoration(
        color: SumAcademyTheme.brandBluePale,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: SumAcademyTheme.brandBlue,
              fontWeight: FontWeight.w700,
            ),
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

Color _statusColor(String status) {
  final normalized = status.toLowerCase();
  if (normalized.contains('active') || normalized.contains('publish')) {
    return SumAcademyTheme.success;
  }
  if (normalized.contains('inactive') || normalized.contains('arch')) {
    return SumAcademyTheme.error;
  }
  if (normalized.contains('upcoming')) {
    return SumAcademyTheme.info;
  }
  return SumAcademyTheme.warning;
}

String _capitalize(String text) {
  if (text.isEmpty) return text;
  return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
}

String _buildInitials(String name, String code) {
  final source = name.isNotEmpty ? name : code;
  final parts = source.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return 'CL';
  if (parts.length == 1) {
    final word = parts.first;
    return (word.length >= 2 ? word.substring(0, 2) : word).toUpperCase();
  }
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}

String? _formatDate(DateTime? date) {
  if (date == null) return null;
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
  return '${date.day.toString().padLeft(2, '0')}-$month-${date.year}';
}
