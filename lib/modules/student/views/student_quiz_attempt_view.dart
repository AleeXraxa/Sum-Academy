import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/utils/network_error.dart';
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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (Get.isRegistered<StudentQuizAttemptController>(tag: widget.quizId)) {
      Get.delete<StudentQuizAttemptController>(tag: widget.quizId);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _showFocusWarning();
    }
  }

  Future<void> _showFocusWarning() async {
    if (_warningVisible) return;
    _warningVisible = true;
    await showAppErrorDialog(
      title: 'Quiz Warning',
      message: 'Please stay in the quiz until you submit. Leaving may forfeit your attempt.',
    );
    _warningVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return WillPopScope(
      onWillPop: () async {
        await _showFocusWarning();
        return false;
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
                return const Center(child: CircularProgressIndicator());
              }
              return ListView(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
                children: [
                  _AttemptHeader(title: widget.quizTitle),
                  SizedBox(height: 16.h),
                  _ProgressCard(
                    total: _controller.questions.length,
                    answered: _controller.answers.length,
                  ),
                  SizedBox(height: 16.h),
                  ..._controller.questions
                      .asMap()
                      .entries
                      .map(
                        (entry) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _QuestionCard(
                            index: entry.key + 1,
                            question: entry.value,
                            controller: _controller,
                          ),
                        ),
                      )
                      .toList(),
                  SizedBox(height: 18.h),
                  SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: _controller.submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SumAcademyTheme.brandBlue,
                        foregroundColor: SumAcademyTheme.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                      ),
                      child: const Text('Submit Quiz'),
                    ),
                  ),
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

  const _AttemptHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            title.isNotEmpty ? title : 'Quiz',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: SumAcademyTheme.darkBase,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int total;
  final int answered;

  const _ProgressCard({required this.total, required this.answered});

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : answered / total;
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: SumAcademyTheme.darkBase,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6.h,
              backgroundColor: SumAcademyTheme.brandBluePale,
              valueColor:
                  const AlwaysStoppedAnimation(SumAcademyTheme.brandBlue),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '$answered of $total answered',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
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
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
      ),
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
          SizedBox(height: 6.h),
          Text(
            question.text.isNotEmpty ? question.text : 'Question',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SumAcademyTheme.darkBase,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 10.h),
          if (question.hasOptions)
            ...question.options.map((option) {
              final value = option.id.isNotEmpty ? option.id : option.label;
              return Obx(() {
                final selected = controller.answerFor(question.id) == value;
                return Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  decoration: BoxDecoration(
                    color: selected
                        ? SumAcademyTheme.brandBluePale
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: SumAcademyTheme.darkBase,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                );
              });
            }).toList()
          else
            TextField(
              controller: controller.controllerFor(question.id),
              onChanged: (value) => controller.setAnswer(question.id, value),
              decoration: const InputDecoration(hintText: 'Type your answer'),
            ),
        ],
      ),
    );
  }
}
