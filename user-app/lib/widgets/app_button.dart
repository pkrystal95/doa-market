import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Button size variants
enum AppButtonSize {
  small,
  medium,
  large,
}

/// Button type variants
enum AppButtonType {
  primary,
  secondary,
  outlined,
  text,
}

/// Reusable app button widget with consistent styling
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonSize size;
  final AppButtonType type;
  final bool isLoading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.size = AppButtonSize.medium,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final double height = _getHeight();
    final EdgeInsets padding = _getPadding();
    final TextStyle textStyle = _getTextStyle();

    Widget button;

    switch (type) {
      case AppButtonType.primary:
        button = _buildElevatedButton(height, padding, textStyle);
        break;
      case AppButtonType.secondary:
        button = _buildFilledButton(height, padding, textStyle);
        break;
      case AppButtonType.outlined:
        button = _buildOutlinedButton(height, padding, textStyle);
        break;
      case AppButtonType.text:
        button = _buildTextButton(height, padding, textStyle);
        break;
    }

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return AppSpacing.buttonHeightSM;
      case AppButtonSize.medium:
        return AppSpacing.buttonHeightMD;
      case AppButtonSize.large:
        return AppSpacing.buttonHeightLG;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        );
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        );
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return AppTypography.labelSmall;
      case AppButtonSize.medium:
        return AppTypography.labelMedium;
      case AppButtonSize.large:
        return AppTypography.labelLarge;
    }
  }

  Widget _buildContent(TextStyle textStyle) {
    if (isLoading) {
      return SizedBox(
        height: textStyle.fontSize,
        width: textStyle.fontSize,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: textStyle.fontSize! * 1.2),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: textStyle),
        ],
      );
    }

    return Text(label, style: textStyle);
  }

  Widget _buildElevatedButton(
    double height,
    EdgeInsets padding,
    TextStyle textStyle,
  ) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: padding,
        minimumSize: Size(0, height),
      ),
      child: _buildContent(textStyle),
    );
  }

  Widget _buildFilledButton(
    double height,
    EdgeInsets padding,
    TextStyle textStyle,
  ) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        padding: padding,
        minimumSize: Size(0, height),
      ),
      child: _buildContent(textStyle),
    );
  }

  Widget _buildOutlinedButton(
    double height,
    EdgeInsets padding,
    TextStyle textStyle,
  ) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        padding: padding,
        minimumSize: Size(0, height),
      ),
      child: _buildContent(textStyle),
    );
  }

  Widget _buildTextButton(
    double height,
    EdgeInsets padding,
    TextStyle textStyle,
  ) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        padding: padding,
        minimumSize: Size(0, height),
      ),
      child: _buildContent(textStyle),
    );
  }
}
