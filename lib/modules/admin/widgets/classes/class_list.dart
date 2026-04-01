import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/models/admin_class.dart';
import 'package:sum_academy/modules/admin/widgets/classes/class_list_card.dart';

class ClassList extends StatelessWidget {
  final List<AdminClass> classes;
  final Color surface;
  final Color textColor;
  final bool isDark;

  const ClassList({
    super.key,
    required this.classes,
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
      itemCount: classes.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return ClassListCard(
          classItem: classes[index],
          surface: surface,
          borderColor: borderColor,
          textColor: textColor,
        );
      },
    );
  }
}
