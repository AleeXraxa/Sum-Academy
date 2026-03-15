import 'package:flutter/material.dart';

class Course {
  final String title;
  final String subtitle;
  final String duration;
  final double progress;
  final Color accent;
  final List<String> tags;

  const Course({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.progress,
    required this.accent,
    required this.tags,
  });
}

