import 'dart:ui';

import 'package:sum_academy/modules/home/models/course.dart';
import 'package:sum_academy/modules/home/models/live_session.dart';

class HomeDashboard {
  final String learnerName;
  final int enrolledCourses;
  final int learningHours;
  final int learningStreakDays;
  final double weeklyGoalHours;
  final double weeklyProgressHours;
  final Course continueCourse;
  final List<Course> featuredCourses;
  final List<LiveSession> liveSessions;
  final List<String> categories;
  final List<int> highlightedCategoryIndexes;

  const HomeDashboard({
    required this.learnerName,
    required this.enrolledCourses,
    required this.learningHours,
    required this.learningStreakDays,
    required this.weeklyGoalHours,
    required this.weeklyProgressHours,
    required this.continueCourse,
    required this.featuredCourses,
    required this.liveSessions,
    required this.categories,
    required this.highlightedCategoryIndexes,
  });

  factory HomeDashboard.empty() {
    return HomeDashboard(
      learnerName: '',
      enrolledCourses: 0,
      learningHours: 0,
      learningStreakDays: 0,
      weeklyGoalHours: 0,
      weeklyProgressHours: 0,
      continueCourse: Course(
        title: '',
        subtitle: '',
        duration: '',
        progress: 0,
        accent: Color(0x00000000),
        tags: const [],
      ),
      featuredCourses: const [],
      liveSessions: const [],
      categories: const [],
      highlightedCategoryIndexes: const [],
    );
  }
}

