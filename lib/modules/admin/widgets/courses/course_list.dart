import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/models/admin_course.dart';
import 'package:sum_academy/modules/admin/widgets/courses/course_list_card.dart';

class CourseList extends StatelessWidget {
  final List<AdminCourse> courses;
  final Color surface;
  final Color textColor;
  final bool isDark;

  const CourseList({
    super.key,
    required this.courses,
    required this.surface,
    required this.textColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark
        ? SumAcademyTheme.darkBorder
        : SumAcademyTheme.brandBluePale;

    return ListView.separated(
      itemCount: courses.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return CourseListCard(
          course: courses[index],
          surface: surface,
          borderColor: borderColor,
          textColor: textColor,
        );
      },
    );
  }
}
