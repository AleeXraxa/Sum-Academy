import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/onboarding/models/onboarding_page.dart';

class OnboardingSlide extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingSlide({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headlineLarge?.copyWith(
      fontSize: 28.sp,
      height: 1.1,
    );
    final subtitleStyle = theme.textTheme.bodyMedium?.copyWith(
      color: SumAcademyTheme.darkBase.withOpacityFloat(0.65),
      fontSize: 14.sp,
      height: 1.5,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _HeroCard(data: data),
          SizedBox(height: 28.h),
          _TagPill(label: data.tag, accent: data.accent, soft: data.accentSoft),
          SizedBox(height: 14.h),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: titleStyle,
          ),
          SizedBox(height: 12.h),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: subtitleStyle,
          ),
          SizedBox(height: 20.h),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8.w,
            runSpacing: 8.h,
            children: data.highlights
                .map(
                  (item) => _HighlightPill(
                    label: item,
                    accent: data.accent,
                    soft: data.accentSoft,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final OnboardingPageData data;

  const _HeroCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260.h,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            data.accentSoft,
            SumAcademyTheme.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: data.accent.withOpacityFloat(0.12)),
        boxShadow: [
          BoxShadow(
            color: data.accent.withOpacityFloat(0.08),
            blurRadius: 24.r,
            offset: Offset(0, 16.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30.h,
            left: -20.w,
            child: _BlurCircle(color: data.accent.withOpacityFloat(0.18)),
          ),
          Positioned(
            bottom: -40.h,
            right: -10.w,
            child: _BlurCircle(color: data.accent.withOpacityFloat(0.14)),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(18.r),
              decoration: BoxDecoration(
                color: SumAcademyTheme.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: SumAcademyTheme.darkBase.withOpacityFloat(0.08),
                    blurRadius: 20.r,
                    offset: Offset(0, 12.h),
                  ),
                ],
              ),
              child: Container(
                width: 86.r,
                height: 86.r,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      data.accent,
                      data.accent.withOpacityFloat(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: Icon(
                  data.icon,
                  color: SumAcademyTheme.white,
                  size: 40.r,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final Color color;

  const _BlurCircle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160.r,
      height: 160.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  final Color accent;
  final Color soft;

  const _TagPill({required this.label, required this.accent, required this.soft});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: soft,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: accent.withOpacityFloat(0.2)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _HighlightPill extends StatelessWidget {
  final String label;
  final Color accent;
  final Color soft;

  const _HighlightPill({
    required this.label,
    required this.accent,
    required this.soft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: soft,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: accent.withOpacityFloat(0.12)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: SumAcademyTheme.darkBase.withOpacityFloat(0.75),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
