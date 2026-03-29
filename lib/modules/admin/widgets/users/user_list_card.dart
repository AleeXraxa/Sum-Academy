import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/controllers/admin_controller.dart';
import 'package:sum_academy/modules/admin/widgets/users/action_icon_button.dart';
import 'package:sum_academy/modules/admin/widgets/users/edit_user_dialog.dart';
import 'package:sum_academy/modules/admin/widgets/users/role_pill.dart';
import 'package:sum_academy/modules/admin/widgets/users/status_pill.dart';

class UserListCard extends StatelessWidget {
  final AdminUserRow user;
  final Color surface;
  final Color borderColor;
  final Color textColor;

  const UserListCard({
    super.key,
    required this.user,
    required this.surface,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final roleColor = _roleColor(user.role);
    final roleTone = roleColor.withOpacityFloat(0.14);
    final isActive = user.isActive;
    final statusColor = isActive
        ? SumAcademyTheme.success
        : SumAcademyTheme.error;
    final statusTone = isActive
        ? SumAcademyTheme.successLight
        : SumAcademyTheme.errorLight;
    final muted = textColor.withOpacityFloat(0.6);

    return Container(
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
                  color: user.avatarColor.withOpacityFloat(0.16),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  user.initials,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: user.avatarColor,
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
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
              RolePill(
                label: user.role,
                color: roleColor,
                background: roleTone,
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
              SizedBox(width: 10.w),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: isActive,
                  onChanged: (_) {},
                  activeColor: SumAcademyTheme.white,
                  activeTrackColor: SumAcademyTheme.success,
                  inactiveThumbColor: SumAcademyTheme.white,
                  inactiveTrackColor: SumAcademyTheme.brandBluePale,
                ),
              ),
              const Spacer(),
              ActionIconButton(
                icon: Icons.edit_outlined,
                color: SumAcademyTheme.brandBlue,
                onPressed: () => showEditUserDialog(
                  context,
                  name: user.name,
                  email: user.email,
                  phone: '',
                  role: user.role,
                  isActive: user.isActive,
                ),
              ),
              SizedBox(width: 8.w),
              ActionIconButton(
                icon: Icons.delete_outline_rounded,
                color: SumAcademyTheme.error,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _roleColor(String role) {
  switch (role.toLowerCase()) {
    case 'admin':
      return SumAcademyTheme.adminPurple;
    case 'teacher':
      return SumAcademyTheme.teacherBlue;
    case 'student':
      return SumAcademyTheme.studentGreen;
    default:
      return SumAcademyTheme.brandBlue;
  }
}
