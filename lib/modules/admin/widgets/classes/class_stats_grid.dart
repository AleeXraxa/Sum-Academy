import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_ui.dart';

class ClassStatsGrid extends StatelessWidget {
  final int totalClasses;
  final int activeClasses;
  final int totalStudents;
  final int upcomingClasses;
  final Color surface;
  final Color textColor;

  const ClassStatsGrid({
    super.key,
    required this.totalClasses,
    required this.activeClasses,
    required this.totalStudents,
    required this.upcomingClasses,
    required this.surface,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final stats = [
      _ClassStat(label: 'Total Classes', value: totalClasses.toString()),
      _ClassStat(label: 'Active Classes', value: activeClasses.toString()),
      _ClassStat(
        label: 'Total Students Enrolled',
        value: totalStudents.toString(),
      ),
      _ClassStat(label: 'Upcoming Classes', value: upcomingClasses.toString()),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, index) {
        return _ClassStatCard(
          stat: stats[index],
          surface: surface,
          textColor: textColor,
        );
      },
    );
  }
}

class _ClassStat {
  final String label;
  final String value;

  const _ClassStat({required this.label, required this.value});
}

class _ClassStatCard extends StatelessWidget {
  final _ClassStat stat;
  final Color surface;
  final Color textColor;

  const _ClassStatCard({
    required this.stat,
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stat.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor.withOpacityFloat(0.6),
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 10.h),
          Text(
            stat.value,
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
