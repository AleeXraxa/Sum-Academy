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
    barrierColor: Colors.black.withOpacity(0.12),
    builder: (context) => PopScope(
      canPop: false,
      child: _PremiumLoading(message: message),
    ),
  );
}

class _PremiumLoading extends StatefulWidget {
  final String message;
  const _PremiumLoading({required this.message});

  @override
  State<_PremiumLoading> createState() => _PremiumLoadingState();
}

class _PremiumLoadingState extends State<_PremiumLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;
    final surface = isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;

    return Center(
      child: Container(
        margin: EdgeInsets.all(32.r),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(
            color: isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale,
          ),
          boxShadow: [
            BoxShadow(
              color: SumAcademyTheme.darkBase.withOpacityFloat(isDark ? 0.3 : 0.12),
              blurRadius: 32.r,
              offset: Offset(0, 12.h),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo with Breathing & Rotation Effect
              Stack(
                alignment: Alignment.center,
                children: [
                  // Rotating Outer Ring
                  RotationTransition(
                    turns: _controller,
                    child: Container(
                      width: 82.r,
                      height: 82.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: SumAcademyTheme.brandBlue.withOpacityFloat(0.1),
                          width: 3.r,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(2.r),
                        child: CircularProgressIndicator(
                          strokeWidth: 3.r,
                          valueColor: const AlwaysStoppedAnimation(
                              SumAcademyTheme.brandBlue),
                        ),
                      ),
                    ),
                  ),
                  // Inner Breathing Shell
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _controller,
                        curve: Curves.easeInOutSine,
                      ),
                    ),
                    child: Container(
                      width: 64.r,
                      height: 64.r,
                      decoration: BoxDecoration(
                        color: SumAcademyTheme.brandBluePale,
                        borderRadius: BorderRadius.circular(22.r),
                        boxShadow: [
                          BoxShadow(
                            color: SumAcademyTheme.brandBlue.withOpacityFloat(0.15),
                            blurRadius: 10.r,
                            spreadRadius: 2.r,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18.r),
                        child: Image.asset(
                          'assets/logo.jpeg',
                          width: 52.r,
                          height: 52.r,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Text(
                'SUM ACADEMY',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: textColor.withOpacityFloat(0.4),
                      letterSpacing: 3.5,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              SizedBox(height: 12.h),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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

Future<void> showNoInternetDialog(
  BuildContext context, {
  String message =
      'No internet connection. Please check your connection and try again.',
}) {
  return _showStatusDialog(
    context,
    title: 'No Internet',
    message: message,
    icon: Icons.wifi_off_rounded,
    iconColor: SumAcademyTheme.accentOrange,
  );
}

Future<void> showDeviceBlockedDialog(
  BuildContext context, {
  String title = 'Access Blocked',
  String message =
      'Your device or IP does not match the registered device. Please contact support.',
}) {
  return _showStatusDialog(
    context,
    title: title,
    message: message,
    icon: Icons.lock_rounded,
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
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textColor = isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;
  final surface = isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;

  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.08),
    builder: (context) => Dialog(
      backgroundColor: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
        side: BorderSide(
          color: isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62.r,
              height: 62.r,
              decoration: BoxDecoration(
                color: iconColor.withOpacityFloat(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 30.sp),
            ),
            SizedBox(height: 18.h),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor.withOpacityFloat(0.65),
                    height: 1.4,
                  ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SumAcademyTheme.brandBlue,
                  foregroundColor: SumAcademyTheme.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
