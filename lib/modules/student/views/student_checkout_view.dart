import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/widgets/app_bootstrap_loader.dart';
import 'package:sum_academy/modules/admin/widgets/users/user_dialog_fields.dart';
import 'package:sum_academy/modules/student/controllers/student_checkout_controller.dart';
import 'package:sum_academy/modules/student/models/student_explore_course.dart';

class StudentCheckoutView extends StatefulWidget {
  final StudentExploreCourse course;

  const StudentCheckoutView({super.key, required this.course});

  @override
  State<StudentCheckoutView> createState() => _StudentCheckoutViewState();
}

class _StudentCheckoutViewState extends State<StudentCheckoutView> {
  late final StudentCheckoutController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      StudentCheckoutController(course: widget.course),
      tag: widget.course.id,
    );
  }

  @override
  void dispose() {
    Get.delete<StudentCheckoutController>(tag: widget.course.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [
                    SumAcademyTheme.darkBase,
                    SumAcademyTheme.darkSurface,
                  ]
                : const [
                    SumAcademyTheme.surfaceSecondary,
                    SumAcademyTheme.surfaceTertiary,
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            if (_controller.isLoading.value) {
              return const AppBootstrapLoader(
                message: 'Preparing your checkout...',
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 28.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CheckoutHeader(onBack: _controller.goBack),
                  SizedBox(height: 18.h),
                  _StepTabs(current: _controller.stepIndex.value),
                  SizedBox(height: 18.h),
                  if (_controller.stepIndex.value == 0)
                    _OrderSummaryStep(controller: _controller),
                  if (_controller.stepIndex.value == 1)
                    _InstallmentStep(controller: _controller),
                  if (_controller.stepIndex.value == 2)
                    _PaymentMethodStep(controller: _controller),
                  if (_controller.stepIndex.value == 3)
                    _ConfirmStep(controller: _controller),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _CheckoutHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _CheckoutHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18.sp,
            color: SumAcademyTheme.darkBase,
          ),
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Checkout',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: SumAcademyTheme.darkBase,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Complete your enrollment securely',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepTabs extends StatelessWidget {
  final int current;

  const _StepTabs({required this.current});

  @override
  Widget build(BuildContext context) {
    const steps = [
      '1. Order Summary',
      '2. Installment Option',
      '3. Payment Method',
      '4. Confirm',
    ];

    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: List.generate(steps.length, (index) {
        final isActive = index == current;
        return Container(
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
            steps[index],
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isActive
                      ? SumAcademyTheme.white
                      : SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                  fontWeight: FontWeight.w600,
                ),
          ),
        );
      }),
    );
  }
}

class _OrderSummaryStep extends StatelessWidget {
  final StudentCheckoutController controller;

  const _OrderSummaryStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: SumAcademyTheme.darkBase,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 12.h),
          _SummaryBox(controller: controller),
          SizedBox(height: 16.h),
          _buildClassShiftSection(),
          SizedBox(height: 14.h),
          _PromoField(controller: controller),
          SizedBox(height: 18.h),
          _StepActions(
            onBack: controller.goBack,
            onNext: () => controller.goNext(),
            nextLabel: 'Next',
          ),
        ],
      ),
    );
  }

  Widget _buildClassShiftSection() {
    return Obx(() {
      final classItems =
          controller.classes.map((item) => item.displayLabel).toList();
      final shiftItems =
          controller.availableShifts.map((item) => item.displayLabel).toList();

      if (classItems.isEmpty) {
        return _InfoBanner(
          message:
              'No classes are available for this course yet. Please check back soon.',
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DialogLabel(text: 'Select Class'),
          SizedBox(height: 8.h),
          DialogDropdown(
            value: controller.selectedClass.value?.displayLabel,
            hintText: 'Select class',
            items: classItems,
            onChanged: controller.selectClassByLabel,
          ),
          SizedBox(height: 12.h),
          if (shiftItems.isEmpty)
            _InfoBanner(
              message: 'No shifts available for the selected class.',
            )
          else ...[
            const DialogLabel(text: 'Select Shift'),
            SizedBox(height: 8.h),
            DialogDropdown(
              value: controller.selectedShift.value?.displayLabel,
              hintText: 'Select shift',
              items: shiftItems,
              onChanged: controller.selectShiftByLabel,
            ),
          ],
        ],
      );
    });
  }
}

class _SummaryBox extends StatelessWidget {
  final StudentCheckoutController controller;

