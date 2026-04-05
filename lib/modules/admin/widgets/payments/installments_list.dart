import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/modules/admin/controllers/admin_payments_controller.dart';
import 'package:sum_academy/modules/admin/widgets/payments/installment_list_card.dart';

class InstallmentsList extends StatelessWidget {
  final List<AdminInstallmentRow> plans;
  final Color surface;
  final Color textColor;
  final bool isDark;

  const InstallmentsList({
    super.key,
    required this.plans,
    required this.surface,
    required this.textColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: plans.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final plan = plans[index];
        return InstallmentListCard(
          plan: plan,
          surface: surface,
          textColor: textColor,
        );
      },
    );
  }
}
