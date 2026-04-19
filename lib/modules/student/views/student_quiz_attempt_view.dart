import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/services/secure_screen_service.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/core/widgets/app_bootstrap_loader.dart';
import 'package:sum_academy/modules/student/controllers/student_quiz_attempt_controller.dart';
import 'package:sum_academy/modules/student/models/student_quiz.dart';

class StudentQuizAttemptView extends StatefulWidget {
  final String quizId;
  final String quizTitle;

  const StudentQuizAttemptView({
    super.key,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  State<StudentQuizAttemptView> createState() => _StudentQuizAttemptViewState();
}

class _StudentQuizAttemptViewState extends State<StudentQuizAttemptView>
    with WidgetsBindingObserver {
  late final StudentQuizAttemptController _controller;
  bool _warningVisible = false;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<StudentQuizAttemptController>(tag: widget.quizId)) {
      _controller = Get.find<StudentQuizAttemptController>(tag: widget.quizId);
    } else {
      _controller = Get.put(
        StudentQuizAttemptController(
          quizId: widget.quizId,
          quizTitle: widget.quizTitle,
        ),
        tag: widget.quizId,
      );
    }
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SecureScreenService.enable();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SecureScreenService.disable();
    if (Get.isRegistered<StudentQuizAttemptController>(tag: widget.quizId)) {
      Get.delete<StudentQuizAttemptController>(tag: widget.quizId);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    if (state == AppLifecycleState.resumed) {
      SecureScreenService.enable();
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _showFocusWarning();
    }
  }

  Future<void> _showFocusWarning() async {
    if (_warningVisible || (_controller.resultPercent.value != null)) return;
    _warningVisible = true;
    await showAppErrorDialog(
      title: 'Quiz Warning',
      message:
          'Please stay in the quiz until you submit. Leaving may forfeit your attempt.',
    );
    _warningVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: _controller.resultPercent.value != null,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _showFocusWarning();
      },
      child: Scaffold(
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
                return const AppBootstrapLoader(message: 'Loading quiz...');
              }
              if (_controller.resultPercent.value != null) {
                return ListView(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
                  children: [
                    _AttemptHeader(
                      title: widget.quizTitle,
                      controller: _controller,
                      onExit: () => Get.back(),
                    ),
                    SizedBox(height: 16.h),
                    _ResultCard(percent: _controller.resultPercent.value ?? 0),
                    SizedBox(height: 18.h),
                    SizedBox(
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SumAcademyTheme.brandBlue,
                          foregroundColor: SumAcademyTheme.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                        ),
                        child: const Text('Back to Quizzes'),
                      ),
                    ),
                  ],
                );
              }
              return ListView(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
                children: [
                  _AttemptHeader(
                    title: widget.quizTitle,
                    controller: _controller,
                    onExit: _showFocusWarning,
                  ),
                  SizedBox(height: 16.h),
                  _ProgressCard(
                    total: _controller.questions.length,
                    answered: _controller.answers.length,
                    currentIndex: _controller.currentIndex.value,
                  ),
                  SizedBox(height: 16.h),
                  if (_controller.questions.isEmpty)
                    const _EmptyQuestionState()
                  else ...[
                    _QuestionCard(
                      index: _controller.currentIndex.value + 1,
                      question:
                          _controller.questions[_controller.currentIndex.value],
                      controller: _controller,
                    ),
                    SizedBox(height: 18.h),
                    _NavigationRow(controller: _controller),
                  ],
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _AttemptHeader extends StatelessWidget {
  final String title;
  final StudentQuizAttemptController controller;
  final VoidCallback onExit;

  const _AttemptHeader({
    required this.title,
    required this.controller,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            title.isNotEmpty ? title : 'Quiz',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: SumAcademyTheme.darkBase,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Obx(() {
          final timeLabel = _formatDuration(controller.elapsedSeconds.value);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Quiz Timer',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: SumAcademyTheme.brandBluePale,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Text(
                  timeLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: SumAcademyTheme.brandBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        }),
        SizedBox(width: 8.w),
        IconButton(
          onPressed: onExit,
          icon: Icon(
            Icons.close_rounded,
            color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
          ),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int total;
  final int answered;
  final int currentIndex;

  const _ProgressCard({
    required this.total,
    required this.answered,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : answered / total;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark
        ? SumAcademyTheme.darkSurface
        : SumAcademyTheme.white;
    final border = isDark
        ? SumAcademyTheme.darkBorder
        : SumAcademyTheme.brandBluePale;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: border),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: SumAcademyTheme.brandBlue.withOpacityFloat(0.06),
              blurRadius: 16.r,
              offset: Offset(0, 8.h),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6.h,
              backgroundColor: SumAcademyTheme.brandBluePale,
              valueColor: const AlwaysStoppedAnimation(
                SumAcademyTheme.brandBlue,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Question ${total == 0 ? 0 : currentIndex + 1} of $total · $answered answered',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: (isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase)
                  .withOpacityFloat(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyQuestionState extends StatelessWidget {
  const _EmptyQuestionState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark
              ? SumAcademyTheme.darkBorder
              : SumAcademyTheme.brandBluePale,
        ),
      ),
      child: Text(
        'No questions available for this quiz.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: isDark
              ? SumAcademyTheme.white.withOpacityFloat(0.7)
              : SumAcademyTheme.darkBase.withOpacityFloat(0.7),
        ),
      ),
    );
  }
}

class _NavigationRow extends StatelessWidget {
  final StudentQuizAttemptController controller;

  const _NavigationRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLast =
          controller.currentIndex.value == controller.questions.length - 1;
      final isSubmitting = controller.isSubmitting.value;
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: (controller.canGoPrevious && !isSubmitting)
                  ? controller.goPrevious
                  : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: SumAcademyTheme.brandBlue,
                side: const BorderSide(color: SumAcademyTheme.brandBluePale),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child: const Text('Previous'),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : (isLast ? controller.submit : controller.goNext),
              style: ElevatedButton.styleFrom(
                backgroundColor: SumAcademyTheme.brandBlue,
                foregroundColor: SumAcademyTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child: isSubmitting
                  ? SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(
                          SumAcademyTheme.white,
                        ),
                      ),
                    )
                  : Text(isLast ? 'Submit Quiz' : 'Next'),
            ),
          ),
        ],
      );
    });
  }
}

