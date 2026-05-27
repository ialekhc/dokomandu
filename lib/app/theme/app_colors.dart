import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Brand
  static const Color brandPrimary = Color(0xFF193CB8);
  static const Color brandPrimaryDark = Color(0xFF6F86FF);
  static const Color brandSecondary = Color(0xFFFFB703);
  static const Color brandTertiary = Color(0xFF4CAF50);

  // Semantic
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF0288D1);

  // Light palette
  static const Color lightPrimary = brandPrimary;
  static const Color lightOnPrimary = Colors.white;
  static const Color lightPrimaryContainer = Color(0xFFDCE4FF);
  static const Color lightBackground = Color(0xFFFFF8F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5);
  static const Color lightOnSurface = Color(0xFF1C1B1F);
  static const Color lightOutline = Color(0xFFD0D0D0);

  // Dark palette
  static const Color darkPrimary = brandPrimaryDark;
  static const Color darkOnPrimary = Color(0xFF0C1745);
  static const Color darkPrimaryContainer = Color(0xFF142A7C);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2A2A2A);
  static const Color darkOnSurface = Color(0xFFF5F5F5);
  static const Color darkOutline = Color(0xFF5C5C5C);
}
