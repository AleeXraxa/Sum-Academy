import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/controllers/admin_controller.dart';
import 'package:sum_academy/modules/admin/views/dashboard/admin_recent_activity_view.dart';
import 'package:sum_academy/modules/admin/widgets/dashboard/admin_action_card.dart';
import 'package:sum_academy/modules/admin/widgets/dashboard/admin_activity_card.dart';
import 'package:sum_academy/modules/admin/widgets/dashboard/admin_dashboard_skeleton.dart';
import 'package:sum_academy/modules/admin/widgets/dashboard/admin_stat_card.dart';
import 'package:sum_academy/modules/admin/widgets/header/admin_header_row.dart';

class AdminDashboardView extends StatelessWidget {
  final AdminController controller;
  final Color textColor;
  final Color surface;
  final bool isDark;
  final String userName;
  final bool isSearchExpanded;

  const AdminDashboardView({
    super.key,
    required this.controller,
    required this.textColor,
    required this.surface,
    required this.isDark,
    required this.userName,
    required this.isSearchExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshDashboard,
      color: textColor,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          AdminHeaderRow(
            textColor: textColor,
            userName: userName,
            isSearchExpanded: isSearchExpanded,
            onSearchTap: controller.toggleSearch,
            onSearchClose: controller.closeSearch,
            searchController: controller.searchController,
          ),
          SizedBox(height: 18.h),
          Obx(() {
            final isLoading = controller.isStatsLoading.value ||
                controller.isActivitiesLoading.value;
            if (isLoading) {
              return const AdminDashboardSkeleton();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    return AdminStatCard(
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
                    child: AdminActionCard(
                      action: action,
                      surface: surface,
                      textColor: textColor,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Recent activity',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.to(
                        () => const AdminRecentActivityView(),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: SumAcademyTheme.brandBlue,
                      ),
                      child: const Text('View all'),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Obx(() {
                  final activities = controller.recentActivities;
                  if (activities.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Text(
                        'No recent activity yet.',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: textColor.withOpacityFloat(0.6),
                                ),
                      ),
                    );
                  }
                  final preview = activities.length > 5
                      ? activities.sublist(0, 5)
                      : activities;
                  return Column(
                    children: preview
                        .map(
                          (activity) => Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: AdminActivityCard(
                              activity: activity,
                              surface: surface,
                              textColor: textColor,
                            ),
                          ),
                        )
                        .toList(),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }
}
