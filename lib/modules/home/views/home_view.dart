import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/auth/bindings/login_binding.dart';
import 'package:sum_academy/modules/auth/services/auth_service.dart';
import 'package:sum_academy/modules/auth/views/login_view.dart';
import 'package:sum_academy/modules/home/controllers/home_controller.dart';
import 'package:sum_academy/modules/home/dialogs/filter_dialog.dart';
import 'package:sum_academy/modules/home/widgets/category_chip.dart';
import 'package:sum_academy/modules/home/widgets/course_card.dart';
import 'package:sum_academy/modules/home/widgets/live_session_tile.dart';
import 'package:sum_academy/modules/home/widgets/progress_card.dart';
import 'package:sum_academy/modules/home/widgets/section_header.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dashboard = controller.dashboard.value;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final authService = Get.find<AuthService>();
      final stats = [
        _StatEntry(
          label: 'Enrolled',
          value: dashboard.enrolledCourses.toString(),
          helper: 'courses',
        ),
        _StatEntry(
          label: 'Hours',
          value: dashboard.learningHours.toString(),
          helper: 'learned',
        ),
        _StatEntry(
          label: 'Streak',
          value: dashboard.learningStreakDays.toString(),
          helper: 'days',
        ),
      ];

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
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
              physics: const BouncingScrollPhysics(),
              children: [
                _HeaderRow(
                  learnerName: dashboard.learnerName,
                  onLogout: () async {
                    await authService.logout();
                    Get.offAll(() => const LoginView(), binding: LoginBinding());
                  },
                ),
                SizedBox(height: 16.h),
                _SearchBar(onFilterTap: HomeFilterDialog.show),
                SizedBox(height: 20.h),
                _StatsRow(stats: stats),
                SizedBox(height: 20.h),
                ProgressCard(
                  course: dashboard.continueCourse,
                  weeklyGoalHours: dashboard.weeklyGoalHours,
                  weeklyProgressHours: dashboard.weeklyProgressHours,
                ),
                SizedBox(height: 26.h),
                SectionHeader(
                  title: 'Featured tracks',
                  actionLabel: 'View all',
                  onAction: () {},
                ),
                SizedBox(height: 14.h),
                SizedBox(
                  height: 230.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: dashboard.featuredCourses.length,
                    separatorBuilder: (_, _) => SizedBox(width: 14.w),
                    itemBuilder: (context, index) {
                      return CourseCard(
                        course: dashboard.featuredCourses[index],
                      );
                    },
                  ),
                ),
                SizedBox(height: 24.h),
                SectionHeader(
                  title: 'Live this week',
                  actionLabel: 'Schedule',
                  onAction: () {},
                ),
                SizedBox(height: 12.h),
                ...dashboard.liveSessions
                    .map((session) => LiveSessionTile(session: session)),
                SizedBox(height: 16.h),
                SectionHeader(
                  title: 'Focus areas',
                  actionLabel: 'Adjust',
                  onAction: () {},
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: dashboard.categories.asMap().entries.map((entry) {
                    final isSelected =
                        dashboard.highlightedCategoryIndexes.contains(entry.key);
                    return CategoryChip(
                      label: entry.value,
                      isSelected: isSelected,
                    );
                  }).toList(),
                ),
                SizedBox(height: 24.h),
                const _BottomCard(),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _HeaderRow extends StatelessWidget {
  final String learnerName;
  final VoidCallback onLogout;

  const _HeaderRow({
    required this.learnerName,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badgeColor =
        isDark ? SumAcademyTheme.brandBlueDark : SumAcademyTheme.brandBlue;
    final actionBorder =
        isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale;
    final actionFill = isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final actionIcon =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, $learnerName',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: (isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase)
                          .withOpacityFloat(0.7),
                    ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Sum Academy',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 28.sp,
                    ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Your LMS command center',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: onLogout,
              borderRadius:
                  BorderRadius.circular(SumAcademyTheme.radiusButton.r),
              child: Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: actionFill,
                  borderRadius:
                      BorderRadius.circular(SumAcademyTheme.radiusButton.r),
                  border: Border.all(color: actionBorder),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: SumAcademyTheme.darkBase.withOpacityFloat(0.06),
                        blurRadius: 10.r,
                        offset: Offset(0, 6.h),
                      ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.logout_rounded,
                  size: 20.sp,
                  color: actionIcon,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius:
                    BorderRadius.circular(SumAcademyTheme.radiusAvatar.r),
                boxShadow: [
                  BoxShadow(
                    color: badgeColor.withOpacityFloat(isDark ? 0.28 : 0.2),
                    blurRadius: 18.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                'SA',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: SumAcademyTheme.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final VoidCallback onFilterTap;

  const _SearchBar({required this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search courses, mentors, or skills',
        prefixIcon: Icon(Icons.search, size: 20.sp),
        suffixIcon: GestureDetector(
          onTap: onFilterTap,
          child: Container(
            margin: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: SumAcademyTheme.brandBlue,
              borderRadius: BorderRadius.circular(SumAcademyTheme.radiusButton.r),
            ),
            child: Icon(Icons.tune, color: SumAcademyTheme.white, size: 20.sp),
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final List<_StatEntry> stats;

  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats
          .map(
            (stat) => Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: _StatTile(stat: stat),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _StatTile extends StatelessWidget {
  final _StatEntry stat;

  const _StatTile({required this.stat});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale;
    final labelColor = (isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase)
        .withOpacityFloat(0.7);
    final helperColor = (isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase)
        .withOpacityFloat(0.5);

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stat.value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 20.sp,
                ),
          ),
          SizedBox(height: 2.h),
          Text(
            stat.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            stat.helper,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: helperColor,
                ),
          ),
        ],
      ),
    );
  }
}

class _BottomCard extends StatelessWidget {
  const _BottomCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [SumAcademyTheme.darkElevated, SumAcademyTheme.brandBlueDark]
              : const [SumAcademyTheme.brandBlueDarker, SumAcademyTheme.brandBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusLargeCard.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready for the next track?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: SumAcademyTheme.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Explore the full Sum Academy catalog and build your path.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SumAcademyTheme.white.withOpacityFloat(0.8),
                      ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: SumAcademyTheme.accentOrange,
              foregroundColor: SumAcademyTheme.white,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
            child: const Text('Browse'),
          ),
        ],
      ),
    );
  }
}

class _StatEntry {
  final String label;
  final String value;
  final String helper;

  const _StatEntry({
    required this.label,
    required this.value,
    required this.helper,
  });
}
