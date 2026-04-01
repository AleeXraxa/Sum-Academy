import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';
import 'package:sum_academy/modules/admin/controllers/admin_student_controller.dart';
import 'package:sum_academy/modules/admin/widgets/users/user_dialog_fields.dart';

Future<void> showEditStudentDialog(
  BuildContext context, {
  required String uid,
  required String name,
  required String email,
  String phone = '',
  bool isActive = true,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (context) => EditStudentDialog(
      uid: uid,
      name: name,
      email: email,
      phone: phone,
      isActive: isActive,
    ),
  );
}

class EditStudentDialog extends StatefulWidget {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final bool isActive;

  const EditStudentDialog({
    super.key,
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.isActive,
  });

  @override
  State<EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends State<EditStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late bool _isActive;
  bool _isSubmitting = false;
  late final bool _isSelf;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
    _isActive = widget.isActive;
    _isSelf = Get.find<AdminStudentController>().isCurrentUser(widget.uid);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: SumAcademyTheme.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 560;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Edit Student',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: SumAcademyTheme.darkBase,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      DialogIconButton(
                        icon: Icons.close_rounded,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  _fieldPair(
                    isWide,
                    _buildField(
                      label: 'Full Name',
                      child: DialogTextField(
                        controller: _nameController,
                        hintText: 'Student full name',
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Full name is required';
                          }
                          if (value.trim().length < 3) {
                            return 'Enter at least 3 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    _buildField(
                      label: 'Email',
                      child: DialogTextField(
                        controller: _emailController,
                        hintText: 'student@example.com',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          final input = value?.trim() ?? '';
                          if (input.isEmpty) {
                            return 'Email is required';
                          }
                          final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                          if (!regex.hasMatch(input)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  _buildField(
                    label: 'Phone',
                    child: DialogTextField(
                      controller: _phoneController,
                      hintText: '+923001234567',
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final input = value?.trim() ?? '';
                        if (input.isEmpty) {
                          return null;
                        }
                        if (input.length < 7) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 14.h),
                  _StatusTile(
                    isActive: _isActive,
                    enabled: !_isSelf,
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: SumAcademyTheme.darkBase,
                          side: const BorderSide(
                            color: SumAcademyTheme.brandBluePale,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              SumAcademyTheme.radiusButton.r,
                            ),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                      SizedBox(width: 12.w),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _handleUpdate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SumAcademyTheme.brandBlue,
                          foregroundColor: SumAcademyTheme.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              SumAcademyTheme.radiusButton.r,
                            ),
                          ),
                        ),
                        child: const Text('Update Student'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _fieldPair(bool isWide, Widget left, Widget right) {
    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          left,
          SizedBox(height: 14.h),
          right,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        SizedBox(width: 16.w),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DialogLabel(text: label),
        SizedBox(height: 8.h),
        child,
      ],
    );
  }

  Future<void> _handleUpdate() async {
    final fullName = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (!(_formKey.currentState?.validate() ?? false)) {
      await showErrorDialog(
        Get.context ?? context,
        title: 'Required',
        message: 'Please fix the highlighted fields.',
      );
      return;
    }

    if (_isSelf && _isActive != widget.isActive) {
      await showErrorDialog(
        Get.context ?? context,
        title: 'Not allowed',
        message: 'You cannot change your own status.',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final controller = Get.find<AdminStudentController>();
    final overlayContext = Get.context ?? context;
    showLoadingDialog(overlayContext, message: 'Updating student...');
    late final result;
    try {
      result = await controller.updateStudent(
        uid: widget.uid,
        fullName: fullName,
        email: email,
        phone: phone,
        isActive: _isActive,
      );
    } finally {
      if (Navigator.of(overlayContext, rootNavigator: true).canPop()) {
        Navigator.of(overlayContext, rootNavigator: true).pop();
      }
    }
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.of(context).pop();
      await showSuccessDialog(
        overlayContext,
        title: 'Student Updated',
        message: result.message,
      );
    } else {
      if (result.isNetworkError) {
        await showNoInternetDialog(
          overlayContext,
          message: result.message,
        );
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

class _StatusTile extends StatelessWidget {
  final bool isActive;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  const _StatusTile({
    required this.isActive,
    required this.onChanged,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: SumAcademyTheme.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: SumAcademyTheme.brandBluePale),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Status',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: SumAcademyTheme.darkBase,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Toggle whether this student can access the system.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SumAcademyTheme.darkBase.withOpacityFloat(0.55),
                        ),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 0.9,
              child: Switch(
                value: isActive,
                onChanged: enabled ? onChanged : null,
                activeColor: SumAcademyTheme.white,
                activeTrackColor: SumAcademyTheme.success,
                inactiveThumbColor: SumAcademyTheme.white,
                inactiveTrackColor: SumAcademyTheme.brandBluePale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
