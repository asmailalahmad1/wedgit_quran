// lib/themes/app_themes.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// تعريف الألوان المطلوبة في وصف التصميم
class AppColors {
  static const Color primaryIndigo =
      Color(0xFF2E6560); // اللون الأساسي: نيلي داكن
  static const Color accentGold = Color(0xFFB8860B); // لون التمييز: ذهبي باهت
  static const Color lightBackground =
      Color(0xFFF0F0F0); // خلفية فاتحة: رمادي فاتح
  static const Color darkBackground =
      Color(0xFF333333); // خلفية داكنة: فحمي داكن

  static const Color lightIcon = Colors.white; // أيقونة بيضاء للوضع الداكن
  static const Color darkIcon =
      Color(0xFF424242); // أيقونة رمادية داكنة للوضع الفاتح
}

class AppThemes {
  // --- الثيم الفاتح (Light Theme) ---
  static final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.primaryIndigo,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryIndigo,
        secondary: AppColors.accentGold,
        background: AppColors.lightBackground,
        surface:
            Colors.white, // خلفية الحاويات تكون بيضاء لتبرز عن الخلفية الرمادية
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: AppColors.darkBackground,
        onSurface: AppColors
            .primaryIndigo, // النص الرئيسي داخل الحاويات يكون باللون النيلي
      ),

      // تطبيق خط 'Alegreya' على كل النصوص
      textTheme: _buildTextTheme(
        base: ThemeData.light().textTheme,
        primaryColor: AppColors.primaryIndigo,
        secondaryColor: AppColors.accentGold,
        bodyColor: AppColors.darkBackground.withOpacity(0.8),
      ),

      // ضبط الأيقونات للوضع الفاتح
      iconTheme: const IconThemeData(
        color: AppColors.darkIcon,
        size: 26,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          iconColor: MaterialStateProperty.all(AppColors.darkIcon),
        ),
      ),
      appBarTheme: AppBarTheme(
        titleTextStyle: GoogleFonts.alegreya(
          color: AppColors.primaryIndigo,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ));

  // --- الثيم الداكن (Dark Theme) ---
  static final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.primaryIndigo,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryIndigo,
        secondary: AppColors.accentGold,
        background: AppColors.darkBackground,
        surface: Color(0xFF424242), // لون أفتح قليلاً من الخلفية للحاويات
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onBackground: Colors.white,
        onSurface: Colors.white, // النص الرئيسي داخل الحاويات يكون أبيض
      ),

      // تطبيق خط 'Alegreya' على كل النصوص
      textTheme: _buildTextTheme(
        base: ThemeData.dark().textTheme,
        primaryColor: Colors.white, // النص الأساسي أبيض في الوضع الداكن
        secondaryColor: AppColors.accentGold, // لون التمييز يبقى ذهبي
        bodyColor: Colors.white.withOpacity(0.85),
      ),

      // ضبط الأيقونات للوضع الداكن
      iconTheme: const IconThemeData(
        color: AppColors.lightIcon,
        size: 26,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          iconColor: MaterialStateProperty.all(AppColors.lightIcon),
        ),
      ),
      appBarTheme: AppBarTheme(
        titleTextStyle: GoogleFonts.alegreya(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ));

  // دالة مساعدة لبناء الثيم النصي باستخدام خط 'Alegreya'
  static TextTheme _buildTextTheme({
    required TextTheme base,
    required Color primaryColor,
    required Color secondaryColor,
    required Color bodyColor,
  }) {
    return GoogleFonts.alegreyaTextTheme(
      base.copyWith(
        // يستخدم لعناوين الآيات الرئيسية
        headlineMedium: base.headlineMedium?.copyWith(
          color: primaryColor,
          fontSize: 24,
          height: 1.8,
          fontWeight: FontWeight.w600,
        ),
        // يستخدم لعناوين الأقسام (التفسير، الفوائد)
        titleLarge: base.titleLarge?.copyWith(
          color: primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        // يستخدم لنص التفسير والفوائد
        bodyMedium: base.bodyMedium?.copyWith(
          color: bodyColor,
          fontSize: 17,
          height: 1.7,
        ),
        // يستخدم لاسم السورة (يستخدم لون التمييز الذهبي)
        bodySmall: base.bodySmall?.copyWith(
          color: secondaryColor,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
