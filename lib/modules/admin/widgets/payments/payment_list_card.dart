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

class PaymentListCard extends StatelessWidget {
  final AdminPaymentRow payment;
  final Color surface;
  final Color textColor;

  const PaymentListCard({
    super.key,
    required this.payment,
    required this.surface,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = _statusStyle(payment.status);
    final muted = textColor.withOpacityFloat(0.6);
    final isPending = statusInfo.type == _PaymentStatus.pending;
    final amountLabel = _formatCurrency(payment.amount);
    final dateLabel = _formatDate(payment.createdAt);

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
                  color: payment.avatarColor.withOpacityFloat(0.16),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  payment.initials,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: payment.avatarColor,
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
                      payment.studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      payment.studentEmail.isNotEmpty
                          ? payment.studentEmail
                          : 'Student payment',
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
                amountLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: SumAcademyTheme.brandBlue,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (payment.method.isNotEmpty) ...[
                SizedBox(width: 10.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: SumAcademyTheme.brandBluePale,
                    borderRadius: BorderRadius.circular(
                      SumAcademyTheme.radiusPill.r,
                    ),
                  ),
                  child: Text(
                    payment.method,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: SumAcademyTheme.brandBlue,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
              const Spacer(),
              if (dateLabel.isNotEmpty)
                Text(
                  dateLabel,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: muted),
                ),
            ],
          ),
          if (payment.reference.isNotEmpty ||
              payment.courseTitle.isNotEmpty ||
              payment.className.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Row(
              children: [
                if (payment.reference.isNotEmpty)
                  Expanded(
                    child: Text(
                      'Ref: ${payment.reference}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: muted),
                    ),
                  ),
                if (payment.reference.isEmpty)
                  Expanded(
                    child: Text(
                      payment.courseTitle.isNotEmpty
                          ? payment.courseTitle
                          : payment.className,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: muted),
                    ),
                  ),
              ],
            ),
          ],
          SizedBox(height: 12.h),
          if (isPending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _confirmVerify(context, approve: false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SumAcademyTheme.error,
                      side: BorderSide(
                        color: SumAcademyTheme.error.withOpacityFloat(0.4),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _confirmVerify(context, approve: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SumAcademyTheme.success,
                      foregroundColor: SumAcademyTheme.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Icon(
                  statusInfo.type == _PaymentStatus.approved
                      ? Icons.verified_rounded
                      : Icons.block_rounded,
                  color: statusInfo.color,
                  size: 18.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  statusInfo.type == _PaymentStatus.approved
                      ? 'Payment verified'
                      : 'Payment rejected',
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

  Future<void> _confirmVerify(BuildContext context,
      {required bool approve}) async {
    final controller = Get.find<AdminPaymentsController>();
    if (payment.id.trim().isEmpty) {
      await showErrorDialog(
        context,
        title: 'Verification Failed',
        message: 'Payment ID is missing. Please refresh and try again.',
      );
      return;
    }
    final action = approve ? 'approve' : 'reject';
    final confirmed = await showConfirmationDialog(
      context,
      title: approve ? 'Approve payment' : 'Reject payment',
      message: approve
          ? 'Mark this payment as approved?'
          : 'Mark this payment as rejected?',
      confirmText: approve ? 'Approve' : 'Reject',
      cancelText: 'Cancel',
      confirmColor: approve ? SumAcademyTheme.success : SumAcademyTheme.error,
      icon: approve ? Icons.check_circle_rounded : Icons.block_rounded,
      iconColor: approve ? SumAcademyTheme.success : SumAcademyTheme.error,
    );

    if (confirmed != true) return;

    final overlayContext = Get.context ?? context;
    showLoadingDialog(
      overlayContext,
      message: approve ? 'Approving payment...' : 'Rejecting payment...',
    );
    late final result;
    try {
      result = await controller.verifyPayment(
        paymentId: payment.id,
        action: action,
      );
    } finally {
      if (Navigator.of(overlayContext, rootNavigator: true).canPop()) {
        Navigator.of(overlayContext, rootNavigator: true).pop();
      }
    }

    if (result.isSuccess) {
      await showSuccessDialog(
        overlayContext,
        title: approve ? 'Payment Approved' : 'Payment Rejected',
        message: result.message,
      );
    } else {
      if (result.isNetworkError) {
        await showNoInternetDialogOnce(message: result.message);
        return;
      }
      await showErrorDialog(
        overlayContext,
        title: 'Verification Failed',
        message: result.message,
      );
    }
  }
}

enum _PaymentStatus { pending, approved, rejected }

class _StatusStyle {
  final String label;
  final Color color;
  final Color tone;
  final _PaymentStatus type;

  const _StatusStyle({
    required this.label,
    required this.color,
    required this.tone,
    required this.type,
  });
}

_StatusStyle _statusStyle(String status) {
  final normalized = status.toLowerCase();
  if (normalized.contains('approve') || normalized.contains('paid')) {
    return const _StatusStyle(
      label: 'Approved',
      color: SumAcademyTheme.success,
      tone: SumAcademyTheme.successLight,
      type: _PaymentStatus.approved,
    );
  }
  if (normalized.contains('reject') ||
      normalized.contains('fail') ||
      normalized.contains('cancel')) {
    return const _StatusStyle(
      label: 'Rejected',
      color: SumAcademyTheme.error,
      tone: SumAcademyTheme.errorLight,
      type: _PaymentStatus.rejected,
    );
  }
  if (normalized.contains('review')) {
    return const _StatusStyle(
      label: 'Under Review',
      color: SumAcademyTheme.warning,
      tone: SumAcademyTheme.warningLight,
      type: _PaymentStatus.pending,
    );
  }
  return const _StatusStyle(
    label: 'Pending',
    color: SumAcademyTheme.warning,
    tone: SumAcademyTheme.warningLight,
    type: _PaymentStatus.pending,
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
