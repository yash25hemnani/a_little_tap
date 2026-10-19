import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const primary = Color(0xFFEC6F80);
  static const primaryLight = Color(0xFFF8B4BF);
  static const onPrimary = Color(0xFFFFFFFF);
  static const heart = Color(0xFFF2546B);

  // Tap back accent
  static const lavender = Color(0xFF8E8CE0);
  static const lavenderSoft = Color(0xFFECEBFB);

  // Surfaces
  static const background = Color(0xFFFFF6F2);
  static const backgroundBlush = Color(0xFFFDE8EC);
  static const softPink = Color(0xFFFDEEF1);
  static const surface = Color(0xFFFFFFFF);

  // Text
  static const text = Color(0xFF4A2B33);
  static const textSecondary = Color(0xFF8C7479);
  static const hint = Color(0xFFBFAEB2);

  // Lines
  static const border = Color(0xFFF1E1E4);
  static const divider = Color(0xFFF3E6E8);

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, backgroundBlush],
  );

  static const tapBackGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF6F5FE), lavenderSoft],
  );
}
