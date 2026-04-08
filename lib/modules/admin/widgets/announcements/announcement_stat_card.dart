import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_ui.dart';

class AnnouncementStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final Color surface;
  final Color textColor;

  const AnnouncementStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.accent,
    required this.surface,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: AdminUi.cardDecoration(
        surface: surface,
        border: AdminUi.borderColor(context),
        radius: 18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: accent,
                  letterSpacing: 2.2,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 10.h),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
