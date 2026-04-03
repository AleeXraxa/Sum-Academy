import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/controllers/admin_controller.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_ui.dart';

class AdminStatCard extends StatelessWidget {
  final AdminStat stat;
  final Color surface;
  final Color textColor;

  const AdminStatCard({
    super.key,
    required this.stat,
    required this.surface,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final muted = textColor.withOpacityFloat(0.55);
    final tone = stat.tone ?? SumAcademyTheme.brandBluePale;
    final iconColor = stat.iconColor ?? SumAcademyTheme.brandBlue;
    final borderColor = iconColor.withOpacityFloat(0.35);

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: AdminUi.cardDecoration(
        surface: surface,
        border: borderColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: tone,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(stat.icon, color: iconColor, size: 20.sp),
          ),
          SizedBox(height: 12.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              stat.value,
              style: GoogleFonts.poppins(
                textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 20.sp,
                ),
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            stat.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
