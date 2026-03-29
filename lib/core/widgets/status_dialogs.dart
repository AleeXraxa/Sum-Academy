import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';

Future<void> showLoadingDialog(
  BuildContext context, {
  String message = 'Please wait...',
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: SumAcademyTheme.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Row(
            children: [
              SizedBox(
                width: 26.r,
                height: 26.r,
                child: const CircularProgressIndicator(strokeWidth: 2.4),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SumAcademyTheme.darkBase,
                    fontWeight: FontWeight.w600,
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
