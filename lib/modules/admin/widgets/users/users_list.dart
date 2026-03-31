import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/controllers/admin_controller.dart';
import 'package:sum_academy/modules/admin/widgets/users/user_list_card.dart';

class UsersList extends StatelessWidget {
  final List<AdminUserRow> users;
  final Color surface;
  final Color textColor;
  final bool isDark;

  const UsersList({
    super.key,
    required this.users,
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
      itemCount: users.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return UserListCard(
          user: users[index],
          surface: surface,
          borderColor: borderColor,
          textColor: textColor,
        );
      },
    );
  }
}
