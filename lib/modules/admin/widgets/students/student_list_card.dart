import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/widgets/confirmation_dialog.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';
import 'package:sum_academy/modules/admin/controllers/admin_student_controller.dart';
import 'package:sum_academy/modules/admin/widgets/students/student_profile_dialog.dart';
import 'package:sum_academy/modules/admin/widgets/students/edit_student_dialog.dart';
import 'package:sum_academy/modules/admin/widgets/users/action_icon_button.dart';
import 'package:sum_academy/modules/admin/widgets/users/status_pill.dart';

class StudentListCard extends StatelessWidget {
  final AdminStudentRow student;
  final Color surface;
  final Color borderColor;
  final Color textColor;

  const StudentListCard({
    super.key,
    required this.student,
    required this.surface,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = student.isActive;
    final statusColor =
        isActive ? SumAcademyTheme.success : SumAcademyTheme.error;
    final statusTone =
        isActive ? SumAcademyTheme.successLight : SumAcademyTheme.errorLight;
    final muted = textColor.withOpacityFloat(0.6);
    final controller = Get.find<AdminStudentController>();
    final isSelf = controller.isCurrentUser(student.uid);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: () => showStudentProfileDialog(
          context,
          student: student,
        ),
        child: Container(
          padding: EdgeInsets.all(14.r),
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
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50.r,
                    height: 50.r,
                    decoration: BoxDecoration(
                      color: student.avatarColor.withOpacityFloat(0.16),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      student.initials,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: student.avatarColor,
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
                          student.name,
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
                          student.email,
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
                    onPressed: () => showEditStudentDialog(
                      context,
                      uid: student.uid,
                      name: student.name,
                      email: student.email,
                      phone: student.phone,
                      isActive: student.isActive,
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
    final controller = Get.find<AdminStudentController>();
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
      title: 'Delete student',
      message: 'Are you sure you want to delete this student?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      confirmColor: SumAcademyTheme.error,
    );

    if (confirmed == true) {
      final overlayContext = Get.context ?? context;
      showLoadingDialog(overlayContext, message: 'Deleting student...');
      late final result;
      try {
        result = await controller.deleteStudent(student.uid);
      } finally {
        if (Navigator.of(overlayContext, rootNavigator: true).canPop()) {
          Navigator.of(overlayContext, rootNavigator: true).pop();
        }
      }

      if (result.isSuccess) {
        await showSuccessDialog(
          overlayContext,
          title: 'Student Deleted',
          message: result.message,
        );
      } else {
        if (result.isNetworkError) {
          await showNoInternetDialog(
            overlayContext,
            message: result.message,
          );
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
