import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';

class DialogLabel extends StatelessWidget {
  final String text;

  const DialogLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: SumAcademyTheme.darkBase,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextInputAction textInputAction;
  final Widget? suffixIcon;

  const DialogTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(SumAcademyTheme.radiusInput.r);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: SumAcademyTheme.darkBase.withOpacityFloat(0.45),
          fontSize: 12.sp,
        ),
        filled: true,
        fillColor: SumAcademyTheme.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: SumAcademyTheme.brandBluePale),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: SumAcademyTheme.brandBluePale),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(
            color: SumAcademyTheme.brandBlue,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class DialogDropdown extends StatelessWidget {
  final String? value;
  final String hintText;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const DialogDropdown({
    super.key,
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(SumAcademyTheme.radiusInput.r);

    return CustomDropdown<String>(
      items: items,
      initialItem: value,
      hintText: hintText,
      onChanged: onChanged,
      closedHeaderPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      expandedHeaderPadding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: CustomDropdownDecoration(
        closedFillColor: SumAcademyTheme.white,
        expandedFillColor: SumAcademyTheme.white,
        closedBorder: Border.all(color: SumAcademyTheme.brandBluePale),
        expandedBorder: Border.all(
          color: SumAcademyTheme.brandBlue,
          width: 1.4,
        ),
        closedBorderRadius: borderRadius,
        expandedBorderRadius: borderRadius,
        hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: SumAcademyTheme.darkBase.withOpacityFloat(0.45),
          fontSize: 12.sp,
        ),
        headerStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: SumAcademyTheme.darkBase,
        ),
        listItemStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: SumAcademyTheme.darkBase,
        ),
        closedSuffixIcon: Icon(
          Icons.expand_more_rounded,
          size: 22.sp,
          color: SumAcademyTheme.darkBase,
        ),
        expandedSuffixIcon: Icon(
          Icons.expand_less_rounded,
          size: 22.sp,
          color: SumAcademyTheme.darkBase,
        ),
      ),
    );
  }
}

class DialogIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const DialogIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.r,
      height: 40.r,
      decoration: BoxDecoration(
        color: SumAcademyTheme.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20.sp, color: SumAcademyTheme.darkBase),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}
