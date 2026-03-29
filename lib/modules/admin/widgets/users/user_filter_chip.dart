import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';

class UserFilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const UserFilterChip({
    super.key,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final background = isSelected
        ? SumAcademyTheme.brandBlue
        : SumAcademyTheme.white;
    final textColor = isSelected
        ? SumAcademyTheme.white
        : SumAcademyTheme.darkBase;
    final borderColor = isSelected
        ? SumAcademyTheme.brandBlue
        : SumAcademyTheme.brandBluePale;

    return InkWell(
      borderRadius: BorderRadius.circular(SumAcademyTheme.radiusPill.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(SumAcademyTheme.radiusPill.r),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? SumAcademyTheme.white.withOpacityFloat(0.2)
                    : SumAcademyTheme.surfaceTertiary,
                borderRadius: BorderRadius.circular(
                  SumAcademyTheme.radiusPill.r,
                ),
              ),
              child: Text(
                count.toString(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
