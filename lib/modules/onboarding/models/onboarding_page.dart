import 'package:flutter/material.dart';

class OnboardingPageData {
  final String title;
  final String subtitle;
  final String tag;
  final IconData icon;
  final Color accent;
  final Color accentSoft;
  final List<String> highlights;

  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.icon,
    required this.accent,
    required this.accentSoft,
    required this.highlights,
  });
}
