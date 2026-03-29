import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';

class UsersSkeletonList extends StatelessWidget {
  final int count;

  const UsersSkeletonList({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _SkeletonCard(),
        );
      }),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final base = SumAcademyTheme.surfaceTertiary;
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
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
            children: [
              _SkeletonBox(size: 50.r, radius: 25.r, color: base),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(width: 140.w, height: 12.h, color: base),
                    SizedBox(height: 8.h),
                    _SkeletonBox(width: 200.w, height: 10.h, color: base),
                  ],
                ),
              ),
              _SkeletonBox(width: 72.w, height: 26.h, radius: 16.r, color: base),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _SkeletonBox(width: 72.w, height: 26.h, radius: 16.r, color: base),
              SizedBox(width: 10.w),
              _SkeletonBox(width: 44.w, height: 24.h, radius: 12.r, color: base),
              const Spacer(),
              _SkeletonBox(width: 36.r, height: 36.r, radius: 12.r, color: base),
              SizedBox(width: 8.w),
              _SkeletonBox(width: 36.r, height: 36.r, radius: 12.r, color: base),
            ],
          ),
        ],
      ),
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
    this.radius = 12,
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
    final highlight = Color.lerp(base, SumAcademyTheme.white, 0.6) ?? base;

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
