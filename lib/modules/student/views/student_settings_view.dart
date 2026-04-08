import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/widgets/users/user_dialog_fields.dart';
import 'package:sum_academy/modules/student/controllers/student_settings_controller.dart';
import 'package:sum_academy/modules/student/widgets/student_notification_bell.dart';

class StudentSettingsView extends GetView<StudentSettingsController> {
  const StudentSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Obx(() {
      return ListView(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
        physics: const BouncingScrollPhysics(),
        children: [
          _HeaderRow(textColor: textColor, controller: controller),
          SizedBox(height: 10.h),
          Text(
            'Manage your profile information and security.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor.withOpacityFloat(0.6),
                ),
          ),
          SizedBox(height: 16.h),
          if (controller.isLoading.value)
            const _SettingsSkeleton()
          else ...[
            _ProfileForm(controller: controller),
            SizedBox(height: 16.h),
            _ChangePasswordCard(controller: controller),
          ],
        ],
      );
    });
  }
}

class _HeaderRow extends StatelessWidget {
  final Color textColor;
  final StudentSettingsController controller;

  const _HeaderRow({
    required this.textColor,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final scaffoldState = Scaffold.maybeOf(context);
    final showMenu = scaffoldState?.hasDrawer ?? false;
    return Row(
      children: [
        if (showMenu)
          IconButton(
            onPressed: () {
              if (scaffoldState?.hasDrawer ?? false) {
                scaffoldState?.openDrawer();
              }
            },
            icon: Icon(
              Icons.menu_rounded,
              size: 20.sp,
              color: textColor.withOpacityFloat(0.7),
            ),
          ),
        if (showMenu) SizedBox(width: 6.w),
        Expanded(
          child: Text(
            'Profile',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        StudentNotificationBell(
          iconColor: textColor.withOpacityFloat(0.75),
        ),
        SizedBox(width: 8.w),
        _ProfileStatus(isComplete: controller.isComplete),
      ],
    );
  }
}

class _ProfileStatus extends StatelessWidget {
  final bool isComplete;

  const _ProfileStatus({required this.isComplete});

  @override
  Widget build(BuildContext context) {
    final label = isComplete ? 'Complete' : 'Incomplete';
    final color =
        isComplete ? SumAcademyTheme.success : SumAcademyTheme.warning;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacityFloat(0.15),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _ProfileForm extends StatelessWidget {
  final StudentSettingsController controller;

  const _ProfileForm({required this.controller});

  @override
  Widget build(BuildContext context) {
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
          _SectionHeader(
            title: 'Profile',
            subtitle: 'Keep your details accurate for certificates.',
          ),
          SizedBox(height: 14.h),
          _FieldRow(
            leftLabel: 'Full Name',
            leftField: DialogTextField(
              controller: controller.fullNameController,
              hintText: 'Your full name',
            ),
            rightLabel: 'Email',
            rightField: DialogTextField(
              controller: controller.emailController,
              hintText: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              enabled: false,
            ),
          ),
          SizedBox(height: 12.h),
          _FieldRow(
            leftLabel: 'Phone Number',
            leftField: DialogTextField(
              controller: controller.phoneController,
              hintText: '+92 300 0000000',
              keyboardType: TextInputType.phone,
            ),
            rightLabel: 'Father Name',
            rightField: DialogTextField(
              controller: controller.fatherNameController,
              hintText: 'Father name',
            ),
          ),
          SizedBox(height: 12.h),
          _FieldRow(
            leftLabel: 'Father Phone',
            leftField: DialogTextField(
              controller: controller.fatherPhoneController,
              hintText: '03001234567',
              keyboardType: TextInputType.phone,
            ),
            rightLabel: 'Father Occupation',
            rightField: DialogTextField(
              controller: controller.fatherOccupationController,
              hintText: 'Occupation',
            ),
          ),
          SizedBox(height: 12.h),
          _FieldRow(
            leftLabel: 'District',
            leftField: DialogTextField(
              controller: controller.districtController,
              hintText: 'District',
            ),
            rightLabel: 'Domicile',
            rightField: DialogTextField(
              controller: controller.domicileController,
              hintText: 'Domicile',
            ),
          ),
          SizedBox(height: 12.h),
          const _FieldLabel(text: 'Caste'),
          SizedBox(height: 8.h),
          DialogTextField(
            controller: controller.casteController,
            hintText: 'Caste',
          ),
          SizedBox(height: 12.h),
          const _FieldLabel(text: 'Address'),
          SizedBox(height: 8.h),
          DialogTextField(
            controller: controller.addressController,
            hintText: 'Address',
            maxLines: 3,
            minLines: 3,
            textInputAction: TextInputAction.newline,
          ),
          SizedBox(height: 18.h),
          Obx(() {
            return SizedBox(
              width: 200.w,
              height: 48.h,
              child: ElevatedButton(
                onPressed:
                    controller.isSaving.value ? null : controller.saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SumAcademyTheme.brandBlue,
                  foregroundColor: SumAcademyTheme.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                ),
                child: controller.isSaving.value
                    ? SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SettingsSkeleton extends StatelessWidget {
  const _SettingsSkeleton();

  @override
  Widget build(BuildContext context) {
    final base = SumAcademyTheme.surfaceTertiary;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.white,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
      ),
      child: Column(
        children: [
          _SkeletonLine(width: 160.w, height: 14.h, color: base),
          SizedBox(height: 12.h),
          _SkeletonLine(width: double.infinity, height: 44.h, color: base),
          SizedBox(height: 12.h),
          _SkeletonLine(width: double.infinity, height: 44.h, color: base),
          SizedBox(height: 12.h),
          _SkeletonLine(width: double.infinity, height: 80.h, color: base),
        ],
      ),
    );
  }
}

class _ChangePasswordCard extends StatelessWidget {
  final StudentSettingsController controller;

  const _ChangePasswordCard({required this.controller});

  @override
  Widget build(BuildContext context) {
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
          _SectionHeader(
            title: 'Change Password',
            subtitle: 'Use a strong password to keep your account safe.',
          ),
          SizedBox(height: 14.h),
          _FieldRow(
            leftLabel: 'Current Password',
            leftField: _PasswordField(
              controller: controller.currentPasswordController,
              hintText: 'Current password',
            ),
            rightLabel: 'New Password',
            rightField: _PasswordField(
              controller: controller.newPasswordController,
              hintText: 'New password',
            ),
          ),
          SizedBox(height: 12.h),
          const _FieldLabel(text: 'Confirm Password'),
          SizedBox(height: 8.h),
          _PasswordField(
            controller: controller.confirmPasswordController,
            hintText: 'Confirm password',
          ),
          SizedBox(height: 12.h),
          Obx(() {
            final strength = controller.passwordStrength.value;
            final label = controller.passwordStrengthLabel.value;
            final color = strength < 0.5
                ? SumAcademyTheme.error
                : (strength < 0.8
                    ? SumAcademyTheme.warning
                    : SumAcademyTheme.success);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: LinearProgressIndicator(
                    value: strength,
                    minHeight: 6.h,
                    backgroundColor: SumAcademyTheme.surfaceTertiary,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Strength: $label',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    _Requirement(text: 'At least 8 characters'),
                    SizedBox(width: 12.w),
                    _Requirement(text: 'One number'),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    _Requirement(text: 'One uppercase letter'),
                    SizedBox(width: 12.w),
                    _Requirement(text: 'One special character'),
                  ],
                ),
              ],
            );
          }),
          SizedBox(height: 16.h),
          Obx(() {
            return SizedBox(
              width: 200.w,
              height: 48.h,
              child: ElevatedButton(
                onPressed:
                    controller.isSaving.value ? null : controller.changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SumAcademyTheme.brandBlue,
                  foregroundColor: SumAcademyTheme.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                ),
                child: controller.isSaving.value
                    ? SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Password'),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: SumAcademyTheme.darkBase,
                fontWeight: FontWeight.w700,
              ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
              ),
        ),
      ],
    );
  }
}

class _Requirement extends StatelessWidget {
  final String text;

  const _Requirement({required this.text});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
            ),
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const _PasswordField({
    required this.controller,
    required this.hintText,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return DialogTextField(
      controller: widget.controller,
      hintText: widget.hintText,
      obscureText: _obscure,
      suffixIcon: IconButton(
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: Icon(
          _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          size: 18.sp,
        ),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String leftLabel;
  final Widget leftField;
  final String rightLabel;
  final Widget rightField;

  const _FieldRow({
    required this.leftLabel,
    required this.leftField,
    required this.rightLabel,
    required this.rightField,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel(text: leftLabel),
              SizedBox(height: 8.h),
              leftField,
              SizedBox(height: 12.h),
              _FieldLabel(text: rightLabel),
              SizedBox(height: 8.h),
              rightField,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel(text: leftLabel),
                  SizedBox(height: 8.h),
                  leftField,
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel(text: rightLabel),
                  SizedBox(height: 8.h),
                  rightField,
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: SumAcademyTheme.darkBase.withOpacityFloat(0.55),
            letterSpacing: 2.2,
            fontWeight: FontWeight.w600,
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
