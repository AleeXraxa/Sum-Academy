import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/controllers/admin_controller.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_ui.dart';

class AdminActionCard extends StatelessWidget {
  final AdminAction action;
  final Color surface;
  final Color textColor;

  const AdminActionCard({
    super.key,
    required this.action,
    required this.surface,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = AdminUi.borderColor(context);
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: AdminUi.cardDecoration(
        surface: surface,
        border: borderColor,
        showShadow: true,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: SumAcademyTheme.surfaceTertiary,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              action.icon,
              color: SumAcademyTheme.brandBlue,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  action.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor.withOpacityFloat(0.6),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: textColor.withOpacityFloat(0.4),
          ),
        ],
      ),
    );
  }
}
