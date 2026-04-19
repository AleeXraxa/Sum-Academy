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
import 'package:sum_academy/modules/student/widgets/student_dashboard_header.dart';

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
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            const StudentDashboardHeader(),
            SizedBox(height: 16.h),
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
          lastLoginAt: dashboard.lastLoginAt,
          activeCourse: dashboard.activeCourse,
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
        SizedBox(height: 20.h),
        _StudentStatsGrid(
          enrolled: dashboard.enrolledClasses,
          completed: dashboard.completedCourses,
          certificates: dashboard.certificatesEarned,
          learningDays: dashboard.learningDays,
        ),
        SizedBox(height: 20.h),
        if (dashboard.activeCourse != null &&
            !(dashboard.activeCourse?.isEmpty ?? true))
          _ActiveCourseCard(course: dashboard.activeCourse!)
        else
          const _ActiveCourseEmptyState(),
        SizedBox(height: 20.h),
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

// ── Floating Circle Animation ──────────────────────────────────────────────────

class _FloatingCircle extends StatefulWidget {
  final double size;
  final Color color;
  final double xOffset;
  final double yOffset;
  final Duration duration;

  const _FloatingCircle({
    required this.size,
    required this.color,
    this.xOffset = 10,
    this.yOffset = 15,
    this.duration = const Duration(seconds: 4),
  });

  @override
  State<_FloatingCircle> createState() => _FloatingCircleState();
}

class _FloatingCircleState extends State<_FloatingCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Use an easeInOut curve for smoother floating
        final value = Curves.easeInOutSine.transform(_controller.value);
        return Transform.translate(
          offset: Offset(
            value * widget.xOffset,
            value * widget.yOffset,
          ),
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
        ),
      ),
    );
  }
}

// ── Header Row ────────────────────────────────────────────────────────────────



// ── Greeting Card ─────────────────────────────────────────────────────────────

class _GreetingCard extends StatelessWidget {
  final String learnerName;
  final DateTime? lastLoginAt;
  final ActiveCourseInfo? activeCourse;

