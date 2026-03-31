import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/controllers/admin_controller.dart';
import 'package:sum_academy/modules/admin/controllers/admin_student_controller.dart';
import 'package:sum_academy/modules/admin/models/student_profile.dart';
import 'package:sum_academy/modules/admin/services/student_profile_service.dart';
import 'package:sum_academy/modules/admin/widgets/users/role_pill.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';

Future<void> showStudentProfileDialog(
  BuildContext context, {
  required AdminStudentRow student,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (context) => StudentProfileDialog(student: student),
  );
}

class StudentProfileDialog extends StatefulWidget {
  final AdminStudentRow student;

  const StudentProfileDialog({super.key, required this.student});

  @override
  State<StudentProfileDialog> createState() => _StudentProfileDialogState();
}

class _StudentProfileDialogState extends State<StudentProfileDialog> {
  Future<StudentProfileData>? _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    _profileFuture = Get.find<StudentProfileService>()
        .fetchStudentProfile(widget.student.uid);
  }

  @override
  Widget build(BuildContext context) {
    final muted = SumAcademyTheme.darkBase.withOpacityFloat(0.6);
    final lightBorder = SumAcademyTheme.brandBluePale;

    return Dialog(
      backgroundColor: SumAcademyTheme.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: FutureBuilder<StudentProfileData>(
        future: _profileFuture,
        builder: (context, snapshot) {
          final loading = snapshot.connectionState == ConnectionState.waiting;
          final data = snapshot.data;
          final hasError = snapshot.hasError;
          final errorMessage =
              hasError ? _formatError(snapshot.error.toString()) : '';
          final profile = data?.profile;
          final progress = data?.progress;

          final name = profile?.fullName.isNotEmpty == true
              ? profile!.fullName
              : widget.student.name;
          final email = profile?.email.isNotEmpty == true
              ? profile!.email
              : widget.student.email;
          final phone = profile?.phone.isNotEmpty == true
              ? profile!.phone
              : widget.student.phone;

          final joinedLabel = _formatDate(profile?.joinedAt) ?? 'N/A';
          final lastLoginLabel = _formatDate(profile?.lastLoginAt) ?? 'Never';
          final deviceLabel =
              profile?.device.isNotEmpty == true ? profile!.device : 'N/A';

          final enrolledCount = progress?.enrolledCourses ?? 0;
          final certificatesCount = progress?.certificates ?? 0;
          final completedCount = progress?.completedCourses ?? 0;
          final avgProgress = _formatPercent(progress?.avgProgress ?? 0);

          final courses = progress?.courses ?? const <StudentCourseProgress>[];
          final certs =
              progress?.certificatesList ?? const <StudentCertificate>[];

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Student Profile',
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
                if (hasError) ...[
                  SizedBox(height: 12.h),
                  _ErrorCard(
                    message: errorMessage,
                    showRetry: !_isAccessDenied(errorMessage),
                    onRetry: () {
                      setState(_loadProfile);
                    },
                  ),
                ],
                SizedBox(height: 18.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Avatar(
                      initials: widget.student.initials,
                      color: widget.student.avatarColor,
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
                          RolePill(
                            label: 'Student',
                            color: SumAcademyTheme.studentGreen,
                            background: SumAcademyTheme.studentGreen
                                .withOpacityFloat(0.12),
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
                    _InfoRow(label: 'Joined Date', value: joinedLabel),
                    _InfoRow(label: 'Last Login', value: lastLoginLabel),
                    _InfoRow(label: 'Device', value: deviceLabel),
                  ],
                ),
                SizedBox(height: 18.h),
                _SectionTitle(title: 'Academic Info'),
                SizedBox(height: 12.h),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 520;
                    final spacing = 12.w;
                    final itemWidth = isWide
                        ? (constraints.maxWidth - spacing) / 2
                        : constraints.maxWidth;
                    return Wrap(
                      spacing: spacing,
                      runSpacing: 12.h,
                      children: [
                        _StatChip(
                          width: itemWidth,
                          label: 'Enrolled Courses',
                          value: enrolledCount.toString(),
                          tone: SumAcademyTheme.brandBluePale,
                          valueColor: SumAcademyTheme.brandBlue,
                        ),
                        _StatChip(
                          width: itemWidth,
                          label: 'Certificates Earned',
                          value: certificatesCount.toString(),
                          tone: SumAcademyTheme.surfaceTertiary,
                          valueColor: SumAcademyTheme.adminPurple,
                        ),
                        _StatChip(
                          width: itemWidth,
                          label: 'Avg Progress',
                          value: avgProgress,
                          tone: SumAcademyTheme.successLight,
                          valueColor: SumAcademyTheme.success,
                        ),
                        _StatChip(
                          width: itemWidth,
                          label: 'Completed Courses',
                          value: completedCount.toString(),
                          tone: SumAcademyTheme.accentOrangePale,
                          valueColor: SumAcademyTheme.accentOrange,
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 18.h),
                _SectionTitle(title: 'Enrolled Courses'),
                SizedBox(height: 12.h),
                if (courses.isEmpty)
                  _EmptySectionCard(
                    borderColor: lightBorder,
                    message: 'No enrolled courses yet.',
                  )
                else
                  Column(
                    children: courses
                        .map(
                          (course) => Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: _CourseCard(
                              borderColor: lightBorder,
                              course: course,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                SizedBox(height: 18.h),
                _SectionTitle(title: 'Certificates'),
                SizedBox(height: 12.h),
                if (certs.isEmpty)
                  _EmptySectionCard(
                    borderColor: lightBorder,
                    message: 'No certificates earned yet.',
                  )
                else
                  Column(
                    children: certs
                        .map(
                          (cert) => Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: _CertificateCard(
                              borderColor: lightBorder,
                              certificate: cert,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                SizedBox(height: 18.h),
                _SectionTitle(title: 'Account Security'),
                SizedBox(height: 12.h),
                _SecurityCard(
                  borderColor: lightBorder,
                  assignedWebDevice: profile?.assignedWebDevice ?? '',
                  assignedWebIp: profile?.assignedWebIp ?? '',
                  onReset: () async {
                    final overlayContext = context;
                    showLoadingDialog(
                      overlayContext,
                      message: 'Resetting device...',
                    );
                    try {
                      await Get.find<AdminController>()
                          .resetUserDevice(widget.student.uid);
                      await showSuccessDialog(
                        overlayContext,
                        title: 'Device Reset',
                        message: 'Device has been reset successfully.',
                      );
                      if (mounted) {
                        setState(_loadProfile);
                      }
                    } finally {
                      if (Navigator.of(overlayContext, rootNavigator: true)
                          .canPop()) {
                        Navigator.of(overlayContext, rootNavigator: true).pop();
                      }
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
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

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color tone;
  final Color valueColor;
  final double width;

  const _StatChip({
    required this.label,
    required this.value,
    required this.tone,
    required this.valueColor,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: tone,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: tone.withOpacityFloat(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Color borderColor;
  final StudentCourseProgress course;

  const _CourseCard({
    required this.borderColor,
    required this.course,
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
          Row(
            children: [
              Expanded(
                child: Text(
                  course.title.isNotEmpty ? course.title : 'Course',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: SumAcademyTheme.darkBase,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Text(
                course.progressLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                    ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            'Enrollment date: ${_formatDate(course.enrolledAt) ?? 'N/A'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.5),
                ),
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              minHeight: 6.h,
              value: course.progressValue,
              backgroundColor: SumAcademyTheme.brandBluePale,
              valueColor: const AlwaysStoppedAnimation(
                SumAcademyTheme.brandBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  final Color borderColor;
  final StudentCertificate certificate;

  const _CertificateCard({
    required this.borderColor,
    required this.certificate,
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
          Text(
            'Cert ID: ${certificate.id.isNotEmpty ? certificate.id : 'N/A'}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: SumAcademyTheme.darkBase,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Course: ${certificate.courseName.isNotEmpty ? certificate.courseName : 'N/A'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.65),
                ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Issued: ${_formatDate(certificate.issuedAt) ?? 'N/A'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.5),
                ),
          ),
        ],
      ),
    );
  }
}

class _SecurityCard extends StatelessWidget {
  final Color borderColor;
  final String assignedWebDevice;
  final String assignedWebIp;
  final VoidCallback onReset;

  const _SecurityCard({
    required this.borderColor,
    required this.assignedWebDevice,
    required this.assignedWebIp,
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
          _SecurityRow(
            label: 'Assigned Web Device',
            value: assignedWebDevice.isNotEmpty ? assignedWebDevice : 'N/A',
          ),
          SizedBox(height: 6.h),
          _SecurityRow(
            label: 'Assigned Web IP',
            value: assignedWebIp.isNotEmpty ? assignedWebIp : 'N/A',
          ),
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

class _EmptySectionCard extends StatelessWidget {
  final Color borderColor;
  final String message;

  const _EmptySectionCard({
    required this.borderColor,
    required this.message,
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
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
            ),
      ),
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
            'Failed to load student profile.',
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
  return '$month ${date.day}, ${date.year}';
}

String _formatPercent(double value) {
  final adjusted = value <= 1 ? value * 100 : value;
  return '${adjusted.round()}%';
}

String _formatError(String raw) {
  if (raw.isEmpty) return 'Please try again.';
  return raw.replaceAll('ApiException: ', '').trim();
}

bool _isAccessDenied(String message) {
  final lower = message.toLowerCase();
  return lower.contains('access denied') || lower.contains('forbidden');
}
