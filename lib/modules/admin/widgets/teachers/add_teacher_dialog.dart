import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';
import 'package:sum_academy/modules/admin/controllers/admin_teacher_controller.dart';
import 'package:sum_academy/modules/admin/widgets/users/user_dialog_fields.dart';

Future<void> showAddTeacherDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (context) => const AddTeacherDialog(),
  );
}

class AddTeacherDialog extends StatefulWidget {
  const AddTeacherDialog({super.key});

  @override
  State<AddTeacherDialog> createState() => _AddTeacherDialogState();
}

class _AddTeacherDialogState extends State<AddTeacherDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bioController = TextEditingController();
  bool _obscure = true;
  bool _isSubmitting = false;
  int _bioLength = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: SumAcademyTheme.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
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
                          'Add Teacher',
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
                        hintText: 'Teacher full name',
                        keyboardType: TextInputType.name,
                        textInputAction:
                            isWide ? TextInputAction.next : TextInputAction.next,
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
                        hintText: 'teacher@example.com',
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
                  _fieldPair(
                    isWide,
                    _buildField(
                      label: 'Password',
                      child: DialogTextField(
                        controller: _passwordController,
                        hintText: 'Create password',
                        obscureText: _obscure,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          final input = value?.trim() ?? '';
                          if (input.isEmpty) {
                            return 'Password is required';
                          }
                          if (input.length < 6) {
                            return 'Minimum 6 characters';
                          }
                          return null;
                        },
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility,
                            size: 20.sp,
                            color: SumAcademyTheme.brandBlueDark,
                          ),
                        ),
                      ),
                    ),
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
                  ),
                  SizedBox(height: 14.h),
                  _buildField(
                    label: 'Subject',
                    child: DialogTextField(
                      controller: _subjectController,
                      hintText: 'Biology',
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Subject is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      const DialogLabel(text: 'Bio'),
                      const Spacer(),
                      Text(
                        '$_bioLength/300',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: SumAcademyTheme.darkBase
                                  .withOpacityFloat(0.5),
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  DialogTextField(
                    controller: _bioController,
                    hintText: 'Short teacher bio',
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    maxLines: 4,
                    minLines: 4,
                    maxLength: 300,
                    showCounter: false,
                    onChanged: (value) => setState(() {
                      _bioLength = value.trim().length;
                    }),
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
                        onPressed: _isSubmitting ? null : _handleCreate,
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
                        child: const Text('Create Teacher'),
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

  Future<void> _handleCreate() async {
    final fullName = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final phone = _phoneController.text.trim();
    final subject = _subjectController.text.trim();
    final bio = _bioController.text.trim();

    if (!(_formKey.currentState?.validate() ?? false)) {
      await showErrorDialog(
        Get.context ?? context,
        title: 'Required',
        message: 'Please fix the highlighted fields.',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final controller = Get.find<AdminTeacherController>();
    final overlayContext = Get.context ?? context;
    showLoadingDialog(overlayContext, message: 'Creating teacher...');
    late final result;
    try {
      result = await controller.createTeacher(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        subject: subject,
        bio: bio,
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
        title: 'Teacher Created',
        message: result.message,
      );
    } else {
      if (result.isNetworkError) {
        await showNoInternetDialogOnce(message: result.message);
        return;
      }
      await showErrorDialog(
        overlayContext,
        title: 'Create Failed',
        message: result.message,
      );
    }
  }
}
