import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';

class StudentPlaceholderView extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;

  const StudentPlaceholderView({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;
    final surface =
        isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
      children: [
        _StudentHeaderRow(title: title, textColor: textColor),
        SizedBox(height: 18.h),
        Text(
          subtitle ?? 'We are polishing this space for you.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textColor.withOpacityFloat(0.65),
              ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
            border: Border.all(
              color: isDark
                  ? SumAcademyTheme.darkBorder
                  : SumAcademyTheme.brandBluePale,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: SumAcademyTheme.brandBluePale,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(icon, color: SumAcademyTheme.brandBlue),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  '$title module is ready for your data.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textColor.withOpacityFloat(0.7),
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StudentHeaderRow extends StatelessWidget {
  final String title;
  final Color textColor;

  const _StudentHeaderRow({
    required this.title,
    required this.textColor,
  });

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
              size: 22.sp,
              color: textColor.withOpacityFloat(0.7),
            ),
          ),
        if (showMenu) SizedBox(width: 6.w),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
