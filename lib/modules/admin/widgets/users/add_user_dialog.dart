import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/widgets/users/user_dialog_fields.dart';

Future<void> showAddUserDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (context) => const AddUserDialog(),
  );
}

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _role;
  bool _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Add User',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
            const DialogLabel(text: 'Full Name'),
            SizedBox(height: 8.h),
            DialogTextField(
              controller: _nameController,
              hintText: 'Full Name',
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 14.h),
            const DialogLabel(text: 'Email'),
            SizedBox(height: 8.h),
            DialogTextField(
              controller: _emailController,
              hintText: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 14.h),
            const DialogLabel(text: 'Password'),
            SizedBox(height: 8.h),
            DialogTextField(
              controller: _passwordController,
              hintText: 'Enter secure password',
              obscureText: _obscure,
              textInputAction: TextInputAction.next,
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility,
                  size: 20.sp,
                  color: SumAcademyTheme.brandBlueDark,
                ),
              ),
            ),
            SizedBox(height: 14.h),
            const DialogLabel(text: 'Phone'),
            SizedBox(height: 8.h),
            DialogTextField(
              controller: _phoneController,
              hintText: '03003425849',
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 14.h),
            const DialogLabel(text: 'Role'),
            SizedBox(height: 8.h),
            DialogDropdown(
              value: _role,
              hintText: 'Select role',
              items: const ['Student', 'Teacher', 'Admin'],
              onChanged: (value) => setState(() => _role = value),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SumAcademyTheme.darkBase,
                    side: const BorderSide(color: SumAcademyTheme.brandBluePale),
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
                  onPressed: () => Navigator.of(context).pop(),
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
                  child: const Text('Create User'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
