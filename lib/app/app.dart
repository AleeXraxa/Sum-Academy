import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/bindings/initial_binding.dart';
import 'package:sum_academy/app/routes/app_pages.dart';
import 'package:sum_academy/app/routes/app_routes.dart';
import 'package:sum_academy/app/theme.dart';

class SumAcademyApp extends StatelessWidget {
  const SumAcademyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Sum Academy LMS',
          debugShowCheckedModeBanner: false,
          theme: SumAcademyTheme.light(),
          darkTheme: SumAcademyTheme.dark(),
          themeMode: ThemeMode.light,
          initialRoute: AppRoutes.splash,
          getPages: AppPages.pages,
          initialBinding: InitialBinding(),
        );
      },
    );
  }
}

