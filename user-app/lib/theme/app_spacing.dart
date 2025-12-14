import 'package:flutter/material.dart';

/// App spacing system based on 4px baseline grid
class AppSpacing {
  // Private constructor to prevent instantiation
  AppSpacing._();

  // Base unit (4px)
  static const double base = 4.0;

  // Spacing scale
  static const double none = 0.0;
  static const double xxs = base; // 4px
  static const double xs = base * 2; // 8px
  static const double sm = base * 3; // 12px
  static const double md = base * 4; // 16px
  static const double lg = base * 5; // 20px
  static const double xl = base * 6; // 24px
  static const double xxl = base * 8; // 32px
  static const double xxxl = base * 10; // 40px

  // Common padding values
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);

  // Horizontal padding
  static const EdgeInsets paddingHorizontalXS = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(horizontal: xl);

  // Vertical padding
  static const EdgeInsets paddingVerticalXS = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVerticalXL = EdgeInsets.symmetric(vertical: xl);

  // Border radius
  static const double radiusXS = xxs; // 4px
  static const double radiusSM = xs; // 8px
  static const double radiusMD = sm; // 12px
  static const double radiusLG = md; // 16px
  static const double radiusXL = lg; // 20px
  static const double radiusFull = 9999.0; // Circle/pill

  // Border radius objects
  static const BorderRadius borderRadiusXS = BorderRadius.all(Radius.circular(radiusXS));
  static const BorderRadius borderRadiusSM = BorderRadius.all(Radius.circular(radiusSM));
  static const BorderRadius borderRadiusMD = BorderRadius.all(Radius.circular(radiusMD));
  static const BorderRadius borderRadiusLG = BorderRadius.all(Radius.circular(radiusLG));
  static const BorderRadius borderRadiusXL = BorderRadius.all(Radius.circular(radiusXL));
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(radiusFull));

  // Icon sizes
  static const double iconXS = md; // 16px
  static const double iconSM = lg; // 20px
  static const double iconMD = xl; // 24px
  static const double iconLG = xxl; // 32px
  static const double iconXL = base * 12; // 48px
  static const double iconXXL = base * 16; // 64px

  // Button heights
  static const double buttonHeightSM = base * 8; // 32px
  static const double buttonHeightMD = base * 11; // 44px
  static const double buttonHeightLG = base * 14; // 56px

  // Input field heights
  static const double inputHeightSM = base * 8; // 32px
  static const double inputHeightMD = base * 11; // 44px
  static const double inputHeightLG = base * 14; // 56px

  // AppBar height
  static const double appBarHeight = base * 14; // 56px

  // Bottom navigation height
  static const double bottomNavHeight = base * 16; // 64px

  // Card elevation
  static const double elevationSM = 2.0;
  static const double elevationMD = 4.0;
  static const double elevationLG = 8.0;
  static const double elevationXL = 16.0;

  // Minimum touch target size (accessibility)
  static const double minTouchTarget = base * 12; // 48px
}
