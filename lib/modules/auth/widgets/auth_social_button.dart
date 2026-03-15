import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';

class AuthSocialButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const AuthSocialButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const _GoogleMark(),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: SumAcademyTheme.darkBase,
          side: const BorderSide(color: SumAcademyTheme.brandBluePale),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SumAcademyTheme.radiusButton.r),
          ),
        ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22.r,
      height: 22.r,
      decoration: BoxDecoration(
        color: SumAcademyTheme.white,
        shape: BoxShape.circle,
        border: Border.all(color: SumAcademyTheme.brandBluePale),
      ),
      alignment: Alignment.center,
      child: Text(
        'G',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(0xFF4285F4),
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

