import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/controllers/admin_teacher_controller.dart';
import 'package:sum_academy/modules/admin/widgets/teachers/teacher_list_card.dart';

class TeacherList extends StatelessWidget {
  final List<AdminTeacherRow> teachers;
  final Color surface;
  final Color textColor;
  final bool isDark;

  const TeacherList({
    super.key,
    required this.teachers,
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
      itemCount: teachers.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return TeacherListCard(
          teacher: teachers[index],
          surface: surface,
          borderColor: borderColor,
          textColor: textColor,
        );
      },
    );
  }
}
