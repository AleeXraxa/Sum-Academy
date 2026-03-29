import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/widgets/users/user_dialog_fields.dart';

Future<void> showEditUserDialog(
  BuildContext context, {
  required String name,
  required String email,
  String phone = '',
  required String role,
  bool isActive = true,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (context) => EditUserDialog(
      name: name,
      email: email,
      phone: phone,
      role: role,
      isActive: isActive,
    ),
  );
}

class EditUserDialog extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool isActive;

  const EditUserDialog({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
  });

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late bool _isActive;
  String? _role;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
    _role = widget.role;
    _isActive = widget.isActive;
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Edit User',
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
            SizedBox(height: 14.h),
            _StatusTile(
              isActive: _isActive,
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
                  child: const Text('Update User'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  final bool isActive;
  final ValueChanged<bool> onChanged;

  const _StatusTile({required this.isActive, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  'Toggle whether this user can access the system.',
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
              onChanged: onChanged,
              activeColor: SumAcademyTheme.white,
              activeTrackColor: SumAcademyTheme.success,
              inactiveThumbColor: SumAcademyTheme.white,
              inactiveTrackColor: SumAcademyTheme.brandBluePale,
            ),
          ),
        ],
      ),
    );
  }
}
