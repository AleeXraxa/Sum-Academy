import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';

class AdminController extends GetxController {
  final String userName = 'Admin';

  final stats = <AdminStat>[
    const AdminStat(
      label: 'Total Students',
      value: '1,248',
      icon: Icons.school_rounded,
      tone: SumAcademyTheme.brandBluePale,
      iconColor: SumAcademyTheme.brandBlue,
    ),
    const AdminStat(
      label: 'Total Revenue',
      value: '₹ 2.4M',
      icon: Icons.account_balance_wallet_rounded,
      tone: SumAcademyTheme.successLight,
      iconColor: SumAcademyTheme.success,
    ),
    const AdminStat(
      label: 'Active Courses',
      value: '36',
      icon: Icons.menu_book_rounded,
      tone: SumAcademyTheme.accentOrangePale,
      iconColor: SumAcademyTheme.accentOrange,
    ),
    const AdminStat(
      label: 'Enrollments today',
      value: '74',
      icon: Icons.how_to_reg_rounded,
      tone: SumAcademyTheme.infoLight,
      iconColor: SumAcademyTheme.info,
    ),
  ];

  final quickActions = <AdminAction>[
    const AdminAction(
      title: 'Add a course',
      subtitle: 'Create a new learning track',
      icon: Icons.add_circle_outline_rounded,
    ),
    const AdminAction(
      title: 'Review payments',
      subtitle: 'Verify pending transactions',
      icon: Icons.payments_outlined,
    ),
    const AdminAction(
      title: 'Send announcement',
      subtitle: 'Notify all learners',
      icon: Icons.campaign_outlined,
    ),
  ];
}

class AdminStat {
  final String label;
  final String value;
  final IconData icon;
  final Color? tone;
  final Color? iconColor;

  const AdminStat({
    required this.label,
    required this.value,
    required this.icon,
    this.tone,
    this.iconColor,
  });
}

class AdminAction {
  final String title;
  final String subtitle;
  final IconData icon;

  const AdminAction({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
