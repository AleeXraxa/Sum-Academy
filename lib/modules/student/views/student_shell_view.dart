import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/widgets/app_bootstrap_loader.dart';
import 'package:sum_academy/modules/auth/bindings/login_binding.dart';
import 'package:sum_academy/modules/auth/services/auth_service.dart';
import 'package:sum_academy/modules/auth/views/login_view.dart';
import 'package:sum_academy/modules/home/controllers/home_controller.dart';
import 'package:sum_academy/modules/home/views/home_view.dart';
import 'package:sum_academy/modules/student/controllers/student_shell_controller.dart';
import 'package:sum_academy/modules/student/views/explore_courses_view.dart';
import 'package:sum_academy/modules/student/views/help_support_view.dart';
import 'package:sum_academy/modules/student/views/my_courses_view.dart';
import 'package:sum_academy/modules/student/views/student_placeholder_view.dart';
import 'package:sum_academy/modules/student/widgets/student_sidebar.dart';

class StudentShellView extends GetView<StudentShellController> {
  const StudentShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final authService = Get.find<AuthService>();
      final homeController = Get.find<HomeController>();
      final isBootLoading = homeController.isLoading.value;
      final pages = <Widget>[
        const HomeDashboardContent(),
        const MyCoursesView(),
        const ExploreCoursesView(),
        const StudentPlaceholderView(
          title: 'My Certificates',
          icon: Icons.verified_rounded,
        ),
        const StudentPlaceholderView(
          title: 'Quizzes',
          icon: Icons.quiz_rounded,
        ),
        const StudentPlaceholderView(
          title: 'Payments',
          icon: Icons.payments_rounded,
        ),
        const StudentPlaceholderView(
          title: 'Announcements',
          icon: Icons.campaign_rounded,
        ),
        const HelpSupportView(),
        const StudentPlaceholderView(
          title: 'Settings',
          icon: Icons.settings_rounded,
        ),
      ];

      return Scaffold(
        drawer: StudentSidebar(
          userName: controller.userName.value,
          activeItem: controller.activeLabel.value,
          onItemSelected: (label) async {
            if (label == 'Logout') {
              await authService.logout();
              Get.offAll(() => const LoginView(), binding: LoginBinding());
              return;
            }
            controller.setActiveLabel(label);
            Get.back();
          },
        ),
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
                  children: pages,
                ),
                if (isBootLoading)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: SumAcademyTheme.white.withOpacityFloat(0.9),
                        alignment: Alignment.center,
                        child: const AppBootstrapLoader(
                          message: 'Preparing your student dashboard...',
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
