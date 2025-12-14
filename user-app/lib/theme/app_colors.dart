import 'package:flutter/material.dart';

/// App color palette with light and dark mode support
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFF1D4ED8); // Blue-700
  static const Color primaryDark = Color(0xFF1E40AF); // Blue-800
  static const Color primaryLight = Color(0xFF3B82F6); // Blue-600

  // Secondary colors
  static const Color secondary = Color(0xFF6366F1); // Indigo-500
  static const Color secondaryDark = Color(0xFF4F46E5); // Indigo-600
  static const Color secondaryLight = Color(0xFF818CF8); // Indigo-400

  // Semantic colors - Success
  static const Color success = Color(0xFF10B981); // Green-500
  static const Color successDark = Color(0xFF059669); // Green-600
  static const Color successLight = Color(0xFF34D399); // Green-400

  // Semantic colors - Warning
  static const Color warning = Color(0xFFF59E0B); // Amber-500
  static const Color warningDark = Color(0xFFD97706); // Amber-600
  static const Color warningLight = Color(0xFFFBBF24); // Amber-400

  // Semantic colors - Error
  static const Color error = Color(0xFFEF4444); // Red-500
  static const Color errorDark = Color(0xFFDC2626); // Red-600
  static const Color errorLight = Color(0xFFF87171); // Red-400

  // Semantic colors - Info
  static const Color info = Color(0xFF3B82F6); // Blue-500
  static const Color infoDark = Color(0xFF2563EB); // Blue-600
  static const Color infoLight = Color(0xFF60A5FA); // Blue-400

  // Neutral colors - Light mode
  static const Color textPrimary = Color(0xFF111827); // Gray-900
  static const Color textSecondary = Color(0xFF6B7280); // Gray-500
  static const Color textTertiary = Color(0xFF9CA3AF); // Gray-400
  static const Color textDisabled = Color(0xFFD1D5DB); // Gray-300

  // Neutral colors - Dark mode
  static const Color textPrimaryDark = Color(0xFFF9FAFB); // Gray-50
  static const Color textSecondaryDark = Color(0xFFD1D5DB); // Gray-300
  static const Color textTertiaryDark = Color(0xFF9CA3AF); // Gray-400
  static const Color textDisabledDark = Color(0xFF6B7280); // Gray-500

  // Background colors - Light mode
  static const Color background = Color(0xFFFFFFFF); // White
  static const Color backgroundSecondary = Color(0xFFF9FAFB); // Gray-50
  static const Color backgroundTertiary = Color(0xFFF3F4F6); // Gray-100

  // Background colors - Dark mode
  static const Color backgroundDark = Color(0xFF111827); // Gray-900
  static const Color backgroundSecondaryDark = Color(0xFF1F2937); // Gray-800
  static const Color backgroundTertiaryDark = Color(0xFF374151); // Gray-700

  // Surface colors
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceLight = Color(0xFFF9FAFB); // Gray-50
  static const Color surfaceDark = Color(0xFF1F2937); // Gray-800

  // Border colors
  static const Color border = Color(0xFFE5E7EB); // Gray-200
  static const Color borderDark = Color(0xFF374151); // Gray-700
  static const Color divider = Color(0xFFE5E7EB); // Gray-200
  static const Color dividerDark = Color(0xFF4B5563); // Gray-600

  // Order status colors
  static const Color statusPending = Color(0xFFF59E0B); // Orange
  static const Color statusConfirmed = Color(0xFF3B82F6); // Blue
  static const Color statusProcessing = Color(0xFF8B5CF6); // Purple
  static const Color statusShipped = Color(0xFF14B8A6); // Teal
  static const Color statusDelivered = Color(0xFF10B981); // Green
  static const Color statusCancelled = Color(0xFFEF4444); // Red

  // Special colors
  static const Color badge = Color(0xFFEF4444); // Red
  static const Color discount = Color(0xFFEF4444); // Red
  static const Color price = Color(0xFF1D4ED8); // Blue
  static const Color outOfStock = Color(0xFFEF4444); // Red
  static const Color inStock = Color(0xFF10B981); // Green

  // Overlay colors
  static const Color overlay = Color(0x80000000); // 50% black
  static const Color overlayLight = Color(0x40000000); // 25% black
  static const Color overlayDark = Color(0xB3000000); // 70% black

  // Shimmer colors for skeleton loading
  static const Color shimmerBase = Color(0xFFE5E7EB); // Gray-200
  static const Color shimmerHighlight = Color(0xFFF3F4F6); // Gray-100
  static const Color shimmerBaseDark = Color(0xFF374151); // Gray-700
  static const Color shimmerHighlightDark = Color(0xFF4B5563); // Gray-600
}
