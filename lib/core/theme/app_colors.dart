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

  // Feelings
  static const sunny = Color(0xFFF5A623);
  static const sunnySoft = Color(0xFFFFF1D6);

  // Feeling base colors (with heart, lavender, sunny above)
  static const rose = Color(0xFFE8608A);
  static const berry = Color(0xFFD14D72);
  static const coral = Color(0xFFF27063);
  static const peach = Color(0xFFF28C6B);
  static const tangerine = Color(0xFFF2873A);
  static const honey = Color(0xFFE8B23A);
  static const lime = Color(0xFF9BC447);
  static const sage = Color(0xFF7FA87A);
  static const mint = Color(0xFF5CC9A7);
  static const teal = Color(0xFF3FB5B0);
  static const sky = Color(0xFF5AA9E6);
  static const ocean = Color(0xFF3D8FD1);
  static const periwinkle = Color(0xFF7A8CE8);
  static const violet = Color(0xFFA06CD5);
  static const plum = Color(0xFFB5589E);
  static const mocha = Color(0xFFA5785F);
  static const slate = Color(0xFF7D8A9C);

  // Surfaces
  static const background = Color(0xFFFFF6F2);
  static const backgroundBlush = Color(0xFFFDE8EC);
  static const softPink = Color(0xFFFDEEF1);
  static const surface = Color(0xFFFFFFFF);
  static const offWhite = Color(0xFFFFFAF8);
  static const track = Color(0xFFF2EDED); // grey behind the tab pill


  // Text
  static const text = Color(0xFF4A2B33);
  static const textSecondary = Color(0xFF8C7479);
  static const hint = Color(0xFFBFAEB2);

  // Lines
  static const border = Color(0xFFF1E1E4);
  static const divider = Color(0xFFF3E6E8);

  // Status
  static const online = Color(0xFF5BC98A);

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

  static const sunnyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFBF2), sunnySoft],
  );
}
