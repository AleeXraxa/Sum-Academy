import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/home/models/live_session.dart';

class LiveSessionTile extends StatelessWidget {
  final LiveSession session;

  const LiveSessionTile({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale;
    final secondaryText =
        (isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase)
            .withOpacityFloat(0.65);
    final iconBg = isDark
        ? SumAcademyTheme.brandBlueDark.withOpacityFloat(0.28)
        : SumAcademyTheme.brandBluePale;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(
                SumAcademyTheme.radiusButton.r,
              ),
            ),
            child: Icon(
              Icons.video_call_outlined,
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
                  session.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${session.host} | ${session.time}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: secondaryText,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${session.seatsLeft} seats left',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: SumAcademyTheme.accentOrange,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 6.h),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  side: BorderSide(color: borderColor),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      SumAcademyTheme.radiusButton.r,
                    ),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                child: const Text('Join'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
