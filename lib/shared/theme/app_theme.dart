import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Palette ──────────────────────────────────────────────
  static const Color bg = Color(0xFF09090B);         // zinc-950
  static const Color bgCard = Color(0xFF18181B);     // zinc-900
  static const Color border = Color(0xFF27272A);     // zinc-800
  static const Color borderLight = Color(0xFF3F3F46); // zinc-700

  static const Color white = Color(0xFFFFFFFF);
  static const Color fgMuted = Color(0xFF71717A);    // zinc-500
  static const Color fgSubtle = Color(0xFFA1A1AA);  // zinc-400

  // Status colors
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberBg = Color(0xFF451A03);
  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldBg = Color(0xFF022C22);
  static const Color red = Color(0xFFEF4444);
  static const Color redBg = Color(0xFF450A0A);
  static const Color zinc = Color(0xFF71717A);

  // Gradient stops
  static const Color gradAmber = Color(0xFFFBBF24);
  static const Color gradRose = Color(0xFFFB7185);
  static const Color gradFuchsia = Color(0xFFE879F9);

  // ── Gradient ────────────────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    colors: [gradAmber, gradRose, gradFuchsia],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ── ThemeData ───────────────────────────────────────────
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: white,
        surface: bgCard,
        onSurface: white,
        outline: border,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: white,
        displayColor: white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          color: white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(color: white),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCard,
        hintStyle: GoogleFonts.inter(color: fgMuted, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: fgMuted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: white,
          foregroundColor: bg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: fgSubtle,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgCard,
        selectedItemColor: white,
        unselectedItemColor: fgMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerColor: border,
      dividerTheme: const DividerThemeData(color: border, space: 1, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: bgCard,
        contentTextStyle: GoogleFonts.inter(color: white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}
