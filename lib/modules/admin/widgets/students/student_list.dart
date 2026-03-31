import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/controllers/admin_student_controller.dart';
import 'package:sum_academy/modules/admin/widgets/students/student_list_card.dart';

class StudentList extends StatelessWidget {
  final List<AdminStudentRow> students;
  final Color surface;
  final Color textColor;
  final bool isDark;

  const StudentList({
    super.key,
    required this.students,
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
      itemCount: students.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return StudentListCard(
          student: students[index],
          surface: surface,
          borderColor: borderColor,
          textColor: textColor,
        );
      },
    );
  }
}
