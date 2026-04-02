import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';
import 'package:sum_academy/modules/admin/controllers/admin_controller.dart';
import 'package:sum_academy/modules/admin/controllers/admin_teacher_controller.dart';
import 'package:sum_academy/modules/admin/models/teacher_profile.dart';
import 'package:sum_academy/modules/admin/services/teacher_profile_service.dart';
import 'package:sum_academy/modules/admin/widgets/users/role_pill.dart';
import 'package:sum_academy/modules/admin/widgets/users/status_pill.dart';

Future<void> showTeacherProfileDialog(
  BuildContext context, {
  required AdminTeacherRow teacher,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (context) => TeacherProfileDialog(teacher: teacher),
  );
}

class TeacherProfileDialog extends StatefulWidget {
  final AdminTeacherRow teacher;

  const TeacherProfileDialog({super.key, required this.teacher});

  @override
  State<TeacherProfileDialog> createState() => _TeacherProfileDialogState();
}

class _TeacherProfileDialogState extends State<TeacherProfileDialog> {
  Future<TeacherProfileData>? _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    _profileFuture = Get.find<TeacherProfileService>()
        .fetchTeacherProfile(widget.teacher.uid);
  }

  @override
  Widget build(BuildContext context) {
    final muted = SumAcademyTheme.darkBase.withOpacityFloat(0.6);
    final lightBorder = SumAcademyTheme.brandBluePale;

    return Dialog(
      backgroundColor: SumAcademyTheme.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: FutureBuilder<TeacherProfileData>(
        future: _profileFuture,
        builder: (context, snapshot) {
          final loading = snapshot.connectionState == ConnectionState.waiting;
          final data = snapshot.data;
          final hasError = snapshot.hasError;
          final errorMessage =
              hasError ? _formatError(snapshot.error.toString()) : '';

          final profile = data?.profile;
          final name = profile?.fullName.isNotEmpty == true
              ? profile!.fullName
              : widget.teacher.name;
          final email = profile?.email.isNotEmpty == true
              ? profile!.email
              : widget.teacher.email;
          final phone = profile?.phone.isNotEmpty == true
              ? profile!.phone
              : widget.teacher.phone;

          final subject = data?.subject.isNotEmpty == true
              ? data!.subject
              : widget.teacher.subject;
          final bio =
              data?.bio.isNotEmpty == true ? data!.bio : widget.teacher.bio;

          final assignedWebDevice =
              profile?.assignedWebDevice.isNotEmpty == true
                  ? profile!.assignedWebDevice
                  : 'N/A';
          final assignedWebIp = profile?.assignedWebIp.isNotEmpty == true
              ? profile!.assignedWebIp
              : 'N/A';
          final assignedMobileDevice =
              profile?.assignedMobileDevice.isNotEmpty == true
                  ? profile!.assignedMobileDevice
                  : 'N/A';
          final assignedMobileIp =
              profile?.assignedMobileIp.isNotEmpty == true
                  ? profile!.assignedMobileIp
                  : 'N/A';

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Teacher Profile',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                if (loading) ...[
                  SizedBox(height: 12.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: LinearProgressIndicator(
                      minHeight: 6.h,
                      backgroundColor: SumAcademyTheme.brandBluePale,
                      valueColor: const AlwaysStoppedAnimation(
                        SumAcademyTheme.brandBlue,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 18.h),
                if (hasError) ...[
                  _ErrorCard(
                    message: errorMessage,
                    showRetry: !_isAccessDenied(errorMessage),
                    onRetry: () => setState(_loadProfile),
                  ),
                  SizedBox(height: 12.h),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Avatar(
                      initials: widget.teacher.initials,
                      color: widget.teacher.avatarColor,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: SumAcademyTheme.darkBase,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            email,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: muted),
                          ),
                          if (phone.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              phone,
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
                                label: 'Teacher',
                                color: SumAcademyTheme.teacherBlue,
                                background: SumAcademyTheme.teacherBlue
                                    .withOpacityFloat(0.12),
                              ),
                              SizedBox(width: 8.w),
                              StatusPill(
                                label: widget.teacher.isActive
                                    ? 'Active'
                                    : 'Inactive',
                                color: widget.teacher.isActive
                                    ? SumAcademyTheme.success
                                    : SumAcademyTheme.error,
                                background: widget.teacher.isActive
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
                    _InfoRow(
                      label: 'Subject',
                      value: subject.isNotEmpty ? subject : 'N/A',
                    ),
                    _InfoRow(
                      label: 'Bio',
                      value: bio.isNotEmpty ? bio : 'N/A',
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                _SectionTitle(title: 'Account Security'),
                SizedBox(height: 12.h),
                _SecurityCard(
                  borderColor: lightBorder,
                  assignedWebDevice: assignedWebDevice,
                  assignedWebIp: assignedWebIp,
                  assignedMobileDevice: assignedMobileDevice,
                  assignedMobileIp: assignedMobileIp,
                  onReset: () => _resetDevice(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _resetDevice(BuildContext context) async {
    final overlayContext = context;
    showLoadingDialog(overlayContext, message: 'Resetting device...');
    try {
      await Get.find<AdminController>().resetUserDevice(widget.teacher.uid);
      await showSuccessDialog(
        overlayContext,
        title: 'Device Reset',
        message: 'Device has been reset successfully.',
      );
      if (mounted) {
        setState(_loadProfile);
      }
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
                    Expanded(
                      child: Text(
                        item.value,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: SumAcademyTheme.darkBase,
                              fontWeight: FontWeight.w600,
                            ),
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
  final String assignedWebDevice;
  final String assignedWebIp;
  final String assignedMobileDevice;
  final String assignedMobileIp;
  final VoidCallback onReset;

  const _SecurityCard({
    required this.borderColor,
    required this.assignedWebDevice,
    required this.assignedWebIp,
    required this.assignedMobileDevice,
    required this.assignedMobileIp,
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
          _SecurityRow(label: 'Assigned Web Device', value: assignedWebDevice),
          SizedBox(height: 6.h),
          _SecurityRow(label: 'Assigned Web IP', value: assignedWebIp),
          SizedBox(height: 6.h),
          _SecurityRow(
            label: 'Assigned Mobile Device',
            value: assignedMobileDevice,
          ),
          SizedBox(height: 6.h),
          _SecurityRow(label: 'Assigned Mobile IP', value: assignedMobileIp),
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

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool showRetry;

  const _ErrorCard({
    required this.message,
    required this.onRetry,
    required this.showRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.errorLight.withOpacityFloat(0.4),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: SumAcademyTheme.error.withOpacityFloat(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Failed to load teacher profile.',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: SumAcademyTheme.error,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 6.h),
          Text(
            message.isNotEmpty ? message : 'Please try again.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                ),
          ),
          SizedBox(height: 12.h),
          if (showRetry)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ),
        ],
      ),
    );
  }
}

String _formatError(String raw) {
  if (raw.isEmpty) return 'Please try again.';
  return raw.replaceAll('ApiException: ', '').trim();
}

bool _isAccessDenied(String message) {
  final lower = message.toLowerCase();
  return lower.contains('access denied') || lower.contains('forbidden');
}
