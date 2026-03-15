import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

int _alphaFromOpacity(double opacity) {
  final value = (opacity * 255).round();
  if (value < 0) {
    return 0;
  }
  if (value > 255) {
    return 255;
  }
  return value;
}

extension ColorOpacityX on Color {
  Color withOpacityFloat(double opacity) => withAlpha(_alphaFromOpacity(opacity));
}

class SumAcademyTheme {
  const SumAcademyTheme._();

  // Primary colors
  static const Color brandBlue = Color(0xFF4A63F5);
  static const Color brandBlueDark = Color(0xFF3347E8);
  static const Color brandBlueDarker = Color(0xFF2535CC);
  static const Color brandBlueLight = Color(0xFF7088FF);
  static const Color brandBluePale = Color(0xFFF0F4FF);

  // Accent colors
  static const Color accentOrange = Color(0xFFFF6F0F);
  static const Color accentOrangeDark = Color(0xFFF05206);
  static const Color accentOrangePale = Color(0xFFFFF8ED);

  // Dark & background colors
  static const Color darkBase = Color(0xFF0D0F1A);
  static const Color darkSurface = Color(0xFF12162B);
  static const Color darkElevated = Color(0xFF181D35);
  static const Color darkBorder = Color(0xFF252A45);
  static const Color white = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF8F9FE);
  static const Color surfaceTertiary = Color(0xFFF0F3FF);

  // Status & semantic colors
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFCA8A04);
  static const Color warningLight = Color(0xFFFEF9C3);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Role accent colors
  static const Color adminPurple = Color(0xFF7C3AED);
  static const Color teacherBlue = info;
  static const Color studentGreen = success;

  // Radius tokens
  static const double radiusButton = 12;
  static const double radiusCard = 16;
  static const double radiusLargeCard = 20;
  static const double radiusInput = 12;
  static const double radiusPill = 999;
  static const double radiusAvatar = 100;
  static const double radiusTag = 8;

  static TextStyle mono({double? fontSize, FontWeight? fontWeight, Color? color}) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseTextTheme = ThemeData(brightness: brightness).textTheme;
    final bodyTextTheme = GoogleFonts.dmSansTextTheme(baseTextTheme);
    final headingTextTheme = GoogleFonts.playfairDisplayTextTheme(baseTextTheme);

    final textColor = brightness == Brightness.dark ? white : darkBase;
    final mutedColor = textColor.withOpacityFloat(0.72);

    return bodyTextTheme.copyWith(
      displayLarge: headingTextTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
        color: textColor,
      ),
      displayMedium: headingTextTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.9,
        color: textColor,
      ),
      headlineLarge: headingTextTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: textColor,
      ),
      headlineMedium: headingTextTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: textColor,
      ),
      headlineSmall: headingTextTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: textColor,
      ),
      titleLarge: headingTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: headingTextTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: bodyTextTheme.bodyLarge?.copyWith(
        color: textColor,
        height: 1.4,
      ),
      bodyMedium: bodyTextTheme.bodyMedium?.copyWith(
        color: mutedColor,
        height: 1.4,
      ),
      bodySmall: bodyTextTheme.bodySmall?.copyWith(
        color: mutedColor,
      ),
      labelLarge: bodyTextTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      labelMedium: bodyTextTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brandBlue,
      brightness: Brightness.light,
    ).copyWith(
      primary: brandBlue,
      secondary: accentOrange,
      surface: white,
      onSurface: darkBase,
      onPrimary: white,
      onSecondary: white,
      error: error,
      onError: white,
      primaryContainer: brandBluePale,
      secondaryContainer: accentOrangePale,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: GoogleFonts.dmSans().fontFamily,
      scaffoldBackgroundColor: surfaceSecondary,
      cardColor: white,
      dialogTheme: const DialogThemeData(backgroundColor: white),
      dividerColor: brandBluePale,
      shadowColor: darkBase.withOpacityFloat(0.12),
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: darkBase,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard.r),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceTertiary,
        hintStyle: TextStyle(color: darkBase.withOpacityFloat(0.55)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput.r),
          borderSide: const BorderSide(color: brandBluePale),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput.r),
          borderSide: const BorderSide(color: brandBluePale),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput.r),
          borderSide: const BorderSide(color: brandBlue, width: 1.4),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandBlue,
          foregroundColor: white,
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton.r),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brandBlue,
          side: const BorderSide(color: brandBluePale),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton.r),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusPill.r),
          side: const BorderSide(color: brandBluePale),
        ),
        labelStyle: TextStyle(color: darkBase.withOpacityFloat(0.8)),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brandBlue,
      brightness: Brightness.dark,
    ).copyWith(
      primary: brandBlueLight,
      secondary: accentOrange,
      surface: darkSurface,
      onSurface: white,
      onPrimary: darkBase,
      onSecondary: darkBase,
      error: error,
      onError: white,
      primaryContainer: darkElevated,
      secondaryContainer: darkElevated,
    );

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: GoogleFonts.dmSans().fontFamily,
      scaffoldBackgroundColor: darkBase,
      cardColor: darkSurface,
      dialogTheme: const DialogThemeData(backgroundColor: darkSurface),
      dividerColor: darkBorder,
      shadowColor: darkBase.withOpacityFloat(0.4),
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: white,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard.r),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkElevated,
        hintStyle: TextStyle(color: white.withOpacityFloat(0.55)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput.r),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput.r),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput.r),
          borderSide: const BorderSide(color: brandBlueLight, width: 1.4),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandBlue,
          foregroundColor: white,
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton.r),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: white,
          side: const BorderSide(color: darkBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton.r),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusPill.r),
          side: const BorderSide(color: darkBorder),
        ),
        labelStyle: TextStyle(color: white.withOpacityFloat(0.85)),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      ),
    );
  }
}



