import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/controllers/admin_controller.dart';
import 'package:sum_academy/modules/admin/widgets/header/admin_header_row.dart';

class AdminPlaceholderView extends StatelessWidget {
  final AdminController controller;
  final Color textColor;
  final Color surface;
  final bool isDark;
  final String userName;
  final String title;
  final IconData icon;
  final bool isSearchExpanded;

  const AdminPlaceholderView({
    super.key,
    required this.controller,
    required this.textColor,
    required this.surface,
    required this.isDark,
    required this.userName,
    required this.title,
    required this.icon,
    required this.isSearchExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
      children: [
        AdminHeaderRow(
          textColor: textColor,
          userName: userName,
          isSearchExpanded: isSearchExpanded,
          onSearchTap: controller.toggleSearch,
          onSearchClose: controller.closeSearch,
          searchController: controller.searchController,
        ),
        SizedBox(height: 18.h),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
            border: Border.all(
              color: isDark
                  ? SumAcademyTheme.darkBorder
                  : SumAcademyTheme.brandBluePale,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: SumAcademyTheme.brandBluePale,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(icon, color: SumAcademyTheme.brandBlue),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  '$title module will appear here.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor.withOpacityFloat(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
