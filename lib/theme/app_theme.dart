import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🎨 Primary colors
  static const Color primaryGreen = Color(0xFF7B61FF); // بنفش گرادیانی پرانرژی
  static const Color primaryDark = Color(0xFFF9FAFF); // پس‌زمینه روشن‌تر و شیک
  static const Color primaryDarker = Color(
    0xFFE6E8FF,
  ); // بنفش خیلی کم برای بک‌گراند
  static const Color secondaryDark = Color(0xFFD4D6FF); // خاکستری-بنفش ملایم
  static const Color cardDark = Color(0xFFFFFFFF); // کارت‌ها سفید تمیز

  // 🌈 Accent colors
  static const Color accentGreen = Color(0xFF00D8B6); // فیروزه‌ای نئونی مدرن
  static const Color disconnectedRed = Color(0xFFFF5C7A); // صورتی-قرمز جذاب
  static const Color connectingYellow = Color(0xFFFFD166); // زرد طلایی نرم

  // 📝 Text colors
  static const Color textLight = Color(0xFF1A1A2E); // متن اصلی پررنگ
  static const Color textGrey = Color(
    0xFF444B59,
  ); // خاکستری مدرن (خواناتر از قبل)

  // 🔥 Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7B61FF), Color(0xFF00D8B6)], // بنفش → فیروزه‌ای
  );
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF9FAFF), Color(0xFFE6E8FF)], // سفید → بنفش خیلی روشن
  );

  // 🌙 Theme data
  static ThemeData darkTheme() {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: primaryDark,
      primaryColor: primaryGreen,
      colorScheme: const ColorScheme.light().copyWith(
        primary: primaryGreen,
        secondary: accentGreen,
        background: primaryDark,
        surface: cardDark,
        error: disconnectedRed,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cardDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
        iconTheme: const IconThemeData(color: textLight),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.light().textTheme,
      ).apply(bodyColor: textLight, displayColor: textLight),
      dividerTheme: const DividerThemeData(color: secondaryDark, thickness: 1),
    );
  }
}
