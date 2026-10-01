import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ==========================================================
  // COLOURS
  // ==========================================================

  // Muted deep red
  static const Color primary = Color(0xFF9A4A47);

  // Darker red
  static const Color primaryDark = Color(0xFF743533);

  // Muted brick red
  static const Color accent = Color(0xFFB66A62);

  // Dark warm background
  static const Color background = Color.fromARGB(255, 31, 24, 23);

  // Slightly lighter surface
  static const Color surface = Color(0xFF282120);

  // Elevated surface
  static const Color surfaceLight = Color(0xFF332A28);

  // Main text
  static const Color text = Color(0xFFF3ECE7);

  // Secondary text
  static const Color secondaryText = Color(0xFFB9ADA7);

  // Borders
  static const Color border = Color(0xFF493D39);

  // Error
  static const Color error = Color(0xFFD96A62);

  // ==========================================================
  // THEME
  // ==========================================================

  static ThemeData theme = ThemeData(
    useMaterial3: true,

    // ========================================================
    // TEXT
    // ========================================================

    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme,
    ).apply(
      bodyColor: text,
      displayColor: text,
    ),

    // ========================================================
    // COLOUR SCHEME
    // ========================================================

    colorScheme: const ColorScheme(
      brightness: Brightness.dark,

      primary: primary,
      onPrimary: Colors.white,

      secondary: accent,
      onSecondary: Colors.white,

      tertiary: Color(0xFFA58A70),
      onTertiary: Colors.white,

      error: error,
      onError: Colors.white,

      surface: surface,
      onSurface: text,

      surfaceContainerHighest: surfaceLight,
      onSurfaceVariant: secondaryText,

      outline: border,
      outlineVariant: Color(0xFF3B322F),

      shadow: Colors.black54,
      scrim: Colors.black87,
    ),

    scaffoldBackgroundColor: background,

    // ==========================================================
    // APP BAR
    // ==========================================================

    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,

      backgroundColor: background,
      foregroundColor: text,

      titleTextStyle: GoogleFonts.poppins(
        fontSize: 21,
        fontWeight: FontWeight.w600,
        color: text,
      ),

      iconTheme: const IconThemeData(
        color: text,
      ),
    ),

    // ==========================================================
    // DIALOGS
    // ==========================================================

    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: text,
      ),

      contentTextStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: secondaryText,
        height: 1.5,
      ),
    ),

    // ==========================================================
    // INPUT FIELDS
    // ==========================================================

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: primary,
          width: 2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: error,
          width: 1,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: error,
          width: 2,
        ),
      ),

      hintStyle: GoogleFonts.poppins(
        color: Color(0xFF817570),
        fontSize: 14,
      ),

      labelStyle: GoogleFonts.poppins(
        color: secondaryText,
        fontSize: 14,
      ),

      floatingLabelStyle: GoogleFonts.poppins(
        color: accent,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),

      errorStyle: GoogleFonts.poppins(
        color: error,
        fontSize: 12,
      ),

      prefixIconColor: secondaryText,
      suffixIconColor: secondaryText,
    ),

    // ==========================================================
    // POPUP MENUS
    // ==========================================================

    popupMenuTheme: PopupMenuThemeData(
      color: surface,
      surfaceTintColor: Colors.transparent,

      elevation: 8,

      textStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: text,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // ==========================================================
    // ELEVATED BUTTON
    // ==========================================================

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),

        backgroundColor: primary,
        foregroundColor: Colors.white,

        elevation: 0,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),

        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ==========================================================
    // FILLED BUTTON
    // ==========================================================

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),

        backgroundColor: primary,
        foregroundColor: Colors.white,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),

        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ==========================================================
    // OUTLINED BUTTON
    // ==========================================================

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),

        foregroundColor: accent,

        side: const BorderSide(
          color: primary,
          width: 1.2,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),

        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ==========================================================
    // TEXT BUTTON
    // ==========================================================

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accent,

        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ==========================================================
    // CARDS
    // ==========================================================

    cardTheme: CardThemeData(
      elevation: 2,

      color: surface,

      margin: EdgeInsets.zero,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),

    // ==========================================================
    // NAVIGATION BAR
    // ==========================================================

    navigationBarTheme: NavigationBarThemeData(
      height: 65,

      backgroundColor: surface,

      elevation: 4,

      indicatorColor: Colors.transparent,

      labelBehavior:
          NavigationDestinationLabelBehavior.alwaysHide,

      iconTheme: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: primary,
              size: 25,
            );
          }

          return const IconThemeData(
            color: secondaryText,
            size: 24,
          );
        },
      ),
    ),

    // ==========================================================
    // DIVIDER
    // ==========================================================

    dividerTheme: const DividerThemeData(
      color: border,
      thickness: 1,
      space: 1,
    ),

    // ==========================================================
    // SNACKBAR
    // ==========================================================

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,

      backgroundColor: surfaceLight,

      contentTextStyle: GoogleFonts.poppins(
        fontSize: 13,
        color: text,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}
