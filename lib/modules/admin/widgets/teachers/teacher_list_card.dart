import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/core/widgets/confirmation_dialog.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';
import 'package:sum_academy/modules/admin/controllers/admin_teacher_controller.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_ui.dart';
import 'package:sum_academy/modules/admin/widgets/teachers/edit_teacher_dialog.dart';
import 'package:sum_academy/modules/admin/widgets/teachers/teacher_profile_dialog.dart';
import 'package:sum_academy/modules/admin/widgets/users/action_icon_button.dart';
import 'package:sum_academy/modules/admin/widgets/users/role_pill.dart';
import 'package:sum_academy/modules/admin/widgets/users/status_pill.dart';

class TeacherListCard extends StatelessWidget {
  final AdminTeacherRow teacher;
  final Color surface;
  final Color borderColor;
  final Color textColor;

  const TeacherListCard({
    super.key,
    required this.teacher,
    required this.surface,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final subjectColor = SumAcademyTheme.teacherBlue;
    final subjectTone = subjectColor.withOpacityFloat(0.14);
    final isActive = teacher.isActive;
    final statusColor =
        isActive ? SumAcademyTheme.success : SumAcademyTheme.error;
    final statusTone =
        isActive ? SumAcademyTheme.successLight : SumAcademyTheme.errorLight;
    final muted = textColor.withOpacityFloat(0.6);
    final controller = Get.find<AdminTeacherController>();
    final isSelf = controller.isCurrentUser(teacher.uid);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AdminUi.cardRadius(),
        onTap: () => showTeacherProfileDialog(
          context,
          teacher: teacher,
        ),
        child: Container(
          padding: EdgeInsets.all(14.r),
          decoration: AdminUi.cardDecoration(
            surface: surface,
            border: borderColor,
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50.r,
                    height: 50.r,
                    decoration: BoxDecoration(
                      color: teacher.avatarColor.withOpacityFloat(0.16),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      teacher.initials,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: teacher.avatarColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teacher.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          teacher.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: muted),
                        ),
                      ],
                    ),
                  ),
                  RolePill(
                    label: teacher.subject.isNotEmpty
                        ? teacher.subject
                        : 'Subject',
                    color: subjectColor,
                    background: subjectTone,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  StatusPill(
                    label: isActive ? 'Active' : 'Inactive',
                    color: statusColor,
                    background: statusTone,
                  ),
                  const Spacer(),
                  ActionIconButton(
                    icon: Icons.edit_outlined,
                    color: SumAcademyTheme.brandBlue,
                    onPressed: () => showEditTeacherDialog(
                      context,
                      uid: teacher.uid,
                      name: teacher.name,
                      email: teacher.email,
                      phone: teacher.phone,
                      isActive: teacher.isActive,
                      subject: teacher.subject,
                      bio: teacher.bio,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ActionIconButton(
                    icon: Icons.delete_outline_rounded,
                    color: SumAcademyTheme.error,
                    onPressed: () => _confirmDelete(context, isSelf),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, bool isSelf) async {
    final controller = Get.find<AdminTeacherController>();
    if (isSelf) {
      await showErrorDialog(
        context,
        title: 'Not allowed',
        message: 'You cannot delete your own account.',
      );
      return;
    }
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Delete teacher',
      message: 'Are you sure you want to delete this teacher?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      confirmColor: SumAcademyTheme.error,
    );

    if (confirmed == true) {
      final overlayContext = Get.context ?? context;
      showLoadingDialog(overlayContext, message: 'Deleting teacher...');
      late final result;
      try {
        result = await controller.deleteTeacher(teacher.uid);
      } finally {
        if (Navigator.of(overlayContext, rootNavigator: true).canPop()) {
          Navigator.of(overlayContext, rootNavigator: true).pop();
        }
      }

      if (result.isSuccess) {
        await showSuccessDialog(
          overlayContext,
          title: 'Teacher Deleted',
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
