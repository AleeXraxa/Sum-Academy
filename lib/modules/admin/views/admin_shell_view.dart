import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/controllers/admin_controller.dart';
import 'package:sum_academy/modules/admin/utils/admin_navigation.dart';
import 'package:sum_academy/modules/admin/views/common/admin_placeholder_view.dart';
import 'package:sum_academy/modules/admin/views/dashboard/admin_dashboard_view.dart';
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

      final activeLabel = activeLabelForIndex(controller.navIndex.value);

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
              Get.back();
              controller.setNavIndex(targetIndex);
            }
          },
        ),
        bottomNavigationBar: CurvedNavigationBar(
          index: controller.navIndex.value,
          height: 60.h,
          backgroundColor: Colors.transparent,
          color: SumAcademyTheme.brandBlue,
          buttonBackgroundColor: SumAcademyTheme.darkBase,
          animationDuration: const Duration(milliseconds: 280),
          items: [
            Icon(
              Icons.dashboard_rounded,
              color: SumAcademyTheme.white,
              size: 22.sp,
            ),
            Icon(
              Icons.group_rounded,
              color: SumAcademyTheme.white,
              size: 22.sp,
            ),
            Icon(
              Icons.payments_rounded,
              color: SumAcademyTheme.white,
              size: 22.sp,
            ),
            Icon(
              Icons.settings_rounded,
              color: SumAcademyTheme.white,
              size: 22.sp,
            ),
          ],
          onTap: controller.setNavIndex,
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
            child: IndexedStack(
              index: controller.navIndex.value,
              children: [
                AdminDashboardView(
                  controller: controller,
                  textColor: textColor,
                  surface: surface,
                  isDark: isDark,
                  userName: name,
                  isSearchExpanded: isSearchExpanded,
                ),
                AdminUsersView(
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
          ),
        ),
      );
    });
  }
}
