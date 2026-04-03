import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';

class AdminUi {
  const AdminUi._();

  static const double cardRadiusValue = 18;

  static EdgeInsets pagePadding() =>
      EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h);

  static Color borderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale;
  }

  static BorderRadius cardRadius([double? radius]) {
    final value = radius ?? cardRadiusValue;
    return BorderRadius.circular(value.r);
  }

  static double cardRadiusR([double? radius]) {
    final value = radius ?? cardRadiusValue;
    return value.r;
  }

  static List<BoxShadow> cardShadow() => [
        BoxShadow(
          color: SumAcademyTheme.darkBase.withOpacityFloat(0.06),
          blurRadius: 18.r,
          offset: Offset(0, 10.h),
        ),
      ];

  static BoxDecoration cardDecoration({
    required Color surface,
    required Color border,
    double? radius,
    bool showShadow = true,
  }) {
    return BoxDecoration(
      color: surface,
      borderRadius: cardRadius(radius),
      border: Border.all(color: border),
      boxShadow: showShadow ? cardShadow() : [],
    );
  }

  static TextStyle? pageTitleStyle(BuildContext context, Color textColor) {
    return Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        );
  }

  static TextStyle? sectionTitleStyle(BuildContext context, Color textColor) {
    return Theme.of(context).textTheme.titleLarge?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        );
  }

  static TextStyle? subtitleStyle(BuildContext context, Color textColor) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor.withOpacityFloat(0.6),
        );
  }
}

class AdminSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool isPageHeader;
  final Color textColor;

  const AdminSectionHeader({
    super.key,
    required this.title,
    required this.textColor,
    this.subtitle,
    this.trailing,
    this.isPageHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = isPageHeader
        ? AdminUi.pageTitleStyle(context, textColor)
        : AdminUi.sectionTitleStyle(context, textColor);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                style: titleStyle,
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          SizedBox(height: 6.h),
          Text(
            subtitle!,
            style: AdminUi.subtitleStyle(context, textColor),
          ),
        ],
      ],
    );
  }
}

class AdminAddIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String tooltip;

  const AdminAddIconButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.add_rounded,
    this.tooltip = 'Add',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42.r,
      height: 42.r,
      decoration: BoxDecoration(
        color: SumAcademyTheme.brandBlue,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: SumAcademyTheme.brandBlue.withOpacityFloat(0.2),
            blurRadius: 14.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: SumAcademyTheme.white,
          size: 20.sp,
        ),
      ),
    );
  }
}
