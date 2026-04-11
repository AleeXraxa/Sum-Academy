import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/student/controllers/student_tests_controller.dart';
import 'package:sum_academy/modules/student/models/student_test.dart';
import 'package:sum_academy/modules/student/services/student_tests_service.dart';
import 'package:sum_academy/modules/student/views/student_test_attempt_view.dart';

class StudentTestsView extends GetView<StudentTestsController> {
  const StudentTestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Obx(() {
      return RefreshIndicator(
        color: SumAcademyTheme.brandBlue,
        onRefresh: controller.refresh,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            _HeaderRow(textColor: textColor),
            SizedBox(height: 6.h),
            Text(
              'Scheduled tests for your classes. You can only attempt during the active time.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor.withOpacityFloat(0.65),
                  ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Search tests',
                prefixIcon: Icon(Icons.search, size: 20.sp),
              ),
            ),
            SizedBox(height: 14.h),
            if (controller.isLoading.value)
              const _Skeleton()
            else if (controller.errorMessage.value.isNotEmpty)
              _ErrorState(
                message: controller.errorMessage.value,
                onRetry: controller.fetchTests,
              )
            else if (controller.filteredTests.isEmpty)
              const _EmptyState()
            else
              ...controller.filteredTests.map(
                (test) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _TestCard(test: test),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _HeaderRow extends StatelessWidget {
  final Color textColor;

  const _HeaderRow({required this.textColor});

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
            'Tests',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _TestCard extends StatelessWidget {
  final StudentTest test;

  const _TestCard({required this.test});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border = isDark
        ? SumAcademyTheme.white.withOpacityFloat(0.08)
        : SumAcademyTheme.brandBluePale;

    final badge = test.isActiveNow
        ? 'live'
        : (test.isUpcoming
            ? 'scheduled'
            : (test.isEnded ? 'ended' : 'scheduled'));
    final badgeColor = test.isActiveNow
        ? SumAcademyTheme.success
        : (test.isEnded ? SumAcademyTheme.error : SumAcademyTheme.brandBlue);
    final score = test.scorePercent == null
        ? ''
        : '${(test.scorePercent! * 100).clamp(0, 100).round()}%';

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: border),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: SumAcademyTheme.darkBase.withOpacityFloat(0.06),
              blurRadius: 16,
              offset: const Offset(0, 10),
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
                  test.title.isEmpty ? 'Test' : test.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: isDark
                            ? SumAcademyTheme.white
                            : SumAcademyTheme.darkBase,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacityFloat(0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: badgeColor.withOpacityFloat(0.25)),
                ),
                child: Text(
                  badge,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: badgeColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            test.className.isNotEmpty ? test.className : 'Class test',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: (isDark
                          ? SumAcademyTheme.white
                          : SumAcademyTheme.darkBase)
                      .withOpacityFloat(0.65),
                ),
          ),
          if (test.description.trim().isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              test.description.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: (isDark
                            ? SumAcademyTheme.white
                            : SumAcademyTheme.darkBase)
                        .withOpacityFloat(0.72),
                    height: 1.4,
                  ),
            ),
          ],
          SizedBox(height: 10.h),
          _MetaLine(
            icon: Icons.calendar_today_rounded,
            label: _dateLine(test.startAt, test.endAt),
          ),
          SizedBox(height: 6.h),
          _MetaLine(
            icon: Icons.timer_rounded,
            label: test.durationMinutes > 0
                ? 'Duration: ${test.durationMinutes} min'
                : 'Duration: TBA',
          ),
          if (score.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              'Score: $score',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: SumAcademyTheme.brandBlue,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canAttempt(test)
                  ? () => Get.to(
                        () => StudentTestAttemptView(
                          testId: test.id,
                          service: StudentTestsService(),
                        ),
                      )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: SumAcademyTheme.brandBlue,
                foregroundColor: SumAcademyTheme.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
              ),
              child: Text(_buttonLabel(test)),
            ),
          ),
          if (!_canAttempt(test)) ...[
            SizedBox(height: 10.h),
            Text(
              _disabledReason(test),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: (isDark
                            ? SumAcademyTheme.white
                            : SumAcademyTheme.darkBase)
                        .withOpacityFloat(0.65),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  bool _canAttempt(StudentTest test) {
    if (test.id.trim().isEmpty) return false;
    if (test.isAttempted) return false;
    return test.isActiveNow;
  }

  String _buttonLabel(StudentTest test) {
    if (test.isAttempted) return 'Attempted';
    if (test.isActiveNow) return 'Start Test';
    return 'Join Test';
  }

  String _disabledReason(StudentTest test) {
    if (test.isAttempted) return 'You have already attempted this test.';
    if (test.isUpcoming && test.startAt != null) {
      return 'Starts at ${_formatFull(test.startAt!)}.';
    }
    if (test.isEnded) return 'This test has ended.';
    return 'This test is not available right now.';
  }

  String _dateLine(DateTime? start, DateTime? end) {
    if (start == null && end == null) return 'Schedule: TBA';
    final startText = start == null ? 'TBA' : _formatFull(start);
    final endText = end == null ? 'TBA' : _formatFull(end);
    return 'Schedule: $startText → $endText';
  }
}

class _MetaLine extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaLine({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = (isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase)
        .withOpacityFloat(0.65);
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: color),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border = isDark
        ? SumAcademyTheme.white.withOpacityFloat(0.08)
        : SumAcademyTheme.brandBluePale;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: border),
      ),
      child: Text(
        'No scheduled tests found.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: (isDark
                      ? SumAcademyTheme.white
                      : SumAcademyTheme.darkBase)
                  .withOpacityFloat(0.7),
            ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.errorLight,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: SumAcademyTheme.error.withOpacityFloat(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unable to load tests',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: SumAcademyTheme.error,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 6.h),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                ),
          ),
          SizedBox(height: 10.h),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: SumAcademyTheme.brandBlue,
              side: const BorderSide(color: SumAcademyTheme.brandBluePale),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Container(
            height: 138.h,
            decoration: BoxDecoration(
              color: SumAcademyTheme.white,
              borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
              border: Border.all(color: SumAcademyTheme.brandBluePale),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatFull(DateTime date) {
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
  final day = date.day.toString().padLeft(2, '0');
  final year = date.year.toString();
  var hour = date.hour;
  final minute = date.minute.toString().padLeft(2, '0');
  final suffix = hour >= 12 ? 'PM' : 'AM';
  hour = hour % 12;
  if (hour == 0) hour = 12;
  return '$month $day, $year $hour:$minute $suffix';
}

String _dateLine(DateTime? start, DateTime? end) {
  if (start == null && end == null) return 'Schedule: TBA';
  final startText = start == null ? 'TBA' : _formatFull(start);
  final endText = end == null ? 'TBA' : _formatFull(end);
  return 'Schedule: $startText → $endText';
}

