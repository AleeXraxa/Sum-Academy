import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/widgets/app_bootstrap_loader.dart';
import 'package:sum_academy/modules/admin/controllers/admin_controller.dart';
import 'package:sum_academy/modules/admin/controllers/admin_class_controller.dart';
import 'package:sum_academy/modules/admin/controllers/admin_course_controller.dart';
import 'package:sum_academy/modules/admin/controllers/admin_student_controller.dart';
import 'package:sum_academy/modules/admin/controllers/admin_teacher_controller.dart';
import 'package:sum_academy/modules/admin/utils/admin_navigation.dart';
import 'package:sum_academy/modules/admin/views/analytics/admin_analytics_view.dart';
import 'package:sum_academy/modules/admin/views/common/admin_placeholder_view.dart';
import 'package:sum_academy/modules/admin/views/classes/admin_classes_view.dart';
import 'package:sum_academy/modules/admin/views/courses/admin_courses_view.dart';
import 'package:sum_academy/modules/admin/views/dashboard/admin_dashboard_view.dart';
import 'package:sum_academy/modules/admin/views/students/admin_students_view.dart';
import 'package:sum_academy/modules/admin/views/teachers/admin_teachers_view.dart';
import 'package:sum_academy/modules/admin/views/users/admin_users_view.dart';
import 'package:sum_academy/modules/admin/widgets/admin_sidebar.dart';
import 'package:sum_academy/modules/auth/bindings/login_binding.dart';
import 'package:sum_academy/modules/auth/services/auth_service.dart';
import 'package:sum_academy/modules/auth/views/login_view.dart';

class AdminShellView extends GetView<AdminController> {
  const AdminShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final teacherController = Get.find<AdminTeacherController>();
      final studentController = Get.find<AdminStudentController>();
      final courseController = Get.find<AdminCourseController>();
      final classController = Get.find<AdminClassController>();
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final surface = isDark
          ? SumAcademyTheme.darkSurface
          : SumAcademyTheme.white;
      final textColor = isDark
          ? SumAcademyTheme.white
          : SumAcademyTheme.darkBase;
      final authService = Get.find<AuthService>();
      final name = controller.userName.value;
      final isSearchExpanded = controller.isSearchExpanded.value;
      final activeLabel = controller.navIndex.value == 0
          ? controller.overviewLabel.value
          : controller.navIndex.value == 1
              ? controller.managementLabel.value
              : activeLabelForIndex(controller.navIndex.value);
      final isBootLoading = !controller.isUsersInitialized.value ||
          !controller.isStatsInitialized.value ||
          !controller.isActivitiesInitialized.value ||
          !teacherController.isInitialized.value ||
          !studentController.isInitialized.value ||
          !courseController.isInitialized.value ||
          !classController.isInitialized.value;

      return Scaffold(
        drawer: AdminSidebar(
          role: 'admin',
          userName: name,
          activeItem: activeLabel,
          onItemSelected: (label) async {
            if (label == 'Logout') {
              await authService.logout();
              Get.offAll(() => const LoginView(), binding: LoginBinding());
              return;
            }

            final targetIndex = navIndexForLabel(label);
            if (targetIndex != null) {
              if (targetIndex == 0) {
                controller.setOverviewLabel(label);
              } else if (targetIndex == 1) {
                controller.setManagementLabel(label);
              }
              Get.back();
              controller.setNavIndex(targetIndex);
            }
          },
        ),
        // Bottom navbar removed: navigation handled via sidebar.
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? const [
                      SumAcademyTheme.darkBase,
                      SumAcademyTheme.darkSurface,
                    ]
                  : const [
                      SumAcademyTheme.surfaceSecondary,
                      SumAcademyTheme.surfaceTertiary,
                    ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                IndexedStack(
                  index: controller.navIndex.value,
                  children: [
                    controller.overviewLabel.value == 'Analytics'
                        ? AdminAnalyticsView(
                            controller: controller,
                            textColor: textColor,
                            surface: surface,
                            isDark: isDark,
                            userName: name,
                          )
                        : AdminDashboardView(
                            controller: controller,
                            textColor: textColor,
                            surface: surface,
                            isDark: isDark,
                            userName: name,
                            isSearchExpanded: isSearchExpanded,
                          ),
                    _ManagementShell(
                      controller: controller,
                      textColor: textColor,
                      surface: surface,
                      isDark: isDark,
                      userName: name,
                    ),
                    AdminPlaceholderView(
                      controller: controller,
                      textColor: textColor,
                      surface: surface,
                      isDark: isDark,
                      userName: name,
                      title: 'Payments',
                      icon: Icons.payments_rounded,
                      isSearchExpanded: isSearchExpanded,
                    ),
                    AdminPlaceholderView(
                      controller: controller,
                      textColor: textColor,
                      surface: surface,
                      isDark: isDark,
                      userName: name,
                      title: 'Settings',
                      icon: Icons.settings_rounded,
                      isSearchExpanded: isSearchExpanded,
                    ),
                  ],
                ),
                if (isBootLoading)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: SumAcademyTheme.white.withOpacityFloat(0.9),
                        alignment: Alignment.center,
                        child: const AppBootstrapLoader(
                          message: 'Preparing your admin workspace...',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _ManagementShell extends StatelessWidget {
  final AdminController controller;
  final Color textColor;
  final Color surface;
  final bool isDark;
  final String userName;

  const _ManagementShell({
    required this.controller,
    required this.textColor,
    required this.surface,
    required this.isDark,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final label = controller.managementLabel.value;
    switch (label) {
      case 'Teachers':
        return AdminTeachersView(
          controller: Get.find<AdminTeacherController>(),
          textColor: textColor,
          surface: surface,
          isDark: isDark,
          userName: userName,
        );
      case 'Students':
        return AdminStudentsView(
          controller: Get.find<AdminStudentController>(),
          textColor: textColor,
          surface: surface,
          isDark: isDark,
          userName: userName,
        );
      case 'Courses':
        return AdminCoursesView(
          controller: Get.find<AdminCourseController>(),
          textColor: textColor,
          surface: surface,
          isDark: isDark,
          userName: userName,
        );
      case 'Classes':
        return AdminClassesView(
          controller: Get.find<AdminClassController>(),
          textColor: textColor,
          surface: surface,
          isDark: isDark,
          userName: userName,
        );
      case 'Users':
        return AdminUsersView(
          controller: controller,
          textColor: textColor,
          surface: surface,
          isDark: isDark,
          userName: userName,
        );
      default:
        return AdminPlaceholderView(
          controller: controller,
          textColor: textColor,
          surface: surface,
          isDark: isDark,
          userName: userName,
          title: label,
          icon: _managementIcon(label),
          isSearchExpanded: controller.isSearchExpanded.value,
        );
    }
  }
}

IconData _managementIcon(String label) {
  switch (label) {
    case 'Students':
      return Icons.school_outlined;
    case 'Courses':
      return Icons.menu_book_outlined;
    case 'Classes':
      return Icons.class_outlined;
    default:
      return Icons.group_outlined;
  }
}
