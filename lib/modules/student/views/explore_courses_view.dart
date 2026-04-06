import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/student/controllers/student_explore_courses_controller.dart';
import 'package:sum_academy/modules/student/controllers/student_shell_controller.dart';
import 'package:sum_academy/modules/student/widgets/explore_course_card.dart';
import 'package:sum_academy/modules/student/views/student_checkout_view.dart';

class ExploreCoursesView extends GetView<StudentExploreCoursesController> {
  const ExploreCoursesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Obx(() {
      return RefreshIndicator(
        color: SumAcademyTheme.brandBlue,
        onRefresh: controller.refresh,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            _HeaderRow(textColor: textColor),
            SizedBox(height: 18.h),
            _SearchField(controller: controller),
            SizedBox(height: 14.h),
            _FilterChips(controller: controller),
            SizedBox(height: 16.h),
            if (controller.isLoading.value)
              const _CoursesSkeleton()
            else if (controller.filteredCourses.isEmpty)
              const _EmptyState()
            else
              Column(
                children: controller.filteredCourses
                    .map(
                      (course) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: ExploreCourseCard(
                          course: course,
                          onEnroll: () async {
                            if (course.isEnrolled) {
                              final shell =
                                  Get.isRegistered<StudentShellController>()
                                      ? Get.find<StudentShellController>()
                                      : null;
                              if (shell != null) {
                                shell.setActiveLabel('My Courses');
                              }
                              return;
                            }
                            Get.to(() => StudentCheckoutView(course: course));
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      );
    });
  }
}

class _HeaderRow extends StatelessWidget {
  final Color textColor;

  const _HeaderRow({required this.textColor});

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
              size: 20.sp,
              color: textColor.withOpacityFloat(0.7),
            ),
          ),
        if (showMenu) SizedBox(width: 6.w),
        Expanded(
          child: Text(
            'Explore Courses',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final StudentExploreCoursesController controller;

  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.searchController,
      decoration: InputDecoration(
        hintText: 'Search courses to explore',
        prefixIcon: Icon(Icons.search, size: 20.sp),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final StudentExploreCoursesController controller;

  const _FilterChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final options = controller.filterOptions;
      final active = controller.activeFilter.value;
      return Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: options.map((filter) {
          final isSelected = filter == active;
          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (_) => controller.setFilter(filter),
            selectedColor: SumAcademyTheme.brandBluePale,
            labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? SumAcademyTheme.brandBlue
                      : SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                  fontWeight: FontWeight.w600,
                ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.r),
              side: BorderSide(
                color: isSelected
                    ? SumAcademyTheme.brandBlue
                    : SumAcademyTheme.brandBluePale,
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(
          color: isDark
              ? SumAcademyTheme.darkBorder
              : SumAcademyTheme.brandBluePale,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.menu_book_rounded, color: SumAcademyTheme.brandBlue),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'No courses available yet. Please check back soon.',
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

class _CoursesSkeleton extends StatelessWidget {
  const _CoursesSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base =
        isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.surfaceTertiary;
    final cardColor =
        isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border =
        isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale;

    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                _SkeletonBox(size: 58.r, radius: 16.r, color: base),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonLine(width: 160.w, height: 12.h, color: base),
                      SizedBox(height: 8.h),
                      _SkeletonLine(width: 220.w, height: 10.h, color: base),
                      SizedBox(height: 8.h),
                      _SkeletonLine(width: 120.w, height: 8.h, color: base),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const _SkeletonLine({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return _SkeletonBox(
      width: width,
      height: height,
      radius: 12.r,
      color: color,
    );
  }
}

class _SkeletonBox extends StatefulWidget {
  final double? width;
  final double? height;
  final double? size;
  final double radius;
  final Color color;

  const _SkeletonBox({
    this.width,
    this.height,
    this.size,
    required this.radius,
    required this.color,
  });

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.color;
    final highlight = Color.lerp(base, SumAcademyTheme.white, 0.55) ?? base;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final color = Color.lerp(base, highlight, _controller.value) ?? base;
        return Container(
          width: widget.size ?? widget.width,
          height: widget.size ?? widget.height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        );
      },
    );
  }
}
