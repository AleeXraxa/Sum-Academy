import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const CategoryChip({
    super.key,
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor =
        isDark ? SumAcademyTheme.brandBlueLight : SumAcademyTheme.brandBlue;
    final selectedText =
        isDark ? SumAcademyTheme.darkBase : SumAcademyTheme.white;
    final unselectedBg =
        isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final borderColor =
        isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale;
    final textColor = isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isSelected ? selectedColor : unselectedBg,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusPill.r),
        border: Border.all(
          color: isSelected ? Colors.transparent : borderColor,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isSelected ? selectedText : textColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
