import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';
import 'package:sum_academy/modules/student/models/student_test.dart';
import 'package:sum_academy/modules/student/services/student_tests_service.dart';
import 'package:sum_academy/modules/student/views/student_test_result_view.dart';

class StudentTestAttemptView extends StatefulWidget {
  final String testId;
  final StudentTestsService service;

  const StudentTestAttemptView({
    super.key,
    required this.testId,
    required this.service,
  });

  @override
  State<StudentTestAttemptView> createState() => _StudentTestAttemptViewState();
}

class _StudentTestAttemptViewState extends State<StudentTestAttemptView> {
  bool _isLoading = true;
  String _error = '';
  StudentTestDetail? _detail;
  String _selected = '';
  bool _submitting = false;
  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = '';
      _selected = '';
    });
    try {
      final meta = await widget.service.fetchTestDetail(widget.testId);
      if (!meta.test.isActiveNow) {
        _error = _outsideScheduleMessage(meta.test);
        return;
      }

      final detail = await widget.service.startOrResume(widget.testId);
      _detail = detail;
      _setupTimer(detail);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _outsideScheduleMessage(StudentTest test) {
    final start = test.startAt;
    final end = test.endAt;
    if (start == null || end == null) {
      return 'This test schedule is not available yet.';
    }
    if (test.isUpcoming) {
      return 'Test starts at ${_formatFull(start)}.';
    }
    if (test.isEnded) {
      return 'This test has ended.';
    }
    return 'This test is not available right now.';
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

  void _setupTimer(StudentTestDetail detail) {
    _timer?.cancel();
    final endAt = detail.test.endAt;
    final startedAt = detail.attemptStartedAt ?? DateTime.now();
    final durationMinutes = detail.test.durationMinutes;
    final byDuration = durationMinutes > 0
        ? startedAt.add(Duration(minutes: durationMinutes))
        : null;

    // Primary rule: never allow attempt beyond scheduled `endAt`.
    // If durationMinutes is missing/0, fall back to schedule window only.
    final hardEnd = endAt == null
        ? (byDuration ?? startedAt)
        : (byDuration == null
            ? endAt
            : (endAt.isBefore(byDuration) ? endAt : byDuration));
    final seconds = hardEnd.difference(DateTime.now()).inSeconds;
    _remainingSeconds = seconds < 0 ? 0 : seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted) return;
      setState(() {
        _remainingSeconds = (_remainingSeconds - 1).clamp(0, 1000000000);
      });
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        await _finish(reason: 'auto');
      }
    });
  }

  Future<void> _submitAnswer() async {
    final detail = _detail;
    final question = detail?.currentQuestion;
    if (detail == null || question == null) return;
    if (_selected.trim().isEmpty) {
      await showErrorDialog(context, title: 'Answer', message: 'Select an option.');
      return;
    }
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await widget.service.answer(
        testId: widget.testId,
        questionId: question.id,
        selectedAnswer: _selected,
      );
      final refreshed = await widget.service.fetchTestDetail(widget.testId);
      _detail = refreshed;
      _selected = '';
      if (mounted) setState(() {});
      if (refreshed.isFinished || refreshed.currentQuestion == null) {
        await _finish(reason: 'manual');
      }
    } catch (e) {
      await showErrorDialog(
        context,
        title: 'Submit failed',
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _finish({required String reason}) async {
    if (!mounted) return;
    showLoadingDialog(context, message: 'Submitting test...');
    try {
      final finishResponse =
          await widget.service.finish(testId: widget.testId, reason: reason);
      final rankingResponse = await widget.service.fetchRanking(widget.testId);
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      Get.off(
        () => StudentTestResultView(
          finishResponse: finishResponse,
          rankingResponse: rankingResponse,
        ),
      );
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      await showErrorDialog(
        context,
        title: 'Finish failed',
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> _confirmExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit test?'),
        content:
            const Text('If you exit now, you can resume during the active time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _detail?.test.title.isNotEmpty == true
                            ? _detail!.test.title
                            : 'Test',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    _TimerChip(seconds: _remainingSeconds),
                    SizedBox(width: 6.w),
                    TextButton(
                      onPressed: () async {
                        final ok = await _confirmExit();
                        if (ok && mounted) Get.back();
                      },
                      child: const Text('Exit'),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (_isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (_error.isNotEmpty) {
                        return _ErrorState(message: _error, onRetry: _load);
                      }
                      final detail = _detail;
                      final question = detail?.currentQuestion;
                      if (detail == null || question == null) {
                        return const Center(child: Text('No questions available.'));
                      }
                      return ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          Text(
                            'Question ${detail.currentQuestionNumber}${detail.totalQuestions > 0 ? ' / ${detail.totalQuestions}' : ''}',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: SumAcademyTheme.brandBlue,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? SumAcademyTheme.darkSurface
                                  : SumAcademyTheme.white,
                              borderRadius: BorderRadius.circular(18.r),
                              border: Border.all(
                                color: isDark
                                    ? SumAcademyTheme.white.withOpacityFloat(0.08)
                                    : SumAcademyTheme.brandBluePale,
                              ),
                            ),
                            child: Text(
                              question.text.isEmpty ? 'Question' : question.text,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          ...question.options.map(
                            (opt) => Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: InkWell(
                                onTap: _submitting
                                    ? null
                                    : () => setState(() => _selected = opt),
                                borderRadius: BorderRadius.circular(16.r),
                                child: Container(
                                  padding: EdgeInsets.all(14.r),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? SumAcademyTheme.darkSurface
                                        : SumAcademyTheme.white,
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: _selected == opt
                                          ? SumAcademyTheme.brandBlue
                                          : (isDark
                                              ? SumAcademyTheme.white
                                                  .withOpacityFloat(0.08)
                                              : SumAcademyTheme.brandBluePale),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _selected == opt
                                            ? Icons.radio_button_checked_rounded
                                            : Icons.radio_button_off_rounded,
                                        color: _selected == opt
                                            ? SumAcademyTheme.brandBlue
                                            : textColor.withOpacityFloat(0.45),
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Text(
                                          opt,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color:
                                                    textColor.withOpacityFloat(0.85),
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitting ? null : _submitAnswer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: SumAcademyTheme.brandBlue,
                                foregroundColor: SumAcademyTheme.white,
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.r),
                                ),
                              ),
                              child: Text(_submitting ? 'Submitting...' : 'Next'),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'Note: once you answer, you cannot go back to previous questions.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: textColor.withOpacityFloat(0.6),
                                ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerChip extends StatelessWidget {
  final int seconds;

  const _TimerChip({required this.seconds});

  @override
  Widget build(BuildContext context) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    final danger = seconds <= 60;
    final color = danger ? SumAcademyTheme.error : SumAcademyTheme.brandBlue;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacityFloat(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacityFloat(0.25)),
      ),
      child: Text(
        '$mins:$secs',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
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
            'Unable to load test',
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