  const _GreetingCard({
    required this.learnerName,
    required this.lastLoginAt,
    required this.activeCourse,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final greeting = _greetingForHour(now.hour);
    final name = learnerName.trim().isEmpty ? 'Learner' : learnerName.trim();
    final firstName = name.split(' ').first;
    final longDate = _formatLongDate(now);
    final course = activeCourse;
    final hasActiveCourse = course != null && !course.isEmpty;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1A2060),
                  const Color(0xFF0D0F1A),
                ]
              : [
                  SumAcademyTheme.brandBlue,
                  SumAcademyTheme.brandBlueDarker,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: SumAcademyTheme.brandBlue.withOpacityFloat(0.3),
            blurRadius: 24.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30.r,
            right: -20.r,
            child: _FloatingCircle(
              size: 180.r,
              color: SumAcademyTheme.white.withOpacityFloat(0.06),
              xOffset: -240.w,
              yOffset: 120.h,
              duration: const Duration(seconds: 12),
            ),
          ),
          Positioned(
            bottom: -40.r,
            left: 60.w,
            child: _FloatingCircle(
              size: 140.r,
              color: SumAcademyTheme.white.withOpacityFloat(0.04),
              xOffset: 180.w,
              yOffset: -100.h,
              duration: const Duration(seconds: 15),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: SumAcademyTheme.white.withOpacityFloat(0.15),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        longDate,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: SumAcademyTheme.white.withOpacityFloat(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Text(
                  greeting,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SumAcademyTheme.white.withOpacityFloat(0.75),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  firstName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: SumAcademyTheme.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                ),
                SizedBox(height: 20.h),
                _HeroActionChip(
                  label: hasActiveCourse ? 'Continue Learning' : 'Explore Classes',
                  icon: hasActiveCourse
                      ? Icons.play_arrow_rounded
                      : Icons.explore_rounded,
                  onTap: () {
                    if (hasActiveCourse) {
                      Get.to(
                        () => StudentCourseDetailView(
                          courseId: course.courseId,
                          title: course.title,
                          teacher: course.teacher,
                          progress: course.progress,
                          nextLecture: course.nextLecture,
                        ),
                      );
                    } else {
                      final shell = Get.isRegistered<StudentShellController>()
                          ? Get.find<StudentShellController>()
                          : null;
                      if (shell != null) {
                        shell.setActiveLabel('Explore Classes');
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Premium Action Button ─────────────────────────────────────────────────────

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
            SumAcademyTheme.accentOrange,
            SumAcademyTheme.accentOrangeDark,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: SumAcademyTheme.accentOrange.withOpacityFloat(0.3),
            blurRadius: 16.r,
            offset: Offset(0, 8.h),
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
                Icon(
                  Icons.person_outline_rounded,
                  color: SumAcademyTheme.white,
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
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
                  size: 16.sp,
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

// ── Stats Grid ────────────────────────────────────────────────────────────────

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
                label: 'Enrolled',
                value: enrolled.toString(),
                accent: SumAcademyTheme.brandBlue,
                icon: Icons.class_rounded,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _StatCard(
                label: 'Completed',
                value: completed.toString(),
                accent: SumAcademyTheme.success,
                icon: Icons.check_circle_rounded,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Quizzes',
                value: certificates.toString(), // The underlying variables will be updated later by Dev
                accent: const Color(0xFF7C3AED),
                icon: Icons.quiz_rounded,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _StatCard(
                label: 'Tests',
                value: learningDays.toString(), // The underlying variables will be updated later by Dev
                accent: SumAcademyTheme.accentOrange,
                icon: Icons.fact_check_rounded,
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
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface =
        isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border =
        isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: border),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: SumAcademyTheme.darkBase.withOpacityFloat(0.05),
              blurRadius: 16.r,
              offset: Offset(0, 8.h),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              color: accent.withOpacityFloat(0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20.sp, color: accent),
          ),
          SizedBox(height: 14.h),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  height: 1.0,
                ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor.withOpacityFloat(0.55),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Active Course Card ────────────────────────────────────────────────────────

class _ActiveCourseCard extends StatelessWidget {
  final ActiveCourseInfo course;

  const _ActiveCourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface =
        isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border =
        isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;
    final progressPercent = (course.progress * 100).clamp(0, 100).round();

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: border),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: SumAcademyTheme.brandBlue.withOpacityFloat(0.08),
              blurRadius: 22.r,
              offset: Offset(0, 12.h),
            ),
        ],
      ),
      child: Column(
        children: [
          // Top gradient banner
          Container(
            height: 6.h,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  SumAcademyTheme.brandBlue,
                  SumAcademyTheme.brandBlueDarker,
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(18.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72.r,
                  height: 72.r,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        SumAcademyTheme.brandBluePale,
                        SumAcademyTheme.brandBlueLight.withOpacityFloat(0.45),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: SumAcademyTheme.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color:
                              SumAcademyTheme.brandBlue.withOpacityFloat(0.2),
                          blurRadius: 8.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: 24.sp,
                      color: SumAcademyTheme.brandBlue,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: SumAcademyTheme.brandBluePale,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'ACTIVE COURSE',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: SumAcademyTheme.brandBlue,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                  ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        course.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        course.teacher.isEmpty ? 'Teacher' : course.teacher,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: textColor.withOpacityFloat(0.60),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 18.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: LinearProgressIndicator(
                          value: course.progress,
                          minHeight: 8.h,
                          backgroundColor: isDark
                              ? SumAcademyTheme.darkElevated
                              : SumAcademyTheme.brandBluePale,
                          valueColor: const AlwaysStoppedAnimation(
                            SumAcademyTheme.brandBlue,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      '$progressPercent%',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: SumAcademyTheme.brandBlue,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // Next lecture
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isDark
                        ? SumAcademyTheme.darkElevated
                        : SumAcademyTheme.surfaceTertiary,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.play_circle_outline_rounded,
                        size: 14.sp,
                        color: textColor.withOpacityFloat(0.55),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          'Next: ${course.nextLecture}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: textColor.withOpacityFloat(0.65),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
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
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    icon: Icon(Icons.play_arrow_rounded, size: 18.sp),
                    label: Text(
                      'Continue Learning',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: SumAcademyTheme.white,
                            fontWeight: FontWeight.w600,
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

// ── Active Course Empty State ─────────────────────────────────────────────────

class _ActiveCourseEmptyState extends StatelessWidget {
  const _ActiveCourseEmptyState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface =
        isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border =
        isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: border),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: SumAcademyTheme.darkBase.withOpacityFloat(0.05),
              blurRadius: 14.r,
              offset: Offset(0, 8.h),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 66.r,
            height: 66.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  SumAcademyTheme.brandBluePale,
                  SumAcademyTheme.brandBlueLight.withOpacityFloat(0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.menu_book_rounded,
              color: SumAcademyTheme.brandBlue,
              size: 30.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No active course yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Explore courses and start learning to see progress here.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textColor.withOpacityFloat(0.60),
                        height: 1.45,
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

// ── Section Header Row ────────────────────────────────────────────────────────

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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: SumAcademyTheme.brandBlue,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        GestureDetector(
          onTap: onViewAll,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: SumAcademyTheme.brandBluePale,
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Text(
              'View all',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: SumAcademyTheme.brandBlue,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Recent Course Card ────────────────────────────────────────────────────────

class _RecentCourseCard extends StatelessWidget {
  final Course course;

  const _RecentCourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface =
        isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border =
        isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;
    final progressPercent = (course.progress * 100).clamp(0, 100).round();

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: border),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: SumAcademyTheme.darkBase.withOpacityFloat(0.04),
              blurRadius: 12.r,
              offset: Offset(0, 6.h),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              color: course.accent.withOpacityFloat(0.12),
              borderRadius: BorderRadius.circular(16.r),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.menu_book_rounded,
              color: course.accent,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 14.w),
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
                        height: 1.25,
                      ),
                ),
                SizedBox(height: 4.h),
                Text(
                  course.subtitle.isEmpty ? 'In progress' : course.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textColor.withOpacityFloat(0.55),
                      ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: LinearProgressIndicator(
                          value: course.progress,
                          minHeight: 6.h,
                          backgroundColor: isDark
                              ? SumAcademyTheme.darkElevated
                              : SumAcademyTheme.brandBluePale,
                          valueColor:
                              AlwaysStoppedAnimation(course.accent),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: course.accent.withOpacityFloat(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        '$progressPercent%',
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: course.accent,
                                  fontWeight: FontWeight.w700,
                                ),
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

// ── Empty Courses Card ────────────────────────────────────────────────────────

class _EmptyCoursesCard extends StatelessWidget {
  const _EmptyCoursesCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface =
        isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border =
        isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: border),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: SumAcademyTheme.darkBase.withOpacityFloat(0.05),
              blurRadius: 16.r,
              offset: Offset(0, 10.h),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58.r,
                height: 58.r,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      SumAcademyTheme.brandBluePale,
                      SumAcademyTheme.brandBlueLight.withOpacityFloat(0.45),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.school_rounded,
                  color: SumAcademyTheme.brandBlue,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'No classes enrolled yet.',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            'Explore classes to start learning and track your progress here.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor.withOpacityFloat(0.65),
                  height: 1.45,
                ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final shell = Get.isRegistered<StudentShellController>()
                    ? Get.find<StudentShellController>()
                    : null;
                if (shell != null) {
                  shell.setActiveLabel('Explore Classes');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SumAcademyTheme.brandBlue,
                foregroundColor: SumAcademyTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(SumAcademyTheme.radiusButton.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 13.h),
                elevation: 0,
              ),
              child: const Text('Explore Classes'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Chip (kept for backward compat) ─────────────────────────────────────

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
      constraints: BoxConstraints(minHeight: 32.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusButton.r),
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

// ── Hero Action Chip ──────────────────────────────────────────────────────────

class _HeroActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _HeroActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusButton.r),
        child: Container(
          constraints: BoxConstraints(minHeight: 36.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: SumAcademyTheme.white.withOpacityFloat(0.15),
            borderRadius:
                BorderRadius.circular(SumAcademyTheme.radiusButton.r),
            border: Border.all(
                color: SumAcademyTheme.white.withOpacityFloat(0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  color: SumAcademyTheme.white.withOpacityFloat(0.95),
                  size: 16.sp),
              SizedBox(width: 6.w),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: SumAcademyTheme.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(width: 4.w),
              Icon(Icons.arrow_forward_rounded,
                  color: SumAcademyTheme.white.withOpacityFloat(0.8),
                  size: 14.sp),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Utility functions ─────────────────────────────────────────────────────────

String _greetingForHour(int hour) {
  if (hour < 12) return 'Good morning,';
  if (hour < 17) return 'Good afternoon,';
  if (hour < 21) return 'Good evening,';
  return 'Good night,';
}

String _formatLongDate(DateTime date) {
  final weekday = _weekdayName(date.weekday);
  final month = _monthName(date.month);
  final day = date.day.toString().padLeft(2, '0');
  return '$weekday, $month $day';
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