  const _SummaryBox({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: SumAcademyTheme.surfaceSecondary,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: SumAcademyTheme.brandBluePale),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.course.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: SumAcademyTheme.darkBase,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 8.h),
            _SummaryRow(
              label: 'Original Price',
              value: _formatPkr(controller.originalPrice),
            ),
            _SummaryRow(
              label: 'Course Discount',
              value: '-${_formatPkr(controller.courseDiscount)}',
            ),
            _SummaryRow(
              label: 'Promo Discount',
              value: '-${_formatPkr(controller.promoDiscount.value)}',
            ),
            SizedBox(height: 6.h),
            Text(
              'Total: ${_formatPkr(controller.totalAmount)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: SumAcademyTheme.darkBase,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      );
    });
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SumAcademyTheme.darkBase,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _PromoField extends StatelessWidget {
  final StudentCheckoutController controller;

  const _PromoField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DialogLabel(text: 'Promo Code'),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: DialogTextField(
                  controller: controller.promoController,
                  hintText: 'ENTER CODE',
                  textInputAction: TextInputAction.done,
                ),
              ),
              SizedBox(width: 10.w),
              SizedBox(
                height: 48.h,
                child: OutlinedButton(
                  onPressed:
                      controller.isValidatingPromo.value ? null : controller.validatePromo,
                  child: controller.isValidatingPromo.value
                      ? SizedBox(
                          width: 18.r,
                          height: 18.r,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Validate'),
                ),
              ),
            ],
          ),
          if (controller.promoMessage.value.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              controller.promoMessage.value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SumAcademyTheme.success,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ],
      );
    });
  }
}

class _InstallmentStep extends StatelessWidget {
  final StudentCheckoutController controller;

  const _InstallmentStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Installment Option',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: SumAcademyTheme.darkBase,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 12.h),
          _InstallmentToggle(controller: controller),
          SizedBox(height: 12.h),
          Obx(() {
            if (!controller.isInstallment.value) {
              return Text(
                'You selected full payment: ${_formatPkr(controller.totalAmount)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                    ),
              );
            }

            final options = controller.installmentOptions;
            final selectedLabel =
                '${controller.selectedInstallmentCount.value} installments';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DialogDropdown(
                  value: selectedLabel,
                  hintText: 'Select installments',
                  items: options.map((value) => '$value installments').toList(),
                  onChanged: controller.selectInstallmentCountByLabel,
                ),
                SizedBox(height: 12.h),
                _SchedulePreview(controller: controller),
              ],
            );
          }),
          SizedBox(height: 18.h),
          _StepActions(
            onBack: controller.goBack,
            onNext: () => controller.goNext(),
            nextLabel: 'Next',
          ),
        ],
      ),
    );
  }
}

class _InstallmentToggle extends StatelessWidget {
  final StudentCheckoutController controller;

  const _InstallmentToggle({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isInstallment = controller.isInstallment.value;
      return Wrap(
        spacing: 10.w,
        children: [
          _SegmentButton(
            label: 'Pay Full',
            isActive: !isInstallment,
            onTap: () => controller.toggleInstallment(false),
          ),
          _SegmentButton(
            label: 'Installment',
            isActive: isInstallment,
            onTap: () => controller.toggleInstallment(true),
          ),
        ],
      );
    });
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? SumAcademyTheme.brandBlue : SumAcademyTheme.white,
          borderRadius: BorderRadius.circular(18.r),
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

class _SchedulePreview extends StatelessWidget {
  final StudentCheckoutController controller;

  const _SchedulePreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    final schedule = controller.installmentSchedule;
    if (schedule.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule Preview',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: SumAcademyTheme.darkBase,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 8.h),
          ...schedule.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Text(
                'Installment ${item.sequence}: ${_formatPkr(item.amount)} - '
                'Due: ${_formatDate(item.dueDate)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodStep extends StatelessWidget {
  final StudentCheckoutController controller;

  const _PaymentMethodStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: SumAcademyTheme.darkBase,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 12.h),
          Obx(() {
            final methods = controller.paymentMethods;
            if (methods.isEmpty) {
              return _InfoBanner(
                message: 'Payment methods are currently unavailable.',
              );
            }
            return Column(
              children: methods.map((method) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: _PaymentMethodCard(
                    label: method,
                    isActive: controller.selectedMethod.value == method,
                    isRecommended: method == 'Bank Transfer',
                    onTap: () => controller.selectMethod(method),
                  ),
                );
              }).toList(),
            );
          }),
          SizedBox(height: 12.h),
          _BankDetails(controller: controller),
          SizedBox(height: 18.h),
          _StepActions(
            onBack: controller.goBack,
            onNext: () => controller.goNext(),
            nextLabel: 'Next',
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isRecommended;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.label,
    required this.isActive,
    required this.isRecommended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tone = _methodTone(label);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: tone.withOpacityFloat(isActive ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isActive ? SumAcademyTheme.brandBlue : tone,
            width: isActive ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: SumAcademyTheme.darkBase,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            if (isRecommended)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: SumAcademyTheme.successLight,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Recommended',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: SumAcademyTheme.success,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BankDetails extends StatelessWidget {
  final StudentCheckoutController controller;

  const _BankDetails({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.selectedMethod.value.toLowerCase().contains('bank')) {
        return const SizedBox.shrink();
      }
      final details = controller.paymentConfig.value?.bankDetails ?? {};
      if (details.isEmpty) {
        return _InfoBanner(
          message: 'Bank details will be shown after selecting Bank Transfer.',
        );
      }

      final bankName = _readAny(details, ['bank', 'bankName', 'name']);
      final accountTitle =
          _readAny(details, ['accountTitle', 'title', 'account_name']);
      final accountNumber =
          _readAny(details, ['accountNumber', 'account', 'number']);
      final iban = _readAny(details, ['iban', 'IBAN']);

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: SumAcademyTheme.surfaceSecondary,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: SumAcademyTheme.brandBluePale),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bank Details',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: SumAcademyTheme.darkBase,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 8.h),
            if (bankName.isNotEmpty) _DetailRow(label: 'Bank', value: bankName),
            if (accountTitle.isNotEmpty)
              _DetailRow(label: 'Account Title', value: accountTitle),
            if (accountNumber.isNotEmpty)
              _DetailRow(label: 'Account Number', value: accountNumber),
            if (iban.isNotEmpty) _DetailRow(label: 'IBAN', value: iban),
          ],
        ),
      );
    });
  }
}

