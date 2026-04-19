import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/student/controllers/student_payments_controller.dart';
import 'package:sum_academy/modules/student/models/student_payment.dart';
import 'package:sum_academy/modules/student/widgets/student_notification_bell.dart';
import 'package:sum_academy/modules/student/widgets/student_dashboard_header.dart';

class StudentPaymentsView extends GetView<StudentPaymentsController> {
  const StudentPaymentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Obx(() {
      return RefreshIndicator(
        color: SumAcademyTheme.brandBlue,
        onRefresh: () => controller.fetchAll(force: true),
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            StudentDashboardHeader(subtitle: 'Payments'),
            SizedBox(height: 6.h),
            Text(
              'Track your transactions, installments, and invoices',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor.withOpacityFloat(0.6),
                  ),
            ),
            SizedBox(height: 16.h),
            _Tabs(controller: controller),
            SizedBox(height: 16.h),
            if (controller.isLoading.value)
              const _PaymentsSkeleton()
            else
              _PaymentsContent(controller: controller),
          ],
        ),
      );
    });
  }
}



class _Tabs extends StatelessWidget {
  final StudentPaymentsController controller;

  const _Tabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    const tabs = [
      'Transaction History',
      'Installment Plans',
      'Invoices',
    ];
    return Obx(() {
      return Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: tabs
            .map(
              (tab) => _TabChip(
                label: tab,
                isActive: controller.activeTab.value == tab,
                onTap: () => controller.setTab(tab),
              ),
            )
            .toList(),
      );
    });
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive
              ? SumAcademyTheme.brandBlue
              : SumAcademyTheme.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isActive
                ? SumAcademyTheme.brandBlue
                : SumAcademyTheme.brandBluePale,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isActive
                    ? SumAcademyTheme.white
                    : SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class _PaymentsContent extends StatelessWidget {
  final StudentPaymentsController controller;

  const _PaymentsContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    final active = controller.activeTab.value;
    if (active == 'Installment Plans') {
      return _InstallmentList(items: controller.installments);
    }
    if (active == 'Invoices') {
      return const _InvoicesEmpty();
    }
    return _TransactionList(items: controller.payments);
  }
}

class _TransactionList extends StatelessWidget {
  final List<StudentPaymentSummary> items;

  const _TransactionList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyState(
        message: 'No transactions found yet.',
        icon: Icons.receipt_long_rounded,
      );
    }
    return Column(
      children: items
          .map(
            (payment) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _TransactionCard(payment: payment),
            ),
          )
          .toList(),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final StudentPaymentSummary payment;

  const _TransactionCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final amountLabel = _formatPkr(payment.amount);
    final method = payment.method.isNotEmpty ? payment.method : 'Payment';
    final dateLabel = payment.createdAt == null
        ? ''
        : '${_formatDate(payment.createdAt!)}';
    final subtitle = dateLabel.isEmpty ? method : '$method | $dateLabel';

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.white,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
        boxShadow: [
          BoxShadow(
            color: SumAcademyTheme.darkBase.withOpacityFloat(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  payment.title.isNotEmpty ? payment.title : 'Course Payment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: SumAcademyTheme.darkBase,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text(
                amountLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: SumAcademyTheme.darkBase,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _StatusBadge(status: payment.statusLabel),
              const Spacer(),
              OutlinedButton(
                onPressed: null,
                child: const Text('Download Invoice'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InstallmentList extends StatelessWidget {
  final List<StudentInstallmentPlan> items;

  const _InstallmentList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyState(
        message: 'No installment plans found.',
        icon: Icons.timeline_rounded,
      );
    }
    return Column(
      children: items
          .map(
            (plan) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _InstallmentCard(plan: plan),
            ),
          )
          .toList(),
    );
  }
}

class _InstallmentCard extends StatelessWidget {
  final StudentInstallmentPlan plan;

  const _InstallmentCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final total = plan.totalAmount;
    final remaining = plan.remainingAmount;
    final progress = total <= 0 ? 0.0 : (total - remaining) / total;
    final dueLabel =
        plan.nextDueDate == null ? 'N/A' : _formatDate(plan.nextDueDate!);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.white,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Installment Plan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: SumAcademyTheme.darkBase,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 6.h),
          Text(
            '${plan.numberOfInstallments} installments',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                ),
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 6.h,
              backgroundColor: SumAcademyTheme.brandBluePale,
              valueColor:
                  const AlwaysStoppedAnimation(SumAcademyTheme.brandBlue),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              _MiniStat(label: 'Remaining', value: _formatPkr(remaining)),
              SizedBox(width: 12.w),
              _MiniStat(label: 'Next Due', value: dueLabel),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: SumAcademyTheme.surfaceSecondary,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: SumAcademyTheme.brandBluePale),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                  ),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SumAcademyTheme.darkBase,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoicesEmpty extends StatelessWidget {
  const _InvoicesEmpty();

  @override
  Widget build(BuildContext context) {
    return const _EmptyState(
      message: 'No invoices available yet.',
      icon: Icons.description_rounded,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const _EmptyState({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.white,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
      ),
      child: Row(
        children: [
          Icon(icon, color: SumAcademyTheme.brandBlue),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacityFloat(0.15),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _PaymentsSkeleton extends StatelessWidget {
  const _PaymentsSkeleton();

  @override
  Widget build(BuildContext context) {
    final base = SumAcademyTheme.surfaceTertiary;
    return Column(
      children: List.generate(
        2,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: SumAcademyTheme.white,
              borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
              border: Border.all(color: SumAcademyTheme.brandBluePale),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonLine(width: 180.w, height: 14.h, color: base),
                SizedBox(height: 10.h),
                _SkeletonLine(width: 140.w, height: 10.h, color: base),
                SizedBox(height: 12.h),
                _SkeletonLine(width: 80.w, height: 24.h, color: base),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatefulWidget {
  final double width;
  final double height;
  final Color color;

  const _SkeletonLine({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  State<_SkeletonLine> createState() => _SkeletonLineState();
}

class _SkeletonLineState extends State<_SkeletonLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.color;
    final highlight = Color.lerp(base, SumAcademyTheme.white, 0.55) ?? base;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final color = Color.lerp(base, highlight, _controller.value) ?? base;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12.r),
          ),
        );
      },
    );
  }
}

String _formatPkr(double value) {
  final rounded = value.isNaN ? 0 : value.round();
  return 'PKR $rounded';
}

String _formatDate(DateTime date) {
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
  final day = date.day.toString().padLeft(2, '0');
  final month = months[date.month - 1];
  final year = date.year.toString();
  return '$day $month $year';
}

Color _statusColor(String status) {
  final lower = status.toLowerCase();
  if (lower.contains('approved') || lower.contains('paid')) {
    return SumAcademyTheme.success;
  }
  if (lower.contains('reject') || lower.contains('fail')) {
    return SumAcademyTheme.error;
  }
  if (lower.contains('review') || lower.contains('pending')) {
    return SumAcademyTheme.warning;
  }
  return SumAcademyTheme.brandBlue;
}
