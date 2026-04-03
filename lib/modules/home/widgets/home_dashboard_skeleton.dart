import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';

class HomeDashboardSkeleton extends StatelessWidget {
  const HomeDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base =
        isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.surfaceTertiary;
    final cardColor =
        isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final borderColor =
        isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SkeletonLine(width: 160.w, height: 16.h, color: base),
        SizedBox(height: 14.h),
        _SkeletonCard(
          base: base,
          cardColor: cardColor,
          borderColor: borderColor,
          height: 120.h,
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 1.35,
          ),
          itemBuilder: (context, index) {
            return _SkeletonCard(
              base: base,
              cardColor: cardColor,
              borderColor: borderColor,
            );
          },
        ),
        SizedBox(height: 18.h),
        _SkeletonCard(
          base: base,
          cardColor: cardColor,
          borderColor: borderColor,
          height: 120.h,
        ),
        SizedBox(height: 18.h),
        _SkeletonLine(width: 140.w, height: 14.h, color: base),
        SizedBox(height: 10.h),
        Column(
          children: List.generate(
            2,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _SkeletonRowCard(
                base: base,
                cardColor: cardColor,
                borderColor: borderColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final Color base;
  final Color cardColor;
  final Color borderColor;
  final double? height;

  const _SkeletonCard({
    required this.base,
    required this.cardColor,
    required this.borderColor,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            height == null ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
        children: [
          _SkeletonBox(size: 42.r, radius: 14.r, color: base),
          SizedBox(height: 12.h),
          _SkeletonLine(width: 120.w, height: 12.h, color: base),
          SizedBox(height: 8.h),
          _SkeletonLine(width: 180.w, height: 10.h, color: base),
        ],
      ),
    );
  }
}

class _SkeletonRowCard extends StatelessWidget {
  final Color base;
  final Color cardColor;
  final Color borderColor;

  const _SkeletonRowCard({
    required this.base,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          _SkeletonBox(size: 48.r, radius: 16.r, color: base),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonLine(width: 180.w, height: 12.h, color: base),
                SizedBox(height: 8.h),
                _SkeletonLine(width: 220.w, height: 10.h, color: base),
              ],
            ),
          ),
        ],
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
    return _SkeletonBox(
      width: width,
      height: height,
      radius: 12.r,
      color: color,
    );
  }
}

class _SkeletonBox extends StatefulWidget {
  final double? width;
  final double? height;
  final double? size;
  final double radius;
  final Color color;

  const _SkeletonBox({
    this.width,
    this.height,
    this.size,
    required this.radius,
    required this.color,
  });

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
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
          width: widget.size ?? widget.width,
          height: widget.size ?? widget.height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        );
      },
    );
  }
}
