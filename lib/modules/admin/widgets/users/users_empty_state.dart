import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';

class UsersEmptyState extends StatelessWidget {
  final VoidCallback onAddUser;

  const UsersEmptyState({super.key, required this.onAddUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
        boxShadow: [
          BoxShadow(
            color: SumAcademyTheme.darkBase.withOpacityFloat(0.05),
            blurRadius: 16.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64.r,
            height: 64.r,
            decoration: BoxDecoration(
              color: SumAcademyTheme.brandBluePale,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              Icons.group_rounded,
              color: SumAcademyTheme.brandBlue,
              size: 30.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'No users yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: SumAcademyTheme.darkBase,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Create your first user to start managing access.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: onAddUser,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add User'),
            style: ElevatedButton.styleFrom(
              backgroundColor: SumAcademyTheme.brandBlue,
              foregroundColor: SumAcademyTheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  SumAcademyTheme.radiusButton.r,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
