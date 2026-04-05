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

  final _textControllers = <String, TextEditingController>{};

  @override
  void onInit() {
    super.onInit();
    _loadQuiz();
  }

  @override
  void onClose() {
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

    try {
      final result = await _service.submitQuiz(
        quizId: quizId,
        answers: payload,
      );
      final score = result['score']?.toString() ?? '';
      await showAppSuccessDialog(
        title: 'Quiz Submitted',
        message: score.isNotEmpty ? 'Score: $score' : 'Your quiz was submitted.',
      );
      if (Get.isRegistered<StudentQuizzesController>()) {
        Get.find<StudentQuizzesController>().markAttempted(quizId);
      }
      Get.back();
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
    }
  }
}
