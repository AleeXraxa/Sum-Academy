import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';
import 'package:sum_academy/modules/admin/controllers/admin_controller.dart';
import 'package:sum_academy/modules/admin/widgets/users/role_pill.dart';
import 'package:sum_academy/modules/admin/widgets/users/status_pill.dart';

Future<void> showUserProfileDialog(
  BuildContext context, {
  required AdminUserRow user,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (context) => UserProfileDialog(user: user),
  );
}

class UserProfileDialog extends StatelessWidget {
  final AdminUserRow user;

  const UserProfileDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final muted = SumAcademyTheme.darkBase.withOpacityFloat(0.6);
    final lightBorder = SumAcademyTheme.brandBluePale;
    final roleLabel = _roleLabel(user.role);

    return Dialog(
      backgroundColor: SumAcademyTheme.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$roleLabel Profile',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: SumAcademyTheme.darkBase,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                _DialogIconButton(
                  icon: Icons.close_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(initials: user.initials, color: user.avatarColor),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: SumAcademyTheme.darkBase,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        user.email,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: muted),
                      ),
                      if (user.phone.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          user.phone,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: muted),
                        ),
                      ],
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          RolePill(
                            label: roleLabel,
                            color: _roleColor(user.role),
                            background:
                                _roleColor(user.role).withOpacityFloat(0.12),
                          ),
                          SizedBox(width: 8.w),
                          StatusPill(
                            label: user.isActive ? 'Active' : 'Inactive',
                            color: user.isActive
                                ? SumAcademyTheme.success
                                : SumAcademyTheme.error,
                            background: user.isActive
                                ? SumAcademyTheme.successLight
                                : SumAcademyTheme.errorLight,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _InfoCard(
              borderColor: lightBorder,
              items: [
                _InfoRow(label: 'Joined Date', value: 'N/A'),
                _InfoRow(label: 'Last Login', value: 'Never'),
                _InfoRow(label: 'Device', value: 'N/A'),
              ],
            ),
            SizedBox(height: 18.h),
            _SectionTitle(title: 'Account Security'),
            SizedBox(height: 12.h),
            _SecurityCard(
              borderColor: lightBorder,
              onReset: () => _resetDevice(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetDevice(BuildContext context) async {
    final overlayContext = context;
    showLoadingDialog(overlayContext, message: 'Resetting device...');
    try {
      await Get.find<AdminController>().resetUserDevice(user.uid);
      await showSuccessDialog(
        overlayContext,
        title: 'Device Reset',
        message: 'Device has been reset successfully.',
      );
    } finally {
      if (Navigator.of(overlayContext, rootNavigator: true).canPop()) {
        Navigator.of(overlayContext, rootNavigator: true).pop();
      }
    }
  }
}

class _DialogIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _DialogIconButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.r,
      height: 40.r,
      decoration: BoxDecoration(
        color: SumAcademyTheme.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20.sp, color: SumAcademyTheme.darkBase),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  final Color color;

  const _Avatar({required this.initials, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56.r,
      height: 56.r,
      decoration: BoxDecoration(
        color: color.withOpacityFloat(0.18),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Color borderColor;
  final List<_InfoRow> items;

  const _InfoCard({required this.borderColor, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.label,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: SumAcademyTheme.darkBase
                                      .withOpacityFloat(0.65),
                                ),
                      ),
                    ),
                    Text(
                      item.value,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: SumAcademyTheme.darkBase,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: SumAcademyTheme.darkBase.withOpacityFloat(0.5),
            letterSpacing: 1.8,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _SecurityCard extends StatelessWidget {
  final Color borderColor;
  final VoidCallback onReset;

  const _SecurityCard({
    required this.borderColor,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SecurityRow(label: 'Assigned Web Device', value: 'N/A'),
          SizedBox(height: 6.h),
          _SecurityRow(label: 'Assigned Web IP', value: 'N/A'),
          SizedBox(height: 12.h),
          ElevatedButton(
            onPressed: onReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: SumAcademyTheme.brandBlue,
              foregroundColor: SumAcademyTheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  SumAcademyTheme.radiusButton.r,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
            ),
            child: const Text('Reset Device'),
          ),
        ],
      ),
    );
  }
}

class _SecurityRow extends StatelessWidget {
  final String label;
  final String value;

  const _SecurityRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: SumAcademyTheme.darkBase,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

String _roleLabel(String role) {
  if (role.trim().isEmpty) return 'User';
  return '${role[0].toUpperCase()}${role.substring(1).toLowerCase()}';
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