class _ConfirmStep extends StatelessWidget {
  final StudentCheckoutController controller;

  const _ConfirmStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirm',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: SumAcademyTheme.darkBase,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 12.h),
          _ConfirmSummary(controller: controller),
          SizedBox(height: 16.h),
          Obx(() {
            if (!controller.paymentInitiated.value) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                _PaymentReferenceCard(controller: controller),
                SizedBox(height: 12.h),
                _ReceiptUpload(controller: controller),
              ],
            );
          }),
          SizedBox(height: 18.h),
          Obx(() {
            final label = controller.paymentInitiated.value
                ? 'Finish'
                : 'Confirm Payment';
            return _StepActions(
              onBack: controller.goBack,
              onNext: () => controller.goNext(),
              nextLabel: label,
            );
          }),
        ],
      ),
    );
  }
}

class _ConfirmSummary extends StatelessWidget {
  final StudentCheckoutController controller;

  const _ConfirmSummary({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final className = controller.selectedClass.value?.name ?? 'Select class';
      final shiftName = controller.selectedShift.value?.name ?? 'Select shift';
      final method = controller.selectedMethod.value;
      final installment = controller.isInstallment.value
          ? '${controller.selectedInstallmentCount.value} installments'
          : 'Full payment';

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: SumAcademyTheme.surfaceSecondary,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: SumAcademyTheme.brandBluePale),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.course.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: SumAcademyTheme.darkBase,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Class: $className - Shift: $shiftName',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                  ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Method: $method',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                  ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Amount Due Now: ${_formatPkr(controller.amountDueNow)}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: SumAcademyTheme.darkBase,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Total: ${_formatPkr(controller.totalAmount)} - $installment',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                  ),
            ),
          ],
        ),
      );
    });
  }
}

class _PaymentReferenceCard extends StatelessWidget {
  final StudentCheckoutController controller;

  const _PaymentReferenceCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final reference = controller.paymentReference.value;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: SumAcademyTheme.surfaceSecondary,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: SumAcademyTheme.brandBluePale),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Reference: ${reference.isEmpty ? 'Pending' : reference}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: SumAcademyTheme.darkBase,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Upload receipt image (JPG/PNG, max 5MB) for admin verification.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                  ),
            ),
          ],
        ),
      );
    });
  }
}

class _ReceiptUpload extends StatelessWidget {
  final StudentCheckoutController controller;

  const _ReceiptUpload({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final path = controller.receiptPath.value;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: SumAcademyTheme.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: SumAcademyTheme.brandBluePale),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload receipt image',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: SumAcademyTheme.darkBase,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    path.isEmpty ? 'No file chosen' : path.split('\\').last,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                        ),
                  ),
                ),
                TextButton(
                  onPressed: controller.pickReceipt,
                  child: const Text('Choose file'),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isUploadingReceipt.value
                    ? null
                    : controller.uploadReceipt,
                child: controller.isUploadingReceipt.value
                    ? SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: SumAcademyTheme.white,
                        ),
                      )
                    : const Text('Upload Receipt'),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Status: Pending Admin Verification',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SumAcademyTheme.warning,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      );
    });
  }
}

class _StepActions extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  final String nextLabel;

  const _StepActions({
    required this.onBack,
    required this.onNext,
    required this.nextLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: onBack,
          child: const Text('Back'),
        ),
        ElevatedButton(
          onPressed: onNext,
          child: Text(nextLabel),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
        boxShadow: [
          BoxShadow(
            color: SumAcademyTheme.darkBase.withOpacityFloat(0.08),
            blurRadius: 18.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String message;

  const _InfoBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.brandBluePale,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
            ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SumAcademyTheme.darkBase,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

String _formatPkr(double value) {
  final rounded = value.isNaN ? 0 : value.round();
  return 'PKR $rounded';
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  return '$day/$month/$year';
}

String _readAny(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = data[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return '';
}

Color _methodTone(String label) {
  final lower = label.toLowerCase();
  if (lower.contains('jazz')) {
    return const Color(0xFFFFA4B8);
  }
  if (lower.contains('easy')) {
    return const Color(0xFF7BE5B0);
  }
  if (lower.contains('bank')) {
    return SumAcademyTheme.brandBlueLight;
  }
  return SumAcademyTheme.brandBlue;
}
