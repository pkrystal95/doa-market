import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// App theme configuration with light and dark mode support
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Color scheme
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.primaryDark,

      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryLight,
      onSecondaryContainer: AppColors.secondaryDark,

      tertiary: AppColors.info,
      onTertiary: Colors.white,

      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorLight,
      onErrorContainer: AppColors.errorDark,

      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,

      surfaceContainerHighest: AppColors.backgroundTertiary,

      outline: AppColors.border,
      outlineVariant: AppColors.divider,

      shadow: Colors.black.withValues(alpha: 0.1),
    ),

    // Scaffold
    scaffoldBackgroundColor: AppColors.background,

    // App bar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.titleLarge.copyWith(
        color: AppColors.textPrimary,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: AppSpacing.iconMD,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),

    // Card
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: AppSpacing.elevationSM,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusSM,
      ),
      margin: AppSpacing.paddingSM,
    ),

    // Elevated button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: AppSpacing.elevationSM,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusSM,
        ),
        textStyle: AppTypography.labelLarge,
        minimumSize: const Size(0, AppSpacing.buttonHeightMD),
      ),
    ),

    // Outlined button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusSM,
        ),
        textStyle: AppTypography.labelLarge,
        minimumSize: const Size(0, AppSpacing.buttonHeightMD),
      ),
    ),

    // Text button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        textStyle: AppTypography.labelLarge,
        minimumSize: const Size(0, AppSpacing.buttonHeightSM),
      ),
    ),

    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.background,
      contentPadding: AppSpacing.paddingMD,
      border: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusSM,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusSM,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusSM,
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusSM,
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusSM,
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textTertiary,
      ),
      errorStyle: AppTypography.bodySmall.copyWith(
        color: AppColors.error,
      ),
    ),

    // Bottom navigation bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: AppSpacing.elevationMD,
      selectedLabelStyle: AppTypography.labelSmall,
      unselectedLabelStyle: AppTypography.labelSmall,
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.backgroundTertiary,
      selectedColor: AppColors.primary,
      disabledColor: AppColors.backgroundSecondary,
      labelStyle: AppTypography.labelMedium,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusFull,
      ),
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      elevation: AppSpacing.elevationLG,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMD,
      ),
      titleTextStyle: AppTypography.titleLarge.copyWith(
        color: AppColors.textPrimary,
      ),
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: Colors.white,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusSM,
      ),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),

    // Typography
    textTheme: AppTypography.getTextTheme(isDark: false),

    // Icon
    iconTheme: const IconThemeData(
      color: AppColors.textPrimary,
      size: AppSpacing.iconMD,
    ),
  );

  /// Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Color scheme
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryLight,
      onPrimary: AppColors.textPrimaryDark,
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: AppColors.primaryLight,

      secondary: AppColors.secondaryLight,
      onSecondary: AppColors.textPrimaryDark,
      secondaryContainer: AppColors.secondaryDark,
      onSecondaryContainer: AppColors.secondaryLight,

      tertiary: AppColors.infoLight,
      onTertiary: AppColors.textPrimaryDark,

      error: AppColors.errorLight,
      onError: AppColors.textPrimaryDark,
      errorContainer: AppColors.errorDark,
      onErrorContainer: AppColors.errorLight,

      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,

      surfaceContainerHighest: AppColors.backgroundTertiaryDark,

      outline: AppColors.borderDark,
      outlineVariant: AppColors.dividerDark,

      shadow: Colors.black.withValues(alpha: 0.3),
    ),

    // Scaffold
    scaffoldBackgroundColor: AppColors.backgroundDark,

    // App bar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.textPrimaryDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.titleLarge.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimaryDark,
        size: AppSpacing.iconMD,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),

    // Card
    cardTheme: CardThemeData(
      color: AppColors.surfaceDark,
      elevation: AppSpacing.elevationSM,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusSM,
      ),
      margin: AppSpacing.paddingSM,
    ),

    // Elevated button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: AppSpacing.elevationSM,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusSM,
        ),
        textStyle: AppTypography.labelLarge,
        minimumSize: const Size(0, AppSpacing.buttonHeightMD),
      ),
    ),

    // Outlined button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        side: const BorderSide(color: AppColors.primaryLight),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusSM,
        ),
        textStyle: AppTypography.labelLarge,
        minimumSize: const Size(0, AppSpacing.buttonHeightMD),
      ),
    ),

    // Text button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        textStyle: AppTypography.labelLarge,
        minimumSize: const Size(0, AppSpacing.buttonHeightSM),
      ),
    ),

    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.backgroundSecondaryDark,
      contentPadding: AppSpacing.paddingMD,
      border: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusSM,
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusSM,
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusSM,
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusSM,
        borderSide: const BorderSide(color: AppColors.errorLight),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusSM,
        borderSide: const BorderSide(color: AppColors.errorLight, width: 2),
      ),
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondaryDark,
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textTertiaryDark,
      ),
      errorStyle: AppTypography.bodySmall.copyWith(
        color: AppColors.errorLight,
      ),
    ),

    // Bottom navigation bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.textSecondaryDark,
      type: BottomNavigationBarType.fixed,
      elevation: AppSpacing.elevationMD,
      selectedLabelStyle: AppTypography.labelSmall,
      unselectedLabelStyle: AppTypography.labelSmall,
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.backgroundTertiaryDark,
      selectedColor: AppColors.primaryLight,
      disabledColor: AppColors.backgroundSecondaryDark,
      labelStyle: AppTypography.labelMedium.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusFull,
      ),
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceDark,
      elevation: AppSpacing.elevationLG,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMD,
      ),
      titleTextStyle: AppTypography.titleLarge.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondaryDark,
      ),
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.backgroundTertiaryDark,
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusSM,
      ),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerDark,
      thickness: 1,
      space: 1,
    ),

    // Typography
    textTheme: AppTypography.getTextTheme(isDark: true),

    // Icon
    iconTheme: const IconThemeData(
      color: AppColors.textPrimaryDark,
      size: AppSpacing.iconMD,
    ),
  );
}
