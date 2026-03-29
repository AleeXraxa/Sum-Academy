import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';

Future<bool> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  Color? confirmColor,
  IconData icon = Icons.warning_rounded,
  Color? iconColor,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) => _ConfirmationDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      confirmColor: confirmColor,
      icon: icon,
      iconColor: iconColor,
    ),
  );
  return result ?? false;
}

class _ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final IconData icon;
  final Color? iconColor;

  const _ConfirmationDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.confirmColor,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedConfirm = confirmColor ?? SumAcademyTheme.error;
    final resolvedIcon = iconColor ?? SumAcademyTheme.error;

    return Dialog(
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
                color: resolvedConfirm.withOpacityFloat(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: resolvedIcon, size: 28.sp),
            ),
            SizedBox(height: 14.h),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: SumAcademyTheme.darkBase,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SumAcademyTheme.darkBase,
                      side: const BorderSide(
                        color: SumAcademyTheme.brandBluePale,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          SumAcademyTheme.radiusButton.r,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(cancelText),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: resolvedConfirm,
                      foregroundColor: SumAcademyTheme.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          SumAcademyTheme.radiusButton.r,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(confirmText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
