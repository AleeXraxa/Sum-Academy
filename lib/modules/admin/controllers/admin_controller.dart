import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/auth/services/auth_service.dart';

class AdminController extends GetxController {
  final RxString userName = 'User'.obs;
  final AuthService _authService = Get.find<AuthService>();
  final RxInt navIndex = 0.obs;
  final RxBool isSearchExpanded = false.obs;
  final TextEditingController searchController = TextEditingController();
  final RxInt userFilterIndex = 0.obs;

  final List<AdminUserFilter> userFilters = const [
    AdminUserFilter(label: 'All', count: 8),
    AdminUserFilter(label: 'Students', count: 5),
    AdminUserFilter(label: 'Teachers', count: 1),
    AdminUserFilter(label: 'Admins', count: 2),
  ];

  final List<AdminUserRow> users = const [
    AdminUserRow(
      initials: 'MA',
      name: 'Muhammad Asim',
      email: 'sasim4589@gmail.com',
      role: 'Admin',
      joinedDate: '29-Mar-2026',
      isActive: true,
      avatarColor: SumAcademyTheme.adminPurple,
    ),
    AdminUserRow(
      initials: 'AK',
      name: 'Ayesha Khan',
      email: 'ayesha.khan@example.com',
      role: 'Student',
      joinedDate: '29-Mar-2026',
      isActive: true,
      avatarColor: SumAcademyTheme.studentGreen,
    ),
    AdminUserRow(
      initials: 'AR',
      name: 'Ali Raza',
      email: 'ali.raza@example.com',
      role: 'Student',
      joinedDate: '29-Mar-2026',
      isActive: true,
      avatarColor: SumAcademyTheme.studentGreen,
    ),
    AdminUserRow(
      initials: 'DA',
      name: 'Dev Alee',
      email: 'dev-alee@outlook.com',
      role: 'Admin',
      joinedDate: '29-Mar-2026',
      isActive: true,
      avatarColor: SumAcademyTheme.adminPurple,
    ),
    AdminUserRow(
      initials: 'WA',
      name: 'Waseem Ali',
      email: 'alikhansoomro252@gmail.com',
      role: 'Student',
      joinedDate: '29-Mar-2026',
      isActive: true,
      avatarColor: SumAcademyTheme.studentGreen,
    ),
    AdminUserRow(
      initials: 'SM',
      name: 'Sir Mansoor Ahmed Mangi',
      email: 'mansoormangi04@gmail.com',
      role: 'Teacher',
      joinedDate: '29-Mar-2026',
      isActive: true,
      avatarColor: SumAcademyTheme.teacherBlue,
    ),
    AdminUserRow(
      initials: 'IA',
      name: 'Ihsan Ali',
      email: 'ihsanalichandio02@gmail.com',
      role: 'Student',
      joinedDate: '29-Mar-2026',
      isActive: true,
      avatarColor: SumAcademyTheme.studentGreen,
    ),
    AdminUserRow(
      initials: 'A',
      name: 'Admin',
      email: 'admin@gmail.com',
      role: 'Admin',
      joinedDate: '17-Mar-2026',
      isActive: true,
      avatarColor: SumAcademyTheme.adminPurple,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    userName.value = await _authService.getCurrentUserName();
  }

  void setNavIndex(int index) {
    navIndex.value = index;
    if (isSearchExpanded.value) {
      closeSearch();
    }
  }

  void setUserFilterIndex(int index) {
    userFilterIndex.value = index;
  }

  void toggleSearch() {
    isSearchExpanded.value = !isSearchExpanded.value;
    if (!isSearchExpanded.value) {
      searchController.clear();
    }
  }

  void closeSearch() {
    isSearchExpanded.value = false;
    searchController.clear();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

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
      value: 'PKR 2.4M',
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

  final recentActivities = <AdminActivity>[
    const AdminActivity(
      title: 'New student enrolled',
      subtitle: 'Ayesha Khan joined Biology 101',
      time: '2m ago',
      icon: Icons.how_to_reg_rounded,
      tone: SumAcademyTheme.infoLight,
      iconColor: SumAcademyTheme.info,
    ),
    const AdminActivity(
      title: 'Payment received',
      subtitle: 'PKR 12,000 for Class IX',
      time: '18m ago',
      icon: Icons.payments_rounded,
      tone: SumAcademyTheme.successLight,
      iconColor: SumAcademyTheme.success,
    ),
    const AdminActivity(
      title: 'Course updated',
      subtitle: 'Added 4 new lectures to Physics',
      time: '1h ago',
      icon: Icons.menu_book_rounded,
      tone: SumAcademyTheme.accentOrangePale,
      iconColor: SumAcademyTheme.accentOrange,
    ),
  ];
}

class AdminUserFilter {
  final String label;
  final int count;

  const AdminUserFilter({required this.label, required this.count});
}

class AdminUserRow {
  final String initials;
  final String name;
  final String email;
  final String role;
  final String joinedDate;
  final bool isActive;
  final Color avatarColor;

  const AdminUserRow({
    required this.initials,
    required this.name,
    required this.email,
    required this.role,
    required this.joinedDate,
    required this.isActive,
    required this.avatarColor,
  });
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

class AdminActivity {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color tone;
  final Color iconColor;

  const AdminActivity({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.tone,
    required this.iconColor,
  });
}
