import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_ui.dart';
import 'package:sum_academy/modules/maintenance/controllers/maintenance_controller.dart';

class MaintenanceView extends GetView<MaintenanceController> {
  const MaintenanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? SumAcademyTheme.darkBase : SumAcademyTheme.surfaceSecondary;
    final surface = isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border = AdminUi.borderColor(context);
    final textColor = isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;
    final muted = textColor.withOpacityFloat(0.65);
    final highlightBg = isDark ? SumAcademyTheme.darkElevated : SumAcademyTheme.brandBluePale.withOpacityFloat(0.4);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Background Glow Effects
          Positioned(
            top: -100.h,
            left: -50.w,
            child: Container(
              width: 300.w,
              height: 300.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    SumAcademyTheme.brandBlue.withOpacityFloat(isDark ? 0.2 : 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50.h,
            right: -100.w,
            child: Container(
              width: 400.w,
              height: 400.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    SumAcademyTheme.accentOrange.withOpacityFloat(isDark ? 0.15 : 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 480.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo
                      Container(
                        width: 72.w,
                        height: 72.w,
                        decoration: BoxDecoration(
                          color: surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: border, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: SumAcademyTheme.brandBlue.withOpacityFloat(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          image: const DecorationImage(
                            image: AssetImage('assets/logo.jpeg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 32.h),
                      
                      // Premium Card
                      Container(
                        padding: EdgeInsets.all(32.r),
                        decoration: AdminUi.cardDecoration(
                          surface: surface,
                          border: border,
                          radius: 28,
                          showShadow: true,
                        ),
                        child: Obx(() {
                          final status = controller.status.value;
                          final message = status.message.trim().isEmpty
                              ? 'We are upgrading our systems to provide you with a better experience. We will be back online shortly!'
                              : status.message.trim();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Construction Icon in Glow
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 80.r,
                                    height: 80.r,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: SumAcademyTheme.accentOrange.withOpacityFloat(0.1),
                                    ),
                                  ),
                                  Icon(
                                    Icons.engineering_rounded,
                                    size: 42.sp,
                                    color: SumAcademyTheme.accentOrange,
                                  ),
                                ],
                              ),
                              SizedBox(height: 24.h),
                              Text(
                                'System Update',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: textColor,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'Scheduled Maintenance in Progress',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: muted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 32.h),
                              
                              // specific message container
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                                decoration: BoxDecoration(
                                  color: highlightBg,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4.w,
                                      height: 40.h,
                                      decoration: BoxDecoration(
                                        color: SumAcademyTheme.brandBlue,
                                        borderRadius: BorderRadius.circular(4.r),
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: Text(
                                        message,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: textColor,
                                              height: 1.5,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              SizedBox(height: 40.h),
                              
                              // Buttons
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: controller.isLoading.value 
                                      ? null 
                                      : () => controller.loadStatus(),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 16.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                    elevation: 0,
                                  ),
                                  icon: controller.isLoading.value 
                                    ? SizedBox(
                                        width: 20.r, height: 20.r,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white,
                                        ),
                                      )
                                    : Icon(Icons.refresh_rounded, size: 20.sp),
                                  label: Text(
                                    controller.isLoading.value ? 'Checking...' : 'Check Status Again',
                                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  onPressed: controller.logout,
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 16.h),
                                    foregroundColor: muted,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Back to Log In',
                                    style: TextStyle(
                                      fontSize: 15.sp, 
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                      
                      SizedBox(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8.r,
                            height: 8.r,
                            decoration: const BoxDecoration(
                              color: SumAcademyTheme.warning,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Status: Active Maintenance Mode',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: muted,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
