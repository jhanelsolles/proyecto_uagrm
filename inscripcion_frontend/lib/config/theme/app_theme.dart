import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UAGRMTheme {
  // Paleta de colores oficial
  static const Color primaryBlue = Color(0xFF003366);
  static const Color primaryRed = Color(0xFFCC0000); // Rojo clásico bandera
  static const Color secondaryBlue = Color(0xFF0099CC);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF2D2D2D);
  static const Color textGrey = Color(0xFF757575);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color successGreen = Color(0xFF388E3C);
  static const Color warningOrange = Color(0xFFFF9800);

  static final ThemeData themeData = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryBlue,
      surface: backgroundWhite,
      onPrimary: Colors.white,
      onSurface: textDark,
      error: errorRed,
    ),
    scaffoldBackgroundColor: backgroundWhite,
    textTheme: TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        color: textDark,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        color: textGrey,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    // Estilo de botones
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Estilo de Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorRed, width: 1),
      ),
      labelStyle: TextStyle(color: textGrey),
      hintStyle: TextStyle(color: textGrey.withValues(alpha: 0.7)),
    ),

    // Estilo de Cards
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.zero,
    ),

    // AppBar personalizada
    appBarTheme: AppBarTheme(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),

    // Snacks
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textDark,
      contentTextStyle: GoogleFonts.roboto(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );

  static const Color darkBackground = Color(0xFF030B17); // Más profundo
  static const Color darkSurface = Color(0xFF0A192F);    // Superficie navy
  static const Color darkCard = Color(0xFF112240);       // Tarjetas navy
  static const Color darkText = Color(0xFFF1F5F9);       // Texto claro puro
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Texto secundario gris azulado
  static const Color accentCyan = Color(0xFF00FFF2);     // Cian vibrante para acentos
  static const Color accentBlue = Color(0xFF38BDF8);     // Azul eléctrico

  static final ThemeData darkThemeData = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      surface: darkSurface,
      onPrimary: Colors.white,
      onSurface: darkText,
      error: errorRed,
    ),
    scaffoldBackgroundColor: darkBackground,

    textTheme: TextTheme(
      displayLarge: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: darkText),
      displayMedium: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: darkText),
      titleLarge: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: darkText),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: darkTextSecondary),
      labelLarge: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorRed, width: 1),
      ),
      labelStyle: const TextStyle(color: darkTextSecondary),
      hintStyle: TextStyle(color: darkTextSecondary.withValues(alpha: 0.7)),
    ),

    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1),
      ),
      margin: EdgeInsets.zero,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF020C1B),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      iconTheme: const IconThemeData(color: Colors.white),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkCard,
      contentTextStyle: GoogleFonts.roboto(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
