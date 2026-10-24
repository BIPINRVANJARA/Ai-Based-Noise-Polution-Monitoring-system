import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextStyle displayLarge([Color? color]) => GoogleFonts.inter(
      fontSize: 48, fontWeight: FontWeight.w700, color: color);
  
  static TextStyle displayMedium([Color? color]) => GoogleFonts.inter(
      fontSize: 36, fontWeight: FontWeight.w600, color: color);
  
  static TextStyle headlineLarge([Color? color]) => GoogleFonts.inter(
      fontSize: 28, fontWeight: FontWeight.w600, color: color);
  
  static TextStyle headlineMedium([Color? color]) => GoogleFonts.inter(
      fontSize: 22, fontWeight: FontWeight.w600, color: color);
  
  static TextStyle titleLarge([Color? color]) => GoogleFonts.inter(
      fontSize: 20, fontWeight: FontWeight.w600, color: color);
  
  static TextStyle titleMedium([Color? color]) => GoogleFonts.inter(
      fontSize: 16, fontWeight: FontWeight.w600, color: color);
  
  static TextStyle bodyLarge([Color? color]) => GoogleFonts.inter(
      fontSize: 16, fontWeight: FontWeight.w400, color: color);
  
  static TextStyle bodyMedium([Color? color]) => GoogleFonts.inter(
      fontSize: 14, fontWeight: FontWeight.w400, color: color);
  
  static TextStyle bodySmall([Color? color]) => GoogleFonts.inter(
      fontSize: 12, fontWeight: FontWeight.w400, color: color);
  
  static TextStyle labelLarge([Color? color]) => GoogleFonts.jetBrainsMono(
      fontSize: 14, fontWeight: FontWeight.w600, color: color);
  
  static TextStyle labelMedium([Color? color]) => GoogleFonts.jetBrainsMono(
      fontSize: 12, fontWeight: FontWeight.w600, color: color);
  
  static TextStyle labelSmall([Color? color]) => GoogleFonts.jetBrainsMono(
      fontSize: 10, fontWeight: FontWeight.w600, color: color);
}
