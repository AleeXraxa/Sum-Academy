import 'package:get/get.dart';
import 'package:sum_academy/app/routes/app_routes.dart';
import 'package:sum_academy/modules/admin/bindings/admin_binding.dart';
import 'package:sum_academy/modules/admin/views/admin_shell_view.dart';
import 'package:sum_academy/modules/auth/bindings/forgot_password_binding.dart';
import 'package:sum_academy/modules/auth/bindings/login_binding.dart';
import 'package:sum_academy/modules/auth/bindings/register_binding.dart';
import 'package:sum_academy/modules/auth/views/forgot_password_view.dart';
import 'package:sum_academy/modules/auth/views/login_view.dart';
import 'package:sum_academy/modules/auth/views/register_view.dart';
import 'package:sum_academy/modules/onboarding/bindings/onboarding_binding.dart';
import 'package:sum_academy/modules/onboarding/views/onboarding_view.dart';
import 'package:sum_academy/modules/splash/bindings/splash_binding.dart';
import 'package:sum_academy/modules/splash/views/splash_view.dart';
import 'package:sum_academy/modules/student/bindings/student_binding.dart';
import 'package:sum_academy/modules/student/views/student_shell_view.dart';

class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const StudentShellView(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppRoutes.student,
      page: () => const StudentShellView(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppRoutes.admin,
      page: () => const AdminShellView(),
      binding: AdminBinding(),
    ),
  ];
}
