import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/student/models/student_quiz.dart';
import 'package:sum_academy/modules/student/services/student_quiz_service.dart';

class StudentQuizzesController extends GetxController {
  StudentQuizzesController(this._service);

  final StudentQuizService _service;

  final isLoading = true.obs;
  final activeTab = 'Available'.obs;
  final quizzes = <StudentQuizSummary>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchQuizzes();
  }

  Future<void> fetchQuizzes() async {
    isLoading.value = true;
    try {
      final items = await _service.fetchQuizzes();
      quizzes.assignAll(items);
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showAppErrorDialog(
          title: 'Failed to load quizzes',
          message: e.message,
        );
      }
    } catch (_) {
      await showAppErrorDialog(
        title: 'Failed to load quizzes',
        message: 'Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void setTab(String tab) {
    activeTab.value = tab;
  }

  List<StudentQuizSummary> get availableQuizzes => quizzes
      .where((quiz) => quiz.isAvailable && !quiz.isAttempted)
      .toList();

  List<StudentQuizSummary> get attemptedQuizzes => quizzes
      .where((quiz) => quiz.isAttempted || !quiz.isAvailable)
      .toList();

  void markAttempted(String quizId, {double? scorePercent}) {
    final index = quizzes.indexWhere((q) => q.id == quizId);
    if (index < 0) return;
    final quiz = quizzes[index];
    quizzes[index] = StudentQuizSummary(
      id: quiz.id,
      title: quiz.title,
      courseTitle: quiz.courseTitle,
      subject: quiz.subject,
      status: 'attempted',
      assigned: false,
      questionCount: quiz.questionCount,
      totalMarks: quiz.totalMarks,
      scorePercent: scorePercent ?? quiz.scorePercent,
    );
    quizzes.refresh();
  }
}
