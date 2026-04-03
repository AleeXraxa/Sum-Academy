import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_ui.dart';

class AdminFilterPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color surface;

  const AdminFilterPanel({
    super.key,
    required this.child,
    required this.surface,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(14.r),
      decoration: AdminUi.cardDecoration(
        surface: surface,
        border: AdminUi.borderColor(context),
        showShadow: false,
        radius: 18,
      ),
      child: child,
    );
  }
}
