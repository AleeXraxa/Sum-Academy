import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/controllers/admin_controller.dart';
import 'package:sum_academy/modules/admin/widgets/header/admin_header_row.dart';
import 'package:sum_academy/modules/admin/widgets/users/add_user_dialog.dart';
import 'package:sum_academy/modules/admin/widgets/users/user_filter_chip.dart';
import 'package:sum_academy/modules/admin/widgets/users/users_list.dart';
import 'package:sum_academy/modules/auth/widgets/auth_text_field.dart';

class AdminUsersView extends StatelessWidget {
  final AdminController controller;
  final Color textColor;
  final Color surface;
  final bool isDark;
  final String userName;

  const AdminUsersView({
    super.key,
    required this.controller,
    required this.textColor,
    required this.surface,
    required this.isDark,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
      children: [
        AdminHeaderRow(
          textColor: textColor,
          userName: userName,
          isSearchExpanded: false,
          onSearchTap: controller.toggleSearch,
          onSearchClose: controller.closeSearch,
          searchController: controller.searchController,
          showSearch: false,
        ),
        SizedBox(height: 18.h),
        Row(
          children: [
            Expanded(
              child: Text(
                'User Management',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: SumAcademyTheme.brandBlue,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: IconButton(
                onPressed: () => showAddUserDialog(context),
                icon: Icon(
                  Icons.add_rounded,
                  color: SumAcademyTheme.white,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Obx(() {
          final selectedIndex = controller.userFilterIndex.value;
          return Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              for (var i = 0; i < controller.userFilters.length; i++)
                UserFilterChip(
                  label: controller.userFilters[i].label,
                  count: controller.userFilters[i].count,
                  isSelected: selectedIndex == i,
                  onTap: () => controller.setUserFilterIndex(i),
                ),
            ],
          );
        }),
        SizedBox(height: 14.h),
        AuthTextField(
          controller: controller.searchController,
          label: 'Search',
          hint: 'Search by email',
          icon: Icons.search_rounded,
          textInputAction: TextInputAction.search,
          onFieldSubmitted: (_) {},
        ),
        SizedBox(height: 16.h),
        UsersList(
          users: controller.users,
          surface: surface,
          textColor: textColor,
          isDark: isDark,
        ),
      ],
    );
  }
}
