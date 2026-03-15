import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/home/models/course.dart';
import 'package:sum_academy/modules/home/models/home_dashboard.dart';
import 'package:sum_academy/modules/home/models/live_session.dart';

class HomeService {
  HomeDashboard fetchDashboard() {
    return HomeDashboard(
      learnerName: 'Sum Learner',
      enrolledCourses: 12,
      learningHours: 34,
      learningStreakDays: 5,
      weeklyGoalHours: 6.0,
      weeklyProgressHours: 4.5,
      continueCourse: Course(
        title: 'Product Thinking for LMS Teams',
        subtitle: 'Outcomes, research, and feedback loops',
        duration: '3h 10m',
        progress: 0.68,
        accent: SumAcademyTheme.brandBlue,
        tags: const ['Product', 'Strategy'],
      ),
      featuredCourses: [
        Course(
          title: 'Flutter Foundations',
          subtitle: 'Build calm, confident UI',
          duration: '4h 30m',
          progress: 0.18,
          accent: SumAcademyTheme.brandBlueLight,
          tags: const ['Mobile', 'Dart'],
        ),
        Course(
          title: 'Data Storytelling',
          subtitle: 'Turn metrics into decisions',
          duration: '2h 50m',
          progress: 0.4,
          accent: SumAcademyTheme.brandBlue,
          tags: const ['Analytics', 'Comms'],
        ),
        Course(
          title: 'Brand Systems Sprint',
          subtitle: 'Design identity that scales',
          duration: '5h 05m',
          progress: 0.62,
          accent: SumAcademyTheme.accentOrange,
          tags: const ['Design', 'Brand'],
        ),
      ],
      liveSessions: const [
        LiveSession(
          title: 'Mentor roundtable: Course launches',
          host: 'Ayesha K.',
          time: 'Tue | 6:00 PM',
          seatsLeft: 8,
        ),
        LiveSession(
          title: 'Live build: Enrollment funnel teardown',
          host: 'Rizwan S.',
          time: 'Thu | 7:30 PM',
          seatsLeft: 12,
        ),
      ],
      categories: const [
        'Product Design',
        'Learning Science',
        'Data Analytics',
        'Flutter',
        'Brand Strategy',
        'Growth Marketing',
        'Leadership',
        'AI for Educators',
      ],
      highlightedCategoryIndexes: const [1, 3, 6],
    );
  }
}
