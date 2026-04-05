import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_ui.dart';

class InstallmentsSkeletonList extends StatelessWidget {
  final int count;

  const InstallmentsSkeletonList({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: const _SkeletonCard(),
        );
      }),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final base = SumAcademyTheme.surfaceTertiary;
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: AdminUi.cardDecoration(
        surface: SumAcademyTheme.white,
        border: AdminUi.borderColor(context),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _SkeletonBox(size: 48.r, radius: 24.r, color: base),
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
              _SkeletonBox(width: 80.w, height: 26.h, radius: 16.r, color: base),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _SkeletonBox(width: 120.w, height: 12.h, color: base),
              const Spacer(),
              _SkeletonBox(width: 90.w, height: 12.h, color: base),
            ],
          ),
          SizedBox(height: 12.h),
          _SkeletonBox(width: double.infinity, height: 36.h, radius: 16.r, color: base),
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
