import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/student/controllers/student_quiz_attempt_controller.dart';
import 'package:sum_academy/modules/student/controllers/student_quizzes_controller.dart';
import 'package:sum_academy/modules/student/models/student_quiz.dart';
import 'package:sum_academy/modules/student/widgets/student_notification_bell.dart';
import 'package:sum_academy/modules/student/views/student_quiz_attempt_view.dart';

class StudentQuizzesView extends GetView<StudentQuizzesController> {
  const StudentQuizzesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;
    return Obx(() {
      return RefreshIndicator(
        color: SumAcademyTheme.brandBlue,
        onRefresh: controller.fetchQuizzes,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
          physics: const BouncingScrollPhysics(),
          children: [
            _HeaderRow(textColor: textColor),
            SizedBox(height: 16.h),
            _TabChips(controller: controller),
            SizedBox(height: 16.h),
            if (controller.isLoading.value)
              const _QuizSkeleton()
            else
              _QuizList(controller: controller),
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
            'Quizzes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        StudentNotificationBell(
          iconColor: textColor.withOpacityFloat(0.75),
        ),
      ],
    );
  }
}

class _TabChips extends StatelessWidget {
  final StudentQuizzesController controller;

  const _TabChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final availableCount = controller.availableQuizzes.length;
      final attemptedCount = controller.attemptedQuizzes.length;
      final active = controller.activeTab.value;
      return Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: [
          _FilterChip(
            label: 'Available',
            count: availableCount,
            isActive: active == 'Available',
            onTap: () => controller.setTab('Available'),
          ),
          _FilterChip(
            label: 'Attempted',
            count: attemptedCount,
            isActive: active == 'Attempted',
            onTap: () => controller.setTab('Attempted'),
          ),
        ],
      );
    });
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isActive
                        ? SumAcademyTheme.white
                        : SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: isActive
                    ? SumAcademyTheme.white.withOpacityFloat(0.2)
                    : SumAcademyTheme.brandBluePale,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                count.toString(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isActive
                          ? SumAcademyTheme.white
                          : SumAcademyTheme.brandBlue,
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

class _QuizList extends StatelessWidget {
  final StudentQuizzesController controller;

  const _QuizList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.activeTab.value == 'Attempted'
          ? controller.attemptedQuizzes
          : controller.availableQuizzes;

      if (items.isEmpty) {
        return Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: SumAcademyTheme.white,
            borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
            border: Border.all(color: SumAcademyTheme.brandBluePale),
          ),
          child: Row(
            children: [
              Icon(Icons.quiz_rounded, color: SumAcademyTheme.brandBlue),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'No quizzes available right now.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                      ),
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: items
            .map(
              (quiz) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _QuizCard(quiz: quiz),
              ),
            )
            .toList(),
      );
    });
  }
}

class _QuizCard extends StatelessWidget {
  final StudentQuizSummary quiz;

  const _QuizCard({required this.quiz});

  @override
  Widget build(BuildContext context) {
    final isAttempted = quiz.isAttempted;
    final statusLabel = isAttempted
        ? 'Attempted'
        : (quiz.isAvailable ? 'Available' : 'Attempted');
    final canStart = quiz.isAvailable && !isAttempted;
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
                  quiz.title.isNotEmpty ? quiz.title : 'Quiz',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: SumAcademyTheme.darkBase,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              _StatusPill(label: statusLabel),
            ],
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              if (quiz.courseTitle.isNotEmpty)
                _Tag(label: quiz.courseTitle),
              if (quiz.subject.isNotEmpty) _Tag(label: quiz.subject),
              _Tag(label: 'Full Subject'),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text(
                '${quiz.questionCount > 0 ? quiz.questionCount : 0} Questions',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                    ),
              ),
              SizedBox(width: 16.w),
              Text(
                '${quiz.totalMarks > 0 ? quiz.totalMarks : 0} Marks',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                    ),
              ),
            ],
          ),
          if (isAttempted && quiz.scorePercent >= 0) ...[
            SizedBox(height: 12.h),
            _ScorePill(scorePercent: quiz.scorePercent),
          ],
          SizedBox(height: 14.h),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              height: 40.h,
              child: ElevatedButton(
                onPressed:
                    canStart ? () => _showStartDialog(context, quiz) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SumAcademyTheme.brandBlue,
                  foregroundColor: SumAcademyTheme.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
                child: Text(canStart ? 'Start Quiz' : 'Attempted'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showStartDialog(
    BuildContext context,
    StudentQuizSummary quiz,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => _StartQuizDialog(quiz: quiz),
    );
  }
}

class _StartQuizDialog extends StatelessWidget {
  final StudentQuizSummary quiz;

  const _StartQuizDialog({required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: SumAcademyTheme.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              quiz.title.isNotEmpty ? quiz.title : 'Quiz',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: SumAcademyTheme.darkBase,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            SizedBox(height: 6.h),
            if (quiz.courseTitle.isNotEmpty)
              Text(
                quiz.courseTitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                    ),
              ),
            SizedBox(height: 14.h),
            Text(
              'This quiz requires fullscreen mode and focus on the quiz tab.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                  ),
            ),
            SizedBox(height: 18.h),
            SizedBox(
              height: 44.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.to(
                    () => StudentQuizAttemptView(
                      quizId: quiz.id,
                      quizTitle: quiz.title,
                    ),
                    binding: BindingsBuilder(
                      () => Get.put(
                        StudentQuizAttemptController(
                          quizId: quiz.id,
                          quizTitle: quiz.title,
                        ),
                        tag: quiz.id,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: SumAcademyTheme.brandBlue,
                  foregroundColor: SumAcademyTheme.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
                child: const Text('Start Quiz'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;

  const _StatusPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: SumAcademyTheme.brandBluePale,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: SumAcademyTheme.brandBlue,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: SumAcademyTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final double scorePercent;

  const _ScorePill({required this.scorePercent});

  @override
  Widget build(BuildContext context) {
    final clamped = scorePercent.clamp(0, 100).toDouble();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: SumAcademyTheme.brandBluePale,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: SumAcademyTheme.brandBlue),
      ),
      child: Text(
        '${clamped.toStringAsFixed(0)}%',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: SumAcademyTheme.brandBlue,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _QuizSkeleton extends StatelessWidget {
  const _QuizSkeleton();

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
                _SkeletonLine(width: 160.w, height: 14.h, color: base),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    _SkeletonLine(width: 90.w, height: 10.h, color: base),
                    SizedBox(width: 10.w),
                    _SkeletonLine(width: 60.w, height: 10.h, color: base),
                  ],
                ),
                SizedBox(height: 12.h),
                _SkeletonLine(width: 120.w, height: 10.h, color: base),
                SizedBox(height: 14.h),
                _SkeletonLine(width: 100.w, height: 36.h, color: base),
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
