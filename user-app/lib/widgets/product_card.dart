import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import 'price_text.dart';

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

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isOutOfStock ? null : onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              flex: 3,
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
            Expanded(
              flex: 2,
              child: Padding(
                padding: AppSpacing.paddingSM,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildProductInfo(isDark),
                    ),
                    if (showActions && !isOutOfStock && onAddToCart != null)
                      _buildAddToCartButton(isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
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
      top: AppSpacing.xs,
      right: AppSpacing.xs,
      child: Material(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: AppSpacing.borderRadiusFull,
        child: InkWell(
          onTap: onToggleWishlist,
          borderRadius: AppSpacing.borderRadiusFull,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isInWishlist ? AppColors.error : AppColors.textSecondary,
              size: AppSpacing.iconSM,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          product.name ?? '',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        PriceText(
          price: product.price ?? 0,
          size: PriceTextSize.small,
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onAddToCart,
        icon: const Icon(Icons.add_shopping_cart, size: AppSpacing.iconXS),
        label: Text(
          '담기',
          style: AppTypography.labelSmall,
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          minimumSize: const Size(0, AppSpacing.buttonHeightSM),
        ),
      ),
    );
  }
}
