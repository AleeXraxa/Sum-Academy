import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';
import 'package:sum_academy/modules/admin/models/admin_class.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_ui.dart';
import 'package:sum_academy/modules/admin/widgets/users/role_pill.dart';

class AdminClassManageView extends StatelessWidget {
  final AdminClass classItem;

  const AdminClassManageView({super.key, required this.classItem});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(classItem.status);
    final statusTone = statusColor.withOpacityFloat(0.12);

    return Scaffold(
      backgroundColor: SumAcademyTheme.surfaceSecondary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AdminUi.pagePadding(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Back'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SumAcademyTheme.darkBase,
                      side: const BorderSide(color: SumAcademyTheme.brandBluePale),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MANAGE CLASS',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: SumAcademyTheme.darkBase
                                    .withOpacityFloat(0.55),
                                letterSpacing: 2.6,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          classItem.name.isNotEmpty ? classItem.name : 'Class',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: SumAcademyTheme.darkBase,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                  RolePill(
                    label: _capitalize(
                      classItem.status.isNotEmpty ? classItem.status : 'Active',
                    ),
                    color: statusColor,
                    background: statusTone,
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              _ManageSectionCard(
                title: 'Courses',
                subtitle: '${classItem.courseCount} courses assigned',
                actionLabel: 'Add Course',
                emptyText: 'No courses assigned yet.',
                onTap: () => _showComingSoon(context),
              ),
              SizedBox(height: 12.h),
              _ManageSectionCard(
                title: 'Shifts',
                subtitle: '${classItem.shiftCount} shifts scheduled',
                actionLabel: 'Add Shift',
                emptyText: 'No shifts scheduled yet.',
                onTap: () => _showComingSoon(context),
              ),
              SizedBox(height: 12.h),
              _ManageSectionCard(
                title: 'Students',
                subtitle: '${classItem.enrolledCount} students enrolled',
                actionLabel: 'Enroll Student',
                emptyText: 'No students enrolled yet.',
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showComingSoon(BuildContext context) {
    return showErrorDialog(
      context,
      title: 'Coming Soon',
      message: 'This section will be available soon.',
    );
  }
}

class _ManageSectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionLabel;
  final String emptyText;
  final VoidCallback onTap;

  const _ManageSectionCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.emptyText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = AdminUi.borderColor(context);
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: AdminUi.cardDecoration(
        surface: SumAcademyTheme.white,
        border: borderColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: SumAcademyTheme.darkBase,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: SumAcademyTheme.darkBase
                                .withOpacityFloat(0.6),
                          ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: SumAcademyTheme.darkBase,
                  side: const BorderSide(color: SumAcademyTheme.brandBluePale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                ),
                child: Text(actionLabel),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            emptyText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.55),
                ),
          ),
        ],
      ),
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
