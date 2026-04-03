import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/student/controllers/student_support_controller.dart';

class HelpSupportView extends GetView<StudentSupportController> {
  const HelpSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Obx(() {
      final data = controller.info.value;
      final cards = [
        _SupportCardData(
          title: 'Email',
          value: data.email,
          actionLabel: 'Open',
          onTap: () => _copyAndNotify(data.email),
        ),
        _SupportCardData(
          title: 'WhatsApp',
          value: data.whatsapp,
          actionLabel: 'Open',
          onTap: () => _copyAndNotify(data.whatsapp),
        ),
        _SupportCardData(
          title: 'Phone',
          value: data.phone,
          actionLabel: 'Open',
          onTap: () => _copyAndNotify(data.phone),
        ),
        _SupportCardData(
          title: 'Office Hours',
          value: data.officeHours,
        ),
      ];

      return RefreshIndicator(
        color: SumAcademyTheme.brandBlue,
        onRefresh: controller.fetchSupportInfo,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
          physics: const BouncingScrollPhysics(),
          children: [
            _HeaderRow(textColor: textColor),
            SizedBox(height: 18.h),
            if (controller.isLoading.value)
              const _SupportSkeleton()
            else
              Column(
                children: cards
                    .map(
                      (card) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: SizedBox(
                          width: double.infinity,
                          child: _SupportCard(card: card),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      );
    });
  }

  Future<void> _copyAndNotify(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    await showAppSuccessDialog(
      title: 'Copied',
      message: '$value copied to clipboard.',
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final Color textColor;

  const _HeaderRow({required this.textColor});

  @override
  Widget build(BuildContext context) {
    final scaffoldState = Scaffold.maybeOf(context);
    final showMenu = scaffoldState?.hasDrawer ?? false;

    return Row(
      children: [
        if (showMenu)
          IconButton(
            onPressed: () {
              if (scaffoldState?.hasDrawer ?? false) {
                scaffoldState?.openDrawer();
              }
            },
            icon: Icon(
              Icons.menu_rounded,
              size: 20.sp,
              color: textColor.withOpacityFloat(0.7),
            ),
          ),
        if (showMenu) SizedBox(width: 6.w),
        Expanded(
          child: Text(
            'Help & Support',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _SupportCardData {
  final String title;
  final String value;
  final String? actionLabel;
  final VoidCallback? onTap;

  const _SupportCardData({
    required this.title,
    required this.value,
    this.actionLabel,
    this.onTap,
  });
}

class _SupportCard extends StatelessWidget {
  final _SupportCardData card;

  const _SupportCard({required this.card});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border = isDark
        ? SumAcademyTheme.darkBorder
        : SumAcademyTheme.brandBluePale;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textColor.withOpacityFloat(0.55),
                  letterSpacing: 2.8,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 10.h),
          Text(
            card.value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (card.actionLabel != null) ...[
            SizedBox(height: 8.h),
            OutlinedButton(
              onPressed: card.onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: SumAcademyTheme.brandBlue,
                side: BorderSide(color: SumAcademyTheme.brandBluePale),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              ),
              child: Text(card.actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _SupportSkeleton extends StatelessWidget {
  const _SupportSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base =
        isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.surfaceTertiary;
    final cardColor =
        isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border =
        isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale;

    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonLine(width: 80.w, height: 10.h, color: base),
                SizedBox(height: 10.h),
                _SkeletonLine(width: 180.w, height: 12.h, color: base),
                SizedBox(height: 12.h),
                _SkeletonLine(width: 60.w, height: 24.h, color: base),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const _SkeletonLine({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10.r),
      ),
    );
  }
}
