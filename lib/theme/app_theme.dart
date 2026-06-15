import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF1667C7);
  static const Color primaryDark = Color(0xFF7AB7FF);
  static const Color teal = Color(0xFF0E9F8A);
  static const Color danger = Color(0xFFD64545);

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      secondary: teal,
      onSecondary: Colors.white,
      error: danger,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF102033),
    );
    return _baseTheme(scheme).copyWith(
      scaffoldBackgroundColor: const Color(0xFFF4F8FB),
      cardColor: Colors.white,
      dividerColor: const Color(0xFFD9E4EE),
    );
  }

  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: primaryDark,
      onPrimary: Color(0xFF071421),
      secondary: Color(0xFF5FE1CC),
      onSecondary: Color(0xFF05201C),
      error: Color(0xFFFF8A8A),
      onError: Color(0xFF2A0303),
      surface: Color(0xFF111B26),
      onSurface: Color(0xFFEAF3FA),
    );
    return _baseTheme(scheme).copyWith(
      scaffoldBackgroundColor: const Color(0xFF07111D),
      cardColor: const Color(0xFF111B26),
      dividerColor: const Color(0xFF263849),
    );
  }

  static ThemeData _baseTheme(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final textColor = scheme.onSurface;
    final mutedColor = isDark
        ? const Color(0xFFB1C1D0)
        : const Color(0xFF5C7186);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Roboto',
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: textColor,
          fontSize: 30,
          fontWeight: FontWeight.w800,
          height: 1.15,
        ),
        headlineMedium: TextStyle(
          color: textColor,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          height: 1.25,
        ),
        titleMedium: TextStyle(
          color: textColor,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
        bodyLarge: TextStyle(color: textColor, fontSize: 16, height: 1.45),
        bodyMedium: TextStyle(color: mutedColor, fontSize: 14, height: 1.4),
        labelLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: isDark ? const Color(0xFF0B1622) : Colors.white,
        foregroundColor: textColor,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? const Color(0xFF263849) : const Color(0xFFE0EAF2),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.primary.withValues(alpha: 0.35),
          disabledForegroundColor: scheme.onPrimary.withValues(alpha: 0.75),
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(
            color: isDark ? const Color(0xFF34495E) : const Color(0xFFD3E1ED),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF0B1622) : const Color(0xFFF8FBFD),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: TextStyle(color: mutedColor),
        prefixIconColor: mutedColor,
        suffixIconColor: mutedColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF34495E) : const Color(0xFFD3E1ED),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF34495E) : const Color(0xFFD3E1ED),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.error),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: scheme.primary,
        unselectedItemColor: mutedColor,
        backgroundColor: isDark ? const Color(0xFF0B1622) : Colors.white,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

extension ThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get appSurface => Theme.of(this).colorScheme.surface;
  Color get appText => Theme.of(this).colorScheme.onSurface;
  Color get appMuted =>
      isDark ? const Color(0xFFB1C1D0) : const Color(0xFF5C7186);
  Color get appBorder =>
      isDark ? const Color(0xFF263849) : const Color(0xFFE0EAF2);
}
