import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/home/controllers/home_controller.dart';
import 'package:sum_academy/modules/home/models/course.dart';
import 'package:sum_academy/modules/home/models/home_dashboard.dart';
import 'package:sum_academy/modules/home/widgets/home_dashboard_skeleton.dart';
import 'package:sum_academy/modules/student/controllers/student_shell_controller.dart';
import 'package:sum_academy/modules/student/views/student_course_detail_view.dart';
import 'package:sum_academy/modules/student/widgets/student_notification_bell.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        child: const SafeArea(
          child: HomeDashboardContent(),
        ),
      ),
    );
  }
}

class HomeDashboardContent extends GetView<HomeController> {
  const HomeDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final content = controller.isLoading.value
          ? const HomeDashboardSkeleton()
          : _DashboardContent(dashboard: controller.dashboard.value);
      return RefreshIndicator(
        color: SumAcademyTheme.brandBlue,
        onRefresh: controller.loadDashboard,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            const _HeaderRow(),
            SizedBox(height: 14.h),
            content,
          ],
        ),
      );
    });
  }
}

class _DashboardContent extends StatelessWidget {
  final HomeDashboard dashboard;

  const _DashboardContent({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _GreetingCard(
          learnerName: dashboard.learnerName,
          learningStreakDays: dashboard.learningStreakDays,
          learningDays: dashboard.learningDays,
          lastLoginAt: dashboard.lastLoginAt,
        ),
        if (!dashboard.isProfileComplete) ...[
          SizedBox(height: 14.h),
          _PremiumActionButton(
            label: 'Complete Profile',
            onPressed: () {
              final shell = Get.isRegistered<StudentShellController>()
                  ? Get.find<StudentShellController>()
                  : null;
              if (shell != null) {
                shell.setActiveLabel('Settings');
              }
            },
          ),
        ],
        SizedBox(height: 16.h),
        _StudentStatsGrid(
          enrolled: dashboard.enrolledClasses,
          completed: dashboard.completedCourses,
          certificates: dashboard.certificatesEarned,
          learningDays: dashboard.learningDays,
        ),
        SizedBox(height: 18.h),
        if (dashboard.activeCourse != null &&
            !(dashboard.activeCourse?.isEmpty ?? true))
          _ActiveCourseCard(course: dashboard.activeCourse!)
        else
          const _ActiveCourseEmptyState(),
        SizedBox(height: 18.h),
        _SectionHeaderRow(
          title: 'My Classes',
          onViewAll: () {
            final shell = Get.isRegistered<StudentShellController>()
                ? Get.find<StudentShellController>()
                : null;
            if (shell != null) {
              shell.setActiveLabel('My Classes');
            }
          },
        ),
        SizedBox(height: 12.h),
        if (dashboard.recentCourses.isEmpty)
          const _EmptyCoursesCard()
        else
          Column(
            children: dashboard.recentCourses
                .take(2)
                .map(
                  (course) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _RecentCourseCard(course: course),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;
    final scaffoldState = Scaffold.maybeOf(context);
    final showMenu = scaffoldState?.hasDrawer ?? false;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
              size: 20.sp,
              color: textColor.withOpacityFloat(0.7),
            ),
          ),
        if (showMenu) SizedBox(width: 6.w),
        Expanded(
          child: Text(
            'SUM ACADEMY',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: textColor.withOpacityFloat(0.55),
              letterSpacing: 3.6,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        StudentNotificationBell(
          iconColor: textColor.withOpacityFloat(0.75),
        ),
      ],
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final String learnerName;
  final int learningStreakDays;
  final int learningDays;
  final DateTime? lastLoginAt;

  const _GreetingCard({
    required this.learnerName,
    required this.learningStreakDays,
    required this.learningDays,
    required this.lastLoginAt,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border = isDark
        ? SumAcademyTheme.darkBorder
        : SumAcademyTheme.brandBluePale;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;
    final now = DateTime.now();
    final greeting = _greetingForHour(now.hour);
    final name = learnerName.trim().isEmpty ? 'Learner' : learnerName.trim();
    final longDate = _formatLongDate(now);

    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: border),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: SumAcademyTheme.darkBase.withOpacityFloat(0.06),
              blurRadius: 18.r,
              offset: Offset(0, 10.h),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, $name',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 6.h),
          Text(
            longDate,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor.withOpacityFloat(0.65),
                ),
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 8.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _InfoChip(
                label: '$learningStreakDays day learning streak',
                background: SumAcademyTheme.brandBluePale,
                textColor: SumAcademyTheme.brandBlue,
              ),
              _InfoChip(
                label: 'Learning days: $learningDays',
                background: SumAcademyTheme.successLight,
                textColor: SumAcademyTheme.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PremiumActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PremiumActionButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusButton.r),
        gradient: const LinearGradient(
          colors: [
            SumAcademyTheme.brandBlue,
            SumAcademyTheme.brandBlueDark,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: SumAcademyTheme.brandBlue.withOpacityFloat(0.25),
            blurRadius: 18.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(SumAcademyTheme.radiusButton.r),
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 18.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: SumAcademyTheme.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18.sp,
                  color: SumAcademyTheme.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StudentStatsGrid extends StatelessWidget {
  final int enrolled;
  final int completed;
  final int certificates;
  final int learningDays;

  const _StudentStatsGrid({
    required this.enrolled,
    required this.completed,
    required this.certificates,
    required this.learningDays,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Enrolled Classes',
                value: enrolled.toString(),
                accent: SumAcademyTheme.brandBlue,
                tone: SumAcademyTheme.brandBluePale,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _StatCard(
                label: 'Completed Courses',
                value: completed.toString(),
                accent: SumAcademyTheme.success,
                tone: SumAcademyTheme.successLight,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Certificates Earned',
                value: certificates.toString(),
                accent: SumAcademyTheme.brandBlueDark,
                tone: SumAcademyTheme.brandBluePale,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _StatCard(
                label: 'Learning Days',
                value: learningDays.toString(),
                accent: SumAcademyTheme.brandBlueDark,
                tone: SumAcademyTheme.brandBluePale,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final Color tone;

  const _StatCard({
    required this.label,
    required this.value,
    required this.accent,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border = isDark
        ? SumAcademyTheme.darkBorder
        : SumAcademyTheme.brandBluePale;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: tone,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _ActiveCourseCard extends StatelessWidget {
  final ActiveCourseInfo course;

  const _ActiveCourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border = isDark
        ? SumAcademyTheme.darkBorder
        : SumAcademyTheme.brandBluePale;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;
    final progressPercent = (course.progress * 100).clamp(0, 100).round();

    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular((SumAcademyTheme.radiusCard + 2).r),
        border: Border.all(color: border),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: SumAcademyTheme.darkBase.withOpacityFloat(0.08),
              blurRadius: 22.r,
              offset: Offset(0, 12.h),
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 78.r,
            height: 78.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  SumAcademyTheme.brandBluePale,
                  SumAcademyTheme.brandBlueLight.withOpacityFloat(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: SumAcademyTheme.white,
                borderRadius: BorderRadius.circular(14.r),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.play_arrow_rounded,
                size: 26.sp,
                color: SumAcademyTheme.brandBlue,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: 6.h),
                Text(
                  course.teacher.isEmpty ? 'Teacher' : course.teacher,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textColor.withOpacityFloat(0.62),
                      ),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: LinearProgressIndicator(
                          value: course.progress,
                          minHeight: 7.h,
                          backgroundColor: SumAcademyTheme.brandBluePale,
                          valueColor: const AlwaysStoppedAnimation(
                            SumAcademyTheme.brandBlue,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: SumAcademyTheme.brandBluePale,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '$progressPercent%',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: SumAcademyTheme.brandBlue,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(
                      Icons.play_circle_outline_rounded,
                      size: 16.sp,
                      color: textColor.withOpacityFloat(0.6),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        'Next lecture: ${course.nextLecture}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: textColor.withOpacityFloat(0.7),
                            ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 0, maxWidth: 200.w),
                    child: ElevatedButton(
                      onPressed: () {
                        if (course.courseId.trim().isNotEmpty) {
                          Get.to(
                            () => StudentCourseDetailView(
                              courseId: course.courseId,
                              title: course.title,
                              teacher: course.teacher,
                              progress: course.progress,
                              nextLecture: course.nextLecture,
                            ),
                          );
                          return;
                        }
                        final shell = Get.isRegistered<StudentShellController>()
                            ? Get.find<StudentShellController>()
                            : null;
                        if (shell != null) {
                          shell.setActiveLabel('My Classes');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SumAcademyTheme.brandBlue,
                        foregroundColor: SumAcademyTheme.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 10.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Continue Learning',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: SumAcademyTheme.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveCourseEmptyState extends StatelessWidget {
  const _ActiveCourseEmptyState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border = isDark
        ? SumAcademyTheme.darkBorder
        : SumAcademyTheme.brandBluePale;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 64.r,
            height: 64.r,
            decoration: BoxDecoration(
              color: SumAcademyTheme.brandBluePale,
              borderRadius: BorderRadius.circular(18.r),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.menu_book_rounded,
              color: SumAcademyTheme.brandBlue,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No active course yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Explore courses and start learning to see progress here.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textColor.withOpacityFloat(0.65),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeaderRow extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const _SectionHeaderRow({
    required this.title,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(
            foregroundColor: SumAcademyTheme.brandBlue,
          ),
          child: const Text('View all'),
        ),
      ],
    );
  }
}

class _RecentCourseCard extends StatelessWidget {
  final Course course;

  const _RecentCourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border = isDark
        ? SumAcademyTheme.darkBorder
        : SumAcademyTheme.brandBluePale;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;
    final progressPercent = (course.progress * 100).clamp(0, 100).round();

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              color: course.accent.withOpacityFloat(0.16),
              borderRadius: BorderRadius.circular(16.r),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.menu_book_rounded,
              color: course.accent,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 4.h),
                Text(
                  course.subtitle.isEmpty ? 'In progress' : course.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textColor.withOpacityFloat(0.6),
                      ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: LinearProgressIndicator(
                          value: course.progress,
                          minHeight: 6.h,
                          backgroundColor: SumAcademyTheme.brandBluePale,
                          valueColor: AlwaysStoppedAnimation(course.accent),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '$progressPercent%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: textColor.withOpacityFloat(0.7),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCoursesCard extends StatelessWidget {
  const _EmptyCoursesCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border = isDark
        ? SumAcademyTheme.darkBorder
        : SumAcademyTheme.brandBluePale;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.menu_book_rounded,
            color: SumAcademyTheme.brandBlue,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'No courses yet. Enroll to see your progress here.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor.withOpacityFloat(0.7),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color textColor;

  const _InfoChip({
    required this.label,
    required this.background,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

String _greetingForHour(int hour) {
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  if (hour < 21) return 'Good evening';
  return 'Good night';
}

String _formatLongDate(DateTime date) {
  final weekday = _weekdayName(date.weekday);
  final month = _monthName(date.month);
  final day = date.day.toString().padLeft(2, '0');
  return '$weekday, $month $day, ${date.year}';
}

String _formatShortDate(DateTime date) {
  final month = _monthName(date.month).substring(0, 3);
  final day = date.day.toString().padLeft(2, '0');
  return '$month $day, ${date.year}';
}

String _monthName(int month) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return months[(month - 1).clamp(0, 11)];
}

String _weekdayName(int weekday) {
  const days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  return days[(weekday - 1).clamp(0, 6)];
}
