import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';

Future<void> showLoadingDialog(
  BuildContext context, {
  String message = 'Processing your request...',
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: SumAcademyTheme.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 74.r,
                height: 74.r,
                decoration: BoxDecoration(
                  color: SumAcademyTheme.brandBluePale,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: Image.asset(
                    'assets/logo.jpeg',
                    width: 56.r,
                    height: 56.r,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'SUM ACADEMY',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.55),
                  letterSpacing: 3.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
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
      ),
    ),
  );
}

Future<void> showSuccessDialog(
  BuildContext context, {
  String title = 'Success',
  required String message,
}) {
  return _showStatusDialog(
    context,
    title: title,
    message: message,
    icon: Icons.check_circle_rounded,
    iconColor: SumAcademyTheme.success,
  );
}

Future<void> showErrorDialog(
  BuildContext context, {
  String title = 'Error',
  required String message,
}) {
  return _showStatusDialog(
    context,
    title: title,
    message: message,
    icon: Icons.error_rounded,
    iconColor: SumAcademyTheme.error,
  );
}

Future<void> _showStatusDialog(
  BuildContext context, {
  required String title,
  required String message,
  required IconData icon,
  required Color iconColor,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      backgroundColor: SumAcademyTheme.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(22.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                color: iconColor.withOpacityFloat(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28.sp),
            ),
            SizedBox(height: 14.h),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: SumAcademyTheme.darkBase,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: SumAcademyTheme.brandBlue,
                foregroundColor: SumAcademyTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    SumAcademyTheme.radiusButton.r,
                  ),
                ),
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    ),
  );
}
