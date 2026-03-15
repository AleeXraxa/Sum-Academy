import 'package:flutter/material.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/onboarding/models/onboarding_page.dart';

const List<OnboardingPageData> onboardingPages = [
  OnboardingPageData(
    title: 'Track progress in real time',
    subtitle:
        'Monitor attendance, grades, and performance with smart dashboards that keep everyone aligned.',
    tag: 'Smart analytics',
    icon: Icons.analytics_rounded,
    accent: SumAcademyTheme.brandBlue,
    accentSoft: SumAcademyTheme.brandBluePale,
    highlights: ['Attendance', 'Grades', 'Insights'],
  ),
  OnboardingPageData(
    title: 'Build courses that feel premium',
    subtitle:
        'Organize lessons, upload resources, and publish content with a clean, scalable workflow.',
    tag: 'Structured content',
    icon: Icons.menu_book_rounded,
    accent: SumAcademyTheme.accentOrange,
    accentSoft: SumAcademyTheme.accentOrangePale,
    highlights: ['Lessons', 'Resources', 'Curriculum'],
  ),
  OnboardingPageData(
    title: 'Engage learners everywhere',
    subtitle:
        'Deliver live classes, discussions, and updates across every screen with ease.',
    tag: 'Connected learning',
    icon: Icons.groups_rounded,
    accent: SumAcademyTheme.info,
    accentSoft: SumAcademyTheme.infoLight,
    highlights: ['Live sessions', 'Community', 'Updates'],
  ),
];
