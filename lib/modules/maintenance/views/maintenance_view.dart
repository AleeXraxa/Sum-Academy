import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/maintenance/controllers/maintenance_controller.dart';

class MaintenanceView extends GetView<MaintenanceController> {
  const MaintenanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? SumAcademyTheme.darkBase : SumAcademyTheme.surfaceSecondary;
    final surface = isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border = isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale;
    final textColor = isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;
    final muted = textColor.withOpacityFloat(0.7);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 22.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 520.w),
              child: Obx(() {
                final status = controller.status.value;
                final message = status.message.trim().isEmpty
                    ? 'We are performing a quick maintenance update. Please try again in a few minutes.'
                    : status.message.trim();

                return Container(
                  padding: EdgeInsets.all(18.r),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(color: border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacityFloat(isDark ? 0.25 : 0.06),
                        blurRadius: 26,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52.r,
                            height: 52.r,
                            decoration: BoxDecoration(
                              color: SumAcademyTheme.accentOrange.withOpacityFloat(0.14),
                              borderRadius: BorderRadius.circular(18.r),
                              border: Border.all(
                                color: SumAcademyTheme.accentOrange.withOpacityFloat(0.2),
                              ),
                            ),
                            child: Icon(
                              Icons.construction_rounded,
                              size: 26.sp,
                              color: SumAcademyTheme.accentOrange,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'Maintenance',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: muted,
                              height: 1.45,
                            ),
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        'Thanks for your patience. We will be back shortly.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: muted,
                            ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
