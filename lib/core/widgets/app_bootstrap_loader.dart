import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';

class AppBootstrapLoader extends StatelessWidget {
  final String message;

  const AppBootstrapLoader({
    super.key,
    this.message = 'Loading your workspace...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 28.w),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
        decoration: BoxDecoration(
          color: SumAcademyTheme.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: SumAcademyTheme.darkBase.withOpacityFloat(0.08),
              blurRadius: 24.r,
              offset: Offset(0, 16.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78.r,
              height: 78.r,
              decoration: BoxDecoration(
                color: SumAcademyTheme.brandBluePale,
                borderRadius: BorderRadius.circular(24.r),
              ),
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Image.asset(
                  'assets/logo.jpeg',
                  width: 60.r,
                  height: 60.r,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'SUM ACADEMY',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: SumAcademyTheme.darkBase.withOpacityFloat(0.55),
                    letterSpacing: 3.2,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 10.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SumAcademyTheme.darkBase.withOpacityFloat(0.8),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 18.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: LinearProgressIndicator(
                minHeight: 6.h,
                backgroundColor: SumAcademyTheme.brandBluePale,
                valueColor: const AlwaysStoppedAnimation(
                  SumAcademyTheme.brandBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
