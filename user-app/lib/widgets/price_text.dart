import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_typography.dart';

/// Size variants for price text
enum PriceTextSize {
  small,
  medium,
  large,
}

/// Reusable price text widget with formatted currency
class PriceText extends StatelessWidget {
  final double price;
  final PriceTextSize size;
  final Color? color;
  final FontWeight? fontWeight;
  final bool showCurrency;

  const PriceText({
    super.key,
    required this.price,
    this.size = PriceTextSize.medium,
    this.color,
    this.fontWeight,
    this.showCurrency = true,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final formattedPrice = formatter.format(price);

    TextStyle textStyle;
    switch (size) {
      case PriceTextSize.small:
        textStyle = AppTypography.priceSmall;
        break;
      case PriceTextSize.medium:
        textStyle = AppTypography.priceMedium;
        break;
      case PriceTextSize.large:
        textStyle = AppTypography.priceLarge;
        break;
    }

    if (color != null) {
      textStyle = textStyle.copyWith(color: color);
    }

    if (fontWeight != null) {
      textStyle = textStyle.copyWith(fontWeight: fontWeight);
    }

    return Text(
      showCurrency ? '$formattedPrice원' : formattedPrice,
      style: textStyle,
    );
  }
}
