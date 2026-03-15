import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (trailing != null) ...[
          Align(alignment: Alignment.centerRight, child: trailing!),
          SizedBox(height: 10.h),
        ],
        Text(
          title,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 28.sp,
                height: 1.1,
              ),
        ),
        SizedBox(height: 8.h),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: baseColor.withOpacity(0.65),
              ),
        ),
      ],
    );
  }
}
