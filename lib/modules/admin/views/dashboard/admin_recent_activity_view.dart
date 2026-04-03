import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/controllers/admin_controller.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_ui.dart';
import 'package:sum_academy/modules/admin/widgets/dashboard/admin_activity_card.dart';
import 'package:sum_academy/modules/admin/widgets/dashboard/activity_detail_sheet.dart';

class AdminRecentActivityView extends GetView<AdminController> {
  const AdminRecentActivityView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark
        ? SumAcademyTheme.darkSurface
        : SumAcademyTheme.white;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;
    final borderColor = AdminUi.borderColor(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [
                    SumAcademyTheme.darkBase,
                    SumAcademyTheme.darkSurface,
                  ]
                : const [
                    SumAcademyTheme.surfaceSecondary,
                    SumAcademyTheme.surfaceTertiary,
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: controller.fetchRecentActivities,
            color: textColor,
            child: ListView(
              padding: AdminUi.pagePadding(),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => Get.back(),
                      borderRadius:
                          BorderRadius.circular(SumAcademyTheme.radiusButton.r),
                      child: Container(
                        width: 42.r,
                        height: 42.r,
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(
                            SumAcademyTheme.radiusButton.r,
                          ),
                          border: Border.all(
                            color: isDark
                                ? SumAcademyTheme.darkBorder
                                : SumAcademyTheme.brandBluePale,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: textColor,
                          size: 20.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recent Activity',
                            style:
                                Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'All important updates across Sum Academy.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: textColor.withOpacityFloat(0.6),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: SumAcademyTheme.brandBluePale,
                        borderRadius: BorderRadius.circular(
                          SumAcademyTheme.radiusPill.r,
                        ),
                      ),
                      child: Text(
                        'Live',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: SumAcademyTheme.brandBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: AdminUi.cardDecoration(
                    surface: surface,
                    border: borderColor,
                    showShadow: false,
                    radius: SumAcademyTheme.radiusCard,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36.r,
                        height: 36.r,
                        decoration: BoxDecoration(
                          color: SumAcademyTheme.brandBluePale,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.timeline_rounded,
                          color: SumAcademyTheme.brandBlue,
                          size: 18.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'Pull down anytime to refresh the activity feed.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: textColor.withOpacityFloat(0.7),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18.h),
                Obx(() {
                  final activities = controller.recentActivities;
                  if (controller.isActivitiesLoading.value &&
                      activities.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: SizedBox(
                          width: 24.r,
                          height: 24.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: SumAcademyTheme.brandBlue,
                          ),
                        ),
                      ),
                    );
                  }
                  if (activities.isEmpty) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 20.h,
                      ),
                      decoration: AdminUi.cardDecoration(
                        surface: surface,
                        border: borderColor,
                        showShadow: false,
                        radius: SumAcademyTheme.radiusCard,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 46.r,
                            height: 46.r,
                            decoration: BoxDecoration(
                              color: SumAcademyTheme.surfaceTertiary,
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Icon(
                              Icons.inbox_rounded,
                              color: SumAcademyTheme.brandBlue,
                              size: 22.sp,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'No activity yet',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Once new events are recorded, they will appear here.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: textColor.withOpacityFloat(0.6),
                                    ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: activities
                        .map(
                          (activity) => Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: AdminActivityCard(
                              activity: activity,
                              surface: surface,
                              textColor: textColor,
                              onTap: () =>
                                  showActivityDetailSheet(context, activity),
                            ),
                          ),
                        )
                        .toList(),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
