import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/core/widgets/confirmation_dialog.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';
import 'package:sum_academy/modules/admin/controllers/admin_payments_controller.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_ui.dart';
import 'package:sum_academy/modules/admin/widgets/users/status_pill.dart';

class InstallmentListCard extends StatelessWidget {
  final AdminInstallmentRow plan;
  final Color surface;
  final Color textColor;

  const InstallmentListCard({
    super.key,
    required this.plan,
    required this.surface,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = _statusStyle(plan);
    final muted = textColor.withOpacityFloat(0.6);
    final remainingLabel = _formatCurrency(plan.remainingAmount);
    final totalLabel = _formatCurrency(plan.totalAmount);
    final isPaid = statusInfo.type == _InstallmentStatus.paid;
    final dueLabel = _formatDate(plan.nextDueDate);

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: AdminUi.cardDecoration(
        surface: surface,
        border: AdminUi.borderColor(context),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: plan.avatarColor.withOpacityFloat(0.16),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  plan.initials,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: plan.avatarColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      plan.studentEmail.isNotEmpty
                          ? plan.studentEmail
                          : 'Installment plan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              StatusPill(
                label: statusInfo.label,
                color: statusInfo.color,
                background: statusInfo.tone,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text(
                remainingLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: SumAcademyTheme.brandBlue,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              SizedBox(width: 8.w),
              Text(
                '/ $totalLabel',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: muted,
                    ),
              ),
              const Spacer(),
              if (dueLabel.isNotEmpty)
                Text(
                  'Due $dueLabel',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: muted),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.courseTitle.isNotEmpty
                      ? plan.courseTitle
                      : 'Plan ${plan.planId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: muted,
                      ),
                ),
              ),
              if (plan.numberOfInstallments > 0)
                Text(
                  '${plan.paidInstallments}/${plan.numberOfInstallments} paid',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: muted,
                      ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          if (!isPaid)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _confirmPay(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SumAcademyTheme.brandBlue,
                  side: const BorderSide(color: SumAcademyTheme.brandBluePale),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: const Text('Mark Next Installment Paid'),
              ),
            )
          else
            Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: SumAcademyTheme.success,
                  size: 18.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  'All installments paid',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: muted,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _confirmPay(BuildContext context) async {
    final controller = Get.find<AdminPaymentsController>();
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Mark installment paid',
      message: 'Mark the next unpaid installment as paid?',
      confirmText: 'Mark Paid',
      cancelText: 'Cancel',
      confirmColor: SumAcademyTheme.success,
      icon: Icons.check_circle_rounded,
      iconColor: SumAcademyTheme.success,
    );

    if (confirmed != true) return;

    final overlayContext = Get.context ?? context;
    showLoadingDialog(overlayContext, message: 'Updating installment...');
    late final result;
    try {
      result = await controller.markNextInstallmentPaid(plan);
    } finally {
      if (Navigator.of(overlayContext, rootNavigator: true).canPop()) {
        Navigator.of(overlayContext, rootNavigator: true).pop();
      }
    }

    if (result.isSuccess) {
      await showSuccessDialog(
        overlayContext,
        title: 'Installment Updated',
        message: result.message,
      );
    } else {
      if (result.isNetworkError) {
        await showNoInternetDialogOnce(message: result.message);
        return;
      }
      await showErrorDialog(
        overlayContext,
        title: 'Update Failed',
        message: result.message,
      );
    }
  }
}

enum _InstallmentStatus { pending, paid, overdue }

class _InstallmentStyle {
  final String label;
  final Color color;
  final Color tone;
  final _InstallmentStatus type;

  const _InstallmentStyle({
    required this.label,
    required this.color,
    required this.tone,
    required this.type,
  });
}

_InstallmentStyle _statusStyle(AdminInstallmentRow plan) {
  final normalized = plan.status.toLowerCase();
  if (normalized.contains('overdue') || normalized.contains('late')) {
    return const _InstallmentStyle(
      label: 'Overdue',
      color: SumAcademyTheme.error,
      tone: SumAcademyTheme.errorLight,
      type: _InstallmentStatus.overdue,
    );
  }
  if (normalized.contains('paid') ||
      normalized.contains('complete') ||
      (plan.remainingAmount <= 0 && plan.totalAmount > 0)) {
    return const _InstallmentStyle(
      label: 'Paid',
      color: SumAcademyTheme.success,
      tone: SumAcademyTheme.successLight,
      type: _InstallmentStatus.paid,
    );
  }
  return const _InstallmentStyle(
    label: 'Pending',
    color: SumAcademyTheme.warning,
    tone: SumAcademyTheme.warningLight,
    type: _InstallmentStatus.pending,
  );
}

String _formatCurrency(double value) {
  final fixed = value.toStringAsFixed(0);
  return 'PKR $fixed';
}

String _formatDate(DateTime? date) {
  if (date == null) return '';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final month = months[date.month - 1];
  return '$month ${date.day}, ${date.year}';
}
