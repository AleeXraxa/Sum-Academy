import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';

class HomeFilterDialog {
  static Future<void> show() async {
    await Get.bottomSheet(
      const _FilterSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SumAcademyTheme.radiusLargeCard.r),
        ),
        boxShadow: [
          BoxShadow(
            color: SumAcademyTheme.darkBase.withOpacityFloat(0.12),
            blurRadius: 24.r,
            offset: Offset(0, -8.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter courses',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                onPressed: Get.back,
                icon: Icon(Icons.close, size: 20.sp),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Narrow down by level, format, and duration.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: 16.h),
          _ChipSection(
            title: 'Level',
            chips: const ['Beginner', 'Intermediate', 'Advanced'],
          ),
          SizedBox(height: 14.h),
          _ChipSection(
            title: 'Format',
            chips: const ['Live', 'Self-paced', 'Cohort'],
          ),
          SizedBox(height: 14.h),
          _ChipSection(
            title: 'Duration',
            chips: const ['< 2 hours', '2-4 hours', '4+ hours'],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Reset'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: Get.back,
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipSection extends StatelessWidget {
  final String title;
  final List<String> chips;

  const _ChipSection({required this.title, required this.chips});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: chips
              .map(
                (chip) => ChoiceChip(
                  label: Text(chip),
                  selected: false,
                  onSelected: (_) {},
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
