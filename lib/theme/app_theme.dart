import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BrandColors {
  // Primary SynFin brand color (deep red/maroon)
  static const primary = Color(0xFFB10042);
  static const onPrimary = Colors.white;

  // Complementary accents
  static const secondary = Color(0xFF7A002D);
  static const tertiary = Color(0xFFD94E76);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: BrandColors.primary,
        primary: BrandColors.primary,
        secondary: BrandColors.tertiary,
        brightness: Brightness.light,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: base.colorScheme.surface,
        foregroundColor: base.colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: base.colorScheme.onSurface,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: base.colorScheme.primary,
          foregroundColor: BrandColors.onPrimary,
          shape: const StadiumBorder(), // pill-shaped
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: base.colorScheme.primary,
          foregroundColor: BrandColors.onPrimary,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: base.colorScheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: base.colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: base.colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: base.colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        color: WidgetStatePropertyAll(
          base.colorScheme.primary.withValues(alpha: 0.08),
        ),
        side: BorderSide(
          color: base.colorScheme.primary.withValues(alpha: 0.2),
        ),
        labelStyle: TextStyle(color: base.colorScheme.primary),
        shape: const StadiumBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: base.colorScheme.surface,
        indicatorColor: base.colorScheme.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        // shape handled below via cardTheme shape in newer SDKs; fallback left minimal
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        iconColor: base.colorScheme.primary,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: base.colorScheme.primary,
        foregroundColor: BrandColors.onPrimary,
      ),
      // Some SDKs use DialogThemeData; fallback to default if not available
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: BrandColors.primary,
        primary: BrandColors.tertiary,
        secondary: BrandColors.primary,
        brightness: Brightness.dark,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: base.colorScheme.surface,
        foregroundColor: base.colorScheme.onSurface,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: base.colorScheme.primary,
          foregroundColor: BrandColors.onPrimary,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: base.colorScheme.primary,
          foregroundColor: BrandColors.onPrimary,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: base.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.3,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: base.colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: base.colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: base.colorScheme.primary, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: base.colorScheme.surface,
        indicatorColor: base.colorScheme.primary.withValues(alpha: 0.2),
        labelTextStyle: MaterialStateProperty.all(
          GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: base.cardTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
