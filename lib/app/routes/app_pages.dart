import 'package:get/get.dart';
import 'package:sum_academy/app/routes/app_routes.dart';
import 'package:sum_academy/modules/auth/bindings/forgot_password_binding.dart';
import 'package:sum_academy/modules/auth/bindings/login_binding.dart';
import 'package:sum_academy/modules/auth/bindings/register_binding.dart';
import 'package:sum_academy/modules/auth/views/forgot_password_view.dart';
import 'package:sum_academy/modules/auth/views/login_view.dart';
import 'package:sum_academy/modules/auth/views/register_view.dart';
import 'package:sum_academy/modules/home/bindings/home_binding.dart';
import 'package:sum_academy/modules/home/views/home_view.dart';
import 'package:sum_academy/modules/onboarding/bindings/onboarding_binding.dart';
import 'package:sum_academy/modules/onboarding/views/onboarding_view.dart';
import 'package:sum_academy/modules/splash/bindings/splash_binding.dart';
import 'package:sum_academy/modules/splash/views/splash_view.dart';

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
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
  ];
}
