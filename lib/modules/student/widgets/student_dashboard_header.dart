import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/student/widgets/student_notification_bell.dart';

class StudentDashboardHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;

  const StudentDashboardHeader({
    Key? key,
    this.title = 'SUM ACADEMY',
    this.subtitle = 'Student Portal',
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;
    final scaffoldState = Scaffold.maybeOf(context);
    final showMenu = scaffoldState?.hasDrawer ?? false;

    void openDrawer() {
      if (scaffoldState?.hasDrawer ?? false) {
        scaffoldState?.openDrawer();
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo avatar (decorative)
        Container(
          width: 38.r,
          height: 38.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? SumAcademyTheme.darkBorder
                  : SumAcademyTheme.brandBluePale,
              width: 1.5,
            ),
            image: const DecorationImage(
              image: AssetImage('assets/logo.jpeg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        // Brand labels
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title ?? 'SUM ACADEMY',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: textColor.withOpacityFloat(0.45),
                      letterSpacing: 3.2,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                subtitle ?? 'Student Portal',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: SumAcademyTheme.brandBlue,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
              ),
            ],
          ),
        ),
        // Notification bell
        StudentNotificationBell(
          iconColor: textColor.withOpacityFloat(0.75),
        ),
        if (actions != null) ...actions!,
        // Hamburger menu button (always visible when drawer exists)
        if (showMenu) ...[
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: openDrawer,
            child: Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: isDark
                    ? SumAcademyTheme.darkSurface
                    : SumAcademyTheme.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isDark
                      ? SumAcademyTheme.darkBorder
                      : SumAcademyTheme.brandBluePale,
                ),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: SumAcademyTheme.darkBase.withOpacityFloat(0.05),
                      blurRadius: 8.r,
                      offset: Offset(0, 4.h),
                    ),
                ],
              ),
              child: Icon(
                Icons.menu_rounded,
                size: 20.sp,
                color: textColor.withOpacityFloat(0.75),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
