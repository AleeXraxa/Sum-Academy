import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';
import 'package:sum_academy/modules/student/controllers/student_certificates_controller.dart';
import 'package:sum_academy/modules/student/models/student_certificate.dart';
import 'package:sum_academy/modules/student/widgets/student_notification_bell.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sum_academy/modules/student/widgets/student_dashboard_header.dart';

class StudentCertificatesView extends GetView<StudentCertificatesController> {
  const StudentCertificatesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Obx(() {
      return RefreshIndicator(
        color: SumAcademyTheme.brandBlue,
        onRefresh: controller.refresh,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            StudentDashboardHeader(subtitle: 'My Certificates'),
            SizedBox(height: 18.h),
            _StatsRow(
              totalEarned: controller.totalEarned,
              inProgress: controller.coursesInProgress.value,
            ),
            SizedBox(height: 18.h),
            if (controller.isLoading.value)
              const _CertificatesSkeleton()
            else if (controller.certificates.isEmpty)
              const _EmptyState()
            else
              ...controller.certificates.map(
                (cert) => Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: _CertificateCard(
                    certificate: cert,
                    onDownload: () => _downloadCertificate(context, cert),
                    onShare: () => _copyLink(
                      cert.pdfUrl.isNotEmpty ? cert.pdfUrl : cert.certificateId,
                      title: 'Share link copied',
                    ),
                    onVerify: () =>
                        controller.verifyCertificate(cert.certificateId),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Future<void> _copyLink(String value, {required String title}) async {
    if (value.trim().isEmpty) {
      await showAppErrorDialog(
        title: 'Unavailable',
        message: 'No link is available for this certificate yet.',
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: value.trim()));
    await showAppSuccessDialog(title: title, message: 'Copied to clipboard.');
  }

  Future<void> _downloadCertificate(
    BuildContext context,
    StudentCertificate certificate,
  ) async {
    if (certificate.pdfUrl.trim().isEmpty) {
      await showAppErrorDialog(
        title: 'Unavailable',
        message: 'No link is available for this certificate yet.',
      );
      return;
    }

    showLoadingDialog(context, message: 'Downloading certificate...');
    try {
      final file = await controller.downloadCertificate(certificate);
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        await showAppErrorDialog(
          title: 'Unable to open',
          message: result.message.isNotEmpty
              ? result.message
              : 'Could not open the certificate file.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      final message = e is Exception ? e.toString() : 'Unknown error';
      await showAppErrorDialog(
        title: 'Download failed',
        message: message.replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _openLink(String value, {required String title}) async {
    final url = value.trim();
    if (url.isEmpty) {
      await showAppErrorDialog(
        title: 'Unavailable',
        message: 'No link is available for this certificate yet.',
      );
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) {
      await showAppErrorDialog(
        title: 'Unavailable',
        message: 'Invalid certificate link.',
      );
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      await showAppErrorDialog(
        title: 'Unable to open',
        message: 'Could not open the certificate link.',
      );
    } else {
      await showAppSuccessDialog(
        title: title,
        message: 'Your certificate is opening in the browser.',
      );
    }
  }
}

class _StatsRow extends StatelessWidget {
  final int totalEarned;
  final int inProgress;

  const _StatsRow({required this.totalEarned, required this.inProgress});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTwoColumn = width > 640;
    final cards = [
      _StatCard(
        label: 'Total Earned',
        value: totalEarned.toString(),
        icon: Icons.workspace_premium_rounded,
        accent: SumAcademyTheme.warning,
      ),
      _StatCard(
        label: 'Courses In Progress',
        value: inProgress.toString(),
        icon: Icons.loop_rounded,
        accent: SumAcademyTheme.brandBlue,
      ),
    ];

    if (isTwoColumn) {
      return Row(
        children: [
          Expanded(child: cards[0]),
          SizedBox(width: 12.w),
          Expanded(child: cards[1]),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(width: double.infinity, child: cards[0]),
        SizedBox(height: 12.h),
        SizedBox(width: double.infinity, child: cards[1]),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
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

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: border),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: SumAcademyTheme.brandBlue.withOpacityFloat(0.06),
              blurRadius: 18.r,
              offset: Offset(0, 10.h),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              color: accent.withOpacityFloat(0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20.sp, color: accent),
          ),
          SizedBox(height: 14.h),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.0,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor.withOpacityFloat(0.55),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  final StudentCertificate certificate;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onVerify;

  const _CertificateCard({
    required this.certificate,
    required this.onDownload,
    required this.onShare,
    required this.onVerify,
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

    final issueDate = certificate.issuedAt == null
        ? 'N/A'
        : _formatDate(certificate.issuedAt!);

    return Container(
      width: double.infinity,
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
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CertificatePreview(
                  certificate: certificate,
                  issueDate: issueDate,
                ),
                SizedBox(height: 18.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onDownload,
                    icon: Icon(
                      Icons.picture_as_pdf_rounded,
                      size: 18.sp,
                      color: SumAcademyTheme.white,
                    ),
                    label: const Text('Download PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SumAcademyTheme.brandBlue,
                      foregroundColor: SumAcademyTheme.white,
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
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onShare,
                        icon: Icon(Icons.share_rounded, size: 16.sp),
                        label: const Text('Share'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          side: BorderSide(
                            color: SumAcademyTheme.brandBluePale,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              SumAcademyTheme.radiusButton.r,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onVerify,
                        icon: Icon(
                          Icons.check_circle_outline_rounded,
                          size: 16.sp,
                        ),
                        label: const Text('Verify'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          side: BorderSide(
                            color: SumAcademyTheme.brandBluePale,
                          ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificatePreview extends StatelessWidget {
  final StudentCertificate certificate;
  final String issueDate;

  const _CertificatePreview({
    required this.certificate,
    required this.issueDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF8FF),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFB9E2FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  color: SumAcademyTheme.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFFB9E2FF)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.asset('assets/logo.jpeg', fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SUM Academy',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: SumAcademyTheme.darkBase,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'MEDICAL LEARNING EXCELLENCE',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: SumAcademyTheme.brandBlue,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'CERTIFICATE OF COMPLETION',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: SumAcademyTheme.brandBlue,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            certificate.studentName.isEmpty
                ? 'Student'
                : certificate.studentName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: SumAcademyTheme.darkBase,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            certificate.displayProgramLine,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _MiniInfo(label: 'Issue Date', value: issueDate),
              SizedBox(width: 12.w),
              _MiniInfo(
                label: 'Certificate ID',
                value: certificate.certificateId.isEmpty
                    ? 'N/A'
                    : certificate.certificateId,
              ),
              SizedBox(width: 12.w),
              _MiniInfo(
                label: 'Authorized By',
                value: certificate.authorizedBy,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final String label;
  final String value;

  const _MiniInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: SumAcademyTheme.darkBase.withOpacityFloat(0.5),
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: SumAcademyTheme.darkBase,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.white,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_rounded, color: SumAcademyTheme.brandBlue),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'No certificates earned yet.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificatesSkeleton extends StatelessWidget {
  const _CertificatesSkeleton();

  @override
  Widget build(BuildContext context) {
    final base = SumAcademyTheme.surfaceTertiary;
    return Column(
      children: List.generate(
        2,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: SumAcademyTheme.white,
              borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
              border: Border.all(color: SumAcademyTheme.brandBluePale),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonLine(width: 220.w, height: 14.h, color: base),
                SizedBox(height: 12.h),
                _SkeletonLine(width: 280.w, height: 10.h, color: base),
                SizedBox(height: 12.h),
                _SkeletonLine(width: 120.w, height: 12.h, color: base),
                SizedBox(height: 16.h),
                _SkeletonLine(
                  width: double.infinity,
                  height: 42.h,
                  color: base,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatefulWidget {
  final double width;
  final double height;
  final Color color;

  const _SkeletonLine({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  State<_SkeletonLine> createState() => _SkeletonLineState();
}

class _SkeletonLineState extends State<_SkeletonLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.color;
    final highlight = Color.lerp(base, SumAcademyTheme.white, 0.55) ?? base;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final color = Color.lerp(base, highlight, _controller.value) ?? base;
        return Container(
          width: widget.width == double.infinity
              ? double.infinity
              : widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12.r),
          ),
        );
      },
    );
  }
}

String _formatDate(DateTime date) {
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
  final day = date.day.toString().padLeft(2, '0');
  final month = months[date.month - 1];
  final year = date.year.toString();
  return '$day $month $year';
}
