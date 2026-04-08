import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/student/models/student_quiz.dart';
import 'package:sum_academy/modules/student/controllers/student_quizzes_controller.dart';
import 'package:sum_academy/modules/student/services/student_quiz_service.dart';

class StudentQuizAttemptController extends GetxController {
  StudentQuizAttemptController({
    required this.quizId,
    required this.quizTitle,
    StudentQuizService? service,
  }) : _service = service ?? StudentQuizService();

  final String quizId;
  final String quizTitle;
  final StudentQuizService _service;

  final isLoading = true.obs;
  final questions = <StudentQuizQuestion>[].obs;
  final answers = <String, String>{}.obs;
  final currentIndex = 0.obs;
  final isSubmitting = false.obs;
  final resultPercent = RxnDouble();
  final elapsedSeconds = 0.obs;

  Timer? _quizTimer;

  final _textControllers = <String, TextEditingController>{};

  @override
  void onInit() {
    super.onInit();
    _loadQuiz();
  }

  @override
  void onClose() {
    _stopTimer();
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }

  Future<void> _loadQuiz() async {
    isLoading.value = true;
    try {
      final detail = await _service.fetchQuiz(quizId);
      questions.assignAll(detail.questions);
      currentIndex.value = 0;
      _startTimer();
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showAppErrorDialog(
          title: 'Quiz failed',
          message: e.message,
        );
      }
    } catch (_) {
      await showAppErrorDialog(
        title: 'Quiz failed',
        message: 'Unable to load quiz.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  TextEditingController controllerFor(String questionId) {
    if (_textControllers.containsKey(questionId)) {
      return _textControllers[questionId]!;
    }
    final controller = TextEditingController(text: answers[questionId] ?? '');
    _textControllers[questionId] = controller;
    return controller;
  }

  void setAnswer(String questionId, String answer) {
    answers[questionId] = answer;
    answers.refresh();
  }

  String answerFor(String questionId) {
    return answers[questionId] ?? '';
  }

  bool get canGoNext => currentIndex.value < questions.length - 1;
  bool get canGoPrevious => currentIndex.value > 0;

  void goNext() {
    if (canGoNext) {
      currentIndex.value += 1;
    }
  }

  void goPrevious() {
    if (canGoPrevious) {
      currentIndex.value -= 1;
    }
  }

  Future<void> submit() async {
    final missing = questions
        .where((question) => answerFor(question.id).trim().isEmpty)
        .toList();
    if (missing.isNotEmpty) {
      await showAppErrorDialog(
        title: 'Incomplete',
        message: 'Please answer all questions before submitting.',
      );
      return;
    }

    final payload = questions
        .map(
          (question) => {
            'questionId': question.id,
            'answer': answerFor(question.id),
          },
        )
        .toList();

    if (isSubmitting.value) return;
    isSubmitting.value = true;
    try {
      final result = await _service.submitQuiz(
        quizId: quizId,
        answers: payload,
      );
      final percent = _computePercent(result);
      resultPercent.value = percent;
      _stopTimer();
      if (Get.isRegistered<StudentQuizzesController>()) {
        Get.find<StudentQuizzesController>().markAttempted(
          quizId,
          scorePercent: percent,
        );
      }
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showAppErrorDialog(
          title: 'Submit failed',
          message: e.message,
        );
      }
    } catch (_) {
      await showAppErrorDialog(
        title: 'Submit failed',
        message: 'Please try again.',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void _startTimer() {
    _quizTimer?.cancel();
    elapsedSeconds.value = 0;
    _quizTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds.value += 1;
    });
  }

  void _stopTimer() {
    _quizTimer?.cancel();
    _quizTimer = null;
  }

  double _computePercent(Map<String, dynamic> result) {
    final percent = _readDouble(
      result,
      const [
        'scorePercent',
        'percentage',
        'percent',
        'scorePercentage',
        'resultPercent',
      ],
    );
    if (percent > 0) return percent.clamp(0, 100);

    final nested = result['result'] ?? result['attempt'] ?? result['submission'];
    if (nested is Map) {
      final nestedMap = Map<String, dynamic>.from(nested);
      final nestedPercent = _readDouble(
        nestedMap,
        const [
          'scorePercent',
          'percentage',
          'percent',
          'scorePercentage',
          'resultPercent',
        ],
      );
      if (nestedPercent > 0) return nestedPercent.clamp(0, 100);
    }

    final score = _readDouble(
      result,
      const ['score', 'marksObtained', 'obtainedMarks', 'points', 'result'],
    );
    final total = _readDouble(
      result,
      const ['total', 'totalMarks', 'maxMarks', 'totalScore', 'outOf'],
    );
    if (score > 0 && total > 0) {
      return ((score / total) * 100).clamp(0, 100);
    }

    final computedTotal = _totalMarks();
    if (score > 0 && computedTotal > 0) {
      return ((score / computedTotal) * 100).clamp(0, 100);
    }

    if (score > 0 && score <= 100) {
      return score;
    }
    return 0;
  }

  int _totalMarks() {
    if (questions.isEmpty) return 0;
    final total = questions.fold<int>(
      0,
      (sum, question) => sum + (question.marks > 0 ? question.marks : 1),
    );
    return total > 0 ? total : questions.length;
  }

  double _readDouble(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      if (value is num) return value.toDouble();
      final parsed = double.tryParse(value.toString());
      if (parsed != null) return parsed;
    }
    return 0;
  }
}
