import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/modules/admin/controllers/admin_payments_controller.dart';
import 'package:sum_academy/modules/admin/widgets/payments/payment_list_card.dart';

class PaymentsList extends StatelessWidget {
  final List<AdminPaymentRow> payments;
  final Color surface;
  final Color textColor;
  final bool isDark;

  const PaymentsList({
    super.key,
    required this.payments,
    required this.surface,
    required this.textColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: payments.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final payment = payments[index];
        return PaymentListCard(
          payment: payment,
          surface: surface,
          textColor: textColor,
        );
      },
    );
  }
}
