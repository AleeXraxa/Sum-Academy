import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/student/controllers/student_courses_controller.dart';
import 'package:sum_academy/modules/student/models/student_class.dart';
import 'package:sum_academy/modules/student/models/student_course.dart';
import 'package:sum_academy/modules/student/views/student_course_detail_view.dart';

class MyCoursesView extends GetView<StudentCoursesController> {
  const MyCoursesView({super.key});

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
            else if (controller.classes.isEmpty)
              const _EmptyState()
            else ...[
              _ClassesSection(controller: controller),
              SizedBox(height: 20.h),
              if (controller.filteredCourses.isEmpty)
                const _EmptyState()
              else ...[
                _SelectedClassHeader(controller: controller),
                SizedBox(height: 12.h),
                _ClassCoursesGrid(
                  courses: controller.filteredCourses,
                  onContinue: (course) {
                    Get.to(
                      () => StudentCourseDetailView(
                        courseId: course.id,
                        title: course.title,
                        teacher: course.teacher,
                        progress: course.progress,
                        nextLecture: course.nextLecture,
                      ),
                    );
                  },
                ),
              ],
            ],
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
            'My Classes',
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
  final StudentCoursesController controller;

  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.searchController,
      decoration: InputDecoration(
        hintText: 'Search your classes or courses',
        prefixIcon: Icon(Icons.search, size: 20.sp),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final StudentCoursesController controller;

  const _FilterChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'In Progress', 'Completed'];
    return Obx(() {
      final active = controller.activeFilter.value;
      return Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: filters.map((filter) {
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
              'No classes found yet. Enroll to get started.',
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

class _ClassesSection extends StatelessWidget {
  final StudentCoursesController controller;

  const _ClassesSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final classes = controller.classes;
      if (classes.isEmpty) {
        return const SizedBox.shrink();
      }
      final selectedId = controller.selectedClassId.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enrolled Classes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: SumAcademyTheme.darkBase,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 200.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: classes.length,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                final item = classes[index];
                final isActive = item.id == selectedId;
                return _ClassCard(
                  item: item,
                  isActive: isActive,
                  onTap: () => controller.selectClass(item.id),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _ClassCard extends StatelessWidget {
  final StudentEnrolledClass item;
  final bool isActive;
  final VoidCallback onTap;

  const _ClassCard({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isActive
        ? SumAcademyTheme.darkBase
        : SumAcademyTheme.brandBluePale;
    final progressPercent = (item.progress * 100).clamp(0, 100).round();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: 260.w,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: SumAcademyTheme.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: borderColor, width: isActive ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.thumbnailUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Image.network(
                  item.thumbnailUrl,
                  height: 44.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              )
            else
              Container(
                height: 44.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: SumAcademyTheme.brandBluePale,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text(
                  item.code.isEmpty ? 'CLASS' : item.code,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: SumAcademyTheme.brandBlue,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            SizedBox(height: 10.h),
            Text(
              item.code.isEmpty ? item.id : item.code,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 6.h),
            Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: SumAcademyTheme.darkBase,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            SizedBox(height: 6.h),
            Text(
              item.teacher.isEmpty ? 'Instructor' : item.teacher,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                  ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Paid subjects: ${item.paidCourses}/${item.totalCourses}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                  ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: LinearProgressIndicator(
                      value: item.progress,
                      minHeight: 6.h,
                      backgroundColor: SumAcademyTheme.brandBluePale,
                      valueColor: const AlwaysStoppedAnimation(
                        SumAcademyTheme.brandBlue,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '$progressPercent%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedClassHeader extends StatelessWidget {
  final StudentCoursesController controller;

  const _SelectedClassHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedClass;
      if (selected == null) return const SizedBox.shrink();
      final title =
          '${selected.code.isEmpty ? selected.id : selected.code} - ${selected.name}';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: SumAcademyTheme.darkBase,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 6.h),
          Text(
            '${selected.courses.length} course(s) in this class',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                ),
          ),
        ],
      );
    });
  }
}

class _ClassCoursesGrid extends StatelessWidget {
  final List<StudentCourse> courses;
  final void Function(StudentCourse course) onContinue;

  const _ClassCoursesGrid({
    required this.courses,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 700 ? 2 : 1;
    final aspectRatio = width >= 700 ? 1.5 : 1.15;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courses.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: aspectRatio,
      ),
      itemBuilder: (context, index) {
        final course = courses[index];
        return _ClassCourseCard(
          course: course,
          onContinue: () => onContinue(course),
        );
      },
    );
  }
}

class _ClassCourseCard extends StatelessWidget {
  final StudentCourse course;
  final VoidCallback onContinue;

  const _ClassCourseCard({
    required this.course,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercent = (course.progress * 100).clamp(0, 100).round();

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.white,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
        boxShadow: [
          BoxShadow(
            color: SumAcademyTheme.darkBase.withOpacityFloat(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: SumAcademyTheme.brandBluePale,
              borderRadius: BorderRadius.circular(16.r),
              image: course.thumbnailUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(course.thumbnailUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: course.thumbnailUrl.isEmpty
                ? Text(
                    course.category.isEmpty ? 'Subject' : course.category,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: SumAcademyTheme.brandBlue,
                          fontWeight: FontWeight.w600,
                        ),
                  )
                : null,
          ),
          SizedBox(height: 12.h),
          Text(
            course.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: SumAcademyTheme.darkBase,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 4.h),
          Text(
            course.teacher.isEmpty ? 'Instructor' : course.teacher,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                ),
          ),
          if (course.category.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              course.category,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                  ),
            ),
          ],
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: LinearProgressIndicator(
                    value: course.progress,
                    minHeight: 6.h,
                    backgroundColor: SumAcademyTheme.brandBluePale,
                    valueColor: const AlwaysStoppedAnimation(
                      SumAcademyTheme.brandBlue,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '$progressPercent%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                    ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: SumAcademyTheme.brandBlue,
                foregroundColor: SumAcademyTheme.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: Text(course.isCompleted ? 'Review' : 'Continue'),
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
                _SkeletonBox(size: 54.r, radius: 16.r, color: base),
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
