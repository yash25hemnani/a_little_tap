import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondaryContainer: AppColors.softPink,
      surface: AppColors.background,
      onSurface: AppColors.text,
      onSurfaceVariant: AppColors.hint,
      outline: AppColors.border,
    );

    // Set weights on Material's plain styles first, THEN hand them to
    // google_fonts. It loads each weight as its own family (e.g. "Poppins_600"),
    // so changing fontWeight on an already-Poppins style keeps the old file.
    final base = ThemeData.light().textTheme;

    // Copy a style with a new weight (null-safe, since TextTheme styles are nullable).
    TextStyle? w(TextStyle? style, FontWeight weight) =>
        style?.copyWith(fontWeight: weight);

    final weighted = base.copyWith(
      // Big headings
      displayLarge: w(base.displayLarge, FontWeight.w600),
      displayMedium: w(base.displayMedium, FontWeight.w600),
      displaySmall: w(base.displaySmall, FontWeight.w600),
      headlineLarge: w(base.headlineLarge, FontWeight.w600),
      headlineMedium: w(base.headlineMedium, FontWeight.w600),
      headlineSmall: w(base.headlineSmall, FontWeight.w600),
      // Titles, list items, buttons
      titleLarge: w(base.titleLarge, FontWeight.w600),
      titleMedium: w(base.titleMedium, FontWeight.w600),
      titleSmall: w(base.titleSmall, FontWeight.w600),
      labelLarge: w(base.labelLarge, FontWeight.w600),
      labelMedium: w(base.labelMedium, FontWeight.w600),
      labelSmall: w(base.labelSmall, FontWeight.w600),
      // Regular text (also what you type into fields)
      bodyLarge: w(base.bodyLarge, FontWeight.w500),
      bodyMedium: w(base.bodyMedium, FontWeight.w500),
      bodySmall: w(base.bodySmall, FontWeight.w500),
    );

    final textTheme = GoogleFonts.poppinsTextTheme(
      weighted,
    ).apply(bodyColor: AppColors.text, displayColor: AppColors.text);

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface, // white
        surfaceTintColor: Colors.transparent, // stops M3 tinting it pink
        // no pill behind the active icon; the filled icon + colour shows it
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppColors.heart
                : AppColors.textSecondary,
          ),
        ),
        labelPadding: EdgeInsets.zero, // default is 4px above the label
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 22, // default is 24
            color: states.contains(WidgetState.selected)
                ? AppColors.heart
                : AppColors.textSecondary,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.hint),
        prefixIconColor: AppColors.hint,
        suffixIconColor: AppColors.hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: border(AppColors.border),
        enabledBorder: border(AppColors.border),
        focusedBorder: border(AppColors.primary, 1.5),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size.fromHeight(56), // full width, 56 tall
          shape: const StadiumBorder(), // pill
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
