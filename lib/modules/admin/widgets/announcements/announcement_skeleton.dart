import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_ui.dart';

class AnnouncementSkeletonList extends StatelessWidget {
  final int count;

  const AnnouncementSkeletonList({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Container(
            padding: EdgeInsets.all(16.r),
            decoration: AdminUi.cardDecoration(
              surface: SumAcademyTheme.white,
              border: AdminUi.borderColor(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120.w,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: SumAcademyTheme.surfaceTertiary,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  width: double.infinity,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: SumAcademyTheme.surfaceTertiary,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: SumAcademyTheme.surfaceTertiary,
                    borderRadius: BorderRadius.circular(10.r),
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
