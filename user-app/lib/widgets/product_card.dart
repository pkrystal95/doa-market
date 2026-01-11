import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import 'price_text.dart';
import '../utils/format_utils.dart';

/// Reusable product card widget for displaying products in grid/list
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onToggleWishlist;
  final bool isInWishlist;
  final bool showActions;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.onToggleWishlist,
    this.isInWishlist = false,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOutOfStock = (product.stock ?? 0) <= 0;

    return InkWell(
      onTap: isOutOfStock ? null : onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image (정사각형)
          AspectRatio(
            aspectRatio: 1.0,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildProductImage(isDark, isOutOfStock),
                if (showActions && onToggleWishlist != null)
                  _buildWishlistButton(),
                if (isOutOfStock) _buildOutOfStockOverlay(),
              ],
            ),
          ),

          // Product info
          Padding(
            padding: const EdgeInsets.all(7.0),
            child: _buildProductInfo(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(bool isDark, bool isOutOfStock) {
    return Image.network(
      product.imageUrl ?? '',
      fit: BoxFit.cover,
      color: isOutOfStock ? Colors.grey : null,
      colorBlendMode: isOutOfStock ? BlendMode.saturation : null,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: isDark
              ? AppColors.backgroundSecondaryDark
              : AppColors.backgroundSecondary,
          child: Icon(
            Icons.image_not_supported,
            size: AppSpacing.iconXL,
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiary,
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: isDark
              ? AppColors.backgroundSecondaryDark
              : AppColors.backgroundSecondary,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildWishlistButton() {
    return Positioned(
      bottom: AppSpacing.xs,
      right: AppSpacing.xs,
      child: Material(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: AppSpacing.borderRadiusFull,
        elevation: 2,
        child: InkWell(
          onTap: onToggleWishlist,
          borderRadius: AppSpacing.borderRadiusFull,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isInWishlist ? AppColors.error : Colors.grey[600],
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutOfStockOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: AppSpacing.borderRadiusSM,
          ),
          child: Text(
            '품절',
            style: AppTypography.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo(bool isDark) {
    // 할인율 계산 (임시로 10-50% 랜덤)
    final discountPercent = 48;
    final originalPrice = product.price * 1.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 상품명
        Text(
          product.name ?? '',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontSize: 11.5,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),

        // 가격 영역
        Row(
          children: [
            // 할인율
            Text(
              '$discountPercent%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(width: 4),
            // 할인가
            Expanded(
              child: Text(
                FormatUtils.formatPrice(product.price),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 1),

        // 원가
        Text(
          FormatUtils.formatPrice(originalPrice),
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
            decoration: TextDecoration.lineThrough,
          ),
        ),
        const SizedBox(height: 2),

        // 무료배송 배지
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: Colors.grey[300]!, width: 0.5),
          ),
          child: Text(
            '무료배송',
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 2),

        // 별점 및 리뷰 수
        Row(
          children: [
            Icon(
              Icons.star,
              size: 11,
              color: Colors.blue[700],
            ),
            const SizedBox(width: 2),
            Text(
              '4.5 (2,340)',
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

}