class _ResultCard extends StatelessWidget {
  final double percent;

  const _ResultCard({required this.percent});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark
        ? SumAcademyTheme.darkSurface
        : SumAcademyTheme.white;

    final clamped = percent.clamp(0, 100).toDouble();
    final tone = _resultTone(clamped);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: tone.withOpacityFloat(0.2)),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: SumAcademyTheme.brandBlue.withOpacityFloat(0.08),
              blurRadius: 22.r,
              offset: Offset(0, 12.h),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 6.h,
            decoration: BoxDecoration(color: tone),
          ),
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Quiz Result',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDark
                            ? SumAcademyTheme.white
                            : SumAcademyTheme.darkBase,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: tone.withOpacityFloat(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _resultLabel(clamped),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: tone,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Container(
                      width: 78.r,
                      height: 78.r,
                      decoration: BoxDecoration(
                        color: tone.withOpacityFloat(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: tone.withOpacityFloat(0.3)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${clamped.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: tone,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Score Percentage',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color:
                                      (isDark
                                              ? SumAcademyTheme.white
                                              : SumAcademyTheme.darkBase)
                                          .withOpacityFloat(0.6),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          SizedBox(height: 6.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: clamped / 100,
                              minHeight: 6.h,
                              backgroundColor: SumAcademyTheme.brandBluePale,
                              valueColor: AlwaysStoppedAnimation(tone),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'You completed the quiz. Review your results anytime from the quizzes tab.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color:
                                      (isDark
                                              ? SumAcademyTheme.white
                                              : SumAcademyTheme.darkBase)
                                          .withOpacityFloat(0.7),
                                  height: 1.5,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int index;
  final StudentQuizQuestion question;
  final StudentQuizAttemptController controller;

  const _QuestionCard({
    required this.index,
    required this.question,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark
        ? SumAcademyTheme.darkSurface
        : SumAcademyTheme.white;
    final border = isDark
        ? SumAcademyTheme.darkBorder
        : SumAcademyTheme.brandBluePale;
    final textColor = isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: border),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: SumAcademyTheme.brandBlue.withOpacityFloat(0.08),
              blurRadius: 22.r,
              offset: Offset(0, 12.h),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 6.h,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  SumAcademyTheme.brandBlue,
                  SumAcademyTheme.brandBlueDarker,
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question $index',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: SumAcademyTheme.brandBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  question.text.isNotEmpty ? question.text : 'Question',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16.h),
                if (question.hasOptions)
                  ...question.options.map((option) {
                    final value = option.id.isNotEmpty
                        ? option.id
                        : option.label;
                    return Obx(() {
                      final selected =
                          controller.answerFor(question.id) == value;
                      return Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        decoration: BoxDecoration(
                          color: selected
                              ? SumAcademyTheme.brandBluePale
                              : isDark
                              ? SumAcademyTheme.darkBorder
                              : SumAcademyTheme.surfaceSecondary,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: selected
                                ? SumAcademyTheme.brandBlue
                                : SumAcademyTheme.brandBluePale,
                          ),
                        ),
                        child: RadioListTile<String>(
                          value: value,
                          groupValue: controller.answerFor(question.id),
                          onChanged: (value) {
                            if (value != null) {
                              controller.setAnswer(question.id, value);
                            }
                          },
                          activeColor: SumAcademyTheme.brandBlue,
                          title: Text(
                            option.label,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      );
                    });
                  })
                else
                  TextField(
                    controller: controller.controllerFor(question.id),
                    onChanged: (value) =>
                        controller.setAnswer(question.id, value),
                    decoration: const InputDecoration(
                      hintText: 'Type your answer',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDuration(int totalSeconds) {
  if (totalSeconds < 0) totalSeconds = 0;
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

String _resultLabel(double percent) {
  if (percent >= 85) return 'Excellent';
  if (percent >= 70) return 'Great Job';
  if (percent >= 50) return 'Good Effort';
  return 'Keep Going';
}

Color _resultTone(double percent) {
  if (percent >= 85) return SumAcademyTheme.success;
  if (percent >= 70) return SumAcademyTheme.brandBlue;
  if (percent >= 50) return SumAcademyTheme.accentOrange;
  return SumAcademyTheme.warning;
}
