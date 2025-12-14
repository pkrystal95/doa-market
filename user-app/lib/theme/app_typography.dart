import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App typography system with predefined text styles
class AppTypography {
  // Private constructor to prevent instantiation
  AppTypography._();

  // Font family
  static const String fontFamily = 'Pretendard';
  static const String fontFamilyFallback = 'SF Pro Display';

  // Display styles (largest)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w700,
    height: 1.12,
    letterSpacing: -0.25,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w700,
    height: 1.16,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.22,
  );

  // Headline styles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.29,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  // Title styles
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.27,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
  );

  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.4,
  );

  // Label styles (for buttons, chips, etc.)
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.45,
    letterSpacing: 0.5,
  );

  // Price styles (special use case)
  static const TextStyle priceLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.33,
    color: AppColors.price,
  );

  static const TextStyle priceMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.44,
    color: AppColors.price,
  );

  static const TextStyle priceSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    color: AppColors.price,
  );

  // Helper methods to get text theme
  static TextTheme getTextTheme({bool isDark = false}) {
    final Color primaryColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return TextTheme(
      displayLarge: displayLarge.copyWith(color: primaryColor),
      displayMedium: displayMedium.copyWith(color: primaryColor),
      displaySmall: displaySmall.copyWith(color: primaryColor),
      headlineLarge: headlineLarge.copyWith(color: primaryColor),
      headlineMedium: headlineMedium.copyWith(color: primaryColor),
      headlineSmall: headlineSmall.copyWith(color: primaryColor),
      titleLarge: titleLarge.copyWith(color: primaryColor),
      titleMedium: titleMedium.copyWith(color: primaryColor),
      titleSmall: titleSmall.copyWith(color: primaryColor),
      bodyLarge: bodyLarge.copyWith(color: primaryColor),
      bodyMedium: bodyMedium.copyWith(color: primaryColor),
      bodySmall: bodySmall.copyWith(color: primaryColor),
      labelLarge: labelLarge.copyWith(color: primaryColor),
      labelMedium: labelMedium.copyWith(color: primaryColor),
      labelSmall: labelSmall.copyWith(color: primaryColor),
    );
  }
}
