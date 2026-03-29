import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/controllers/admin_controller.dart';

class AdminDashboardView extends GetView<AdminController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final textColor = isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [SumAcademyTheme.darkBase, SumAcademyTheme.darkSurface]
                : const [
                    SumAcademyTheme.surfaceSecondary,
                    SumAcademyTheme.surfaceTertiary,
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
            children: [
              _HeaderRow(textColor: textColor, userName: controller.userName),
              SizedBox(height: 18.h),
              Text(
                'Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              SizedBox(height: 12.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.stats.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  return _StatCard(
                    stat: controller.stats[index],
                    surface: surface,
                    textColor: textColor,
                  );
                },
              ),
              SizedBox(height: 24.h),
              Text(
                'Quick actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              SizedBox(height: 12.h),
              ...controller.quickActions.map(
                (action) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _ActionCard(
                    action: action,
                    surface: surface,
                    textColor: textColor,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius:
                      BorderRadius.circular(SumAcademyTheme.radiusCard.r),
                  border: Border.all(
                    color: isDark
                        ? SumAcademyTheme.darkBorder
                        : SumAcademyTheme.brandBluePale,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: SumAcademyTheme.brandBluePale,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.health_and_safety_rounded,
                        color: SumAcademyTheme.brandBlue,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'System status',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'All services running normally.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: textColor.withOpacityFloat(0.65),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: SumAcademyTheme.successLight,
                        borderRadius: BorderRadius.circular(
                          SumAcademyTheme.radiusPill.r,
                        ),
                      ),
                      child: Text(
                        'Healthy',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: SumAcademyTheme.success,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final Color textColor;
  final String userName;

  const _HeaderRow({
    required this.textColor,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final initials = userName.isNotEmpty ? userName.trim()[0].toUpperCase() : 'A';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sum Academy',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: textColor,
                      fontSize: 22.sp,
                    ),
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      color: SumAcademyTheme.brandBlue,
                      borderRadius: BorderRadius.circular(
                        SumAcademyTheme.radiusAvatar.r,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              SumAcademyTheme.brandBlue.withOpacityFloat(0.2),
                          blurRadius: 16.r,
                          offset: Offset(0, 8.h),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: SumAcademyTheme.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          children: [
            _HeaderIconButton(
              icon: Icons.search_rounded,
              tooltip: 'Search',
            ),
            SizedBox(width: 10.w),
            _HeaderIconButton(
              icon: Icons.notifications_none_rounded,
              tooltip: 'Notifications',
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;

  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(
        color: SumAcademyTheme.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: () {},
        icon: Icon(
          icon,
          color: SumAcademyTheme.brandBlue,
          size: 22.sp,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final AdminStat stat;
  final Color surface;
  final Color textColor;

  const _StatCard({
    required this.stat,
    required this.surface,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final muted = textColor.withOpacityFloat(0.55);
    final tone = stat.tone ?? SumAcademyTheme.brandBluePale;
    final iconColor = stat.iconColor ?? SumAcademyTheme.brandBlue;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: SumAcademyTheme.darkBase.withOpacityFloat(0.06),
            blurRadius: 18.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: tone,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              stat.icon,
              color: iconColor,
              size: 20.sp,
            ),
          ),
          SizedBox(height: 12.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              stat.value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            stat.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: muted,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final AdminAction action;
  final Color surface;
  final Color textColor;

  const _ActionCard({
    required this.action,
    required this.surface,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: SumAcademyTheme.surfaceTertiary,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              action.icon,
              color: SumAcademyTheme.brandBlue,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 4.h),
                Text(
                  action.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textColor.withOpacityFloat(0.6),
                      ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: textColor.withOpacityFloat(0.4),
          ),
        ],
      ),
    );
  }
}
