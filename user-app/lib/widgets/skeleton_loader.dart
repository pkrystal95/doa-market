import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Skeleton loader widget with shimmer effect
class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  /// Create a circular skeleton loader
  factory SkeletonLoader.circular({
    required double size,
  }) {
    return SkeletonLoader(
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }

  /// Create a rectangular skeleton loader
  factory SkeletonLoader.rectangular({
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return SkeletonLoader(
      width: width,
      height: height,
      borderRadius: borderRadius ?? AppSpacing.borderRadiusSM,
    );
  }

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase;
    final highlightColor =
        isDark ? AppColors.shimmerHighlightDark : AppColors.shimmerHighlight;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                _animation.value - 1,
                _animation.value,
                _animation.value + 1,
              ].map((value) => value.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Product card skeleton loader
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingSM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image skeleton
            Expanded(
              flex: 3,
              child: SkeletonLoader.rectangular(
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Title skeleton
            SkeletonLoader.rectangular(
              width: double.infinity,
              height: 16,
            ),
            const SizedBox(height: AppSpacing.xs),

            // Subtitle skeleton
            SkeletonLoader.rectangular(
              width: 100,
              height: 14,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Price skeleton
            SkeletonLoader.rectangular(
              width: 80,
              height: 18,
            ),
          ],
        ),
      ),
    );
  }
}

/// List item skeleton loader
class ListItemSkeleton extends StatelessWidget {
  const ListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Row(
          children: [
            // Image skeleton
            SkeletonLoader.rectangular(
              width: 80,
              height: 80,
            ),
            const SizedBox(width: AppSpacing.md),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader.rectangular(
                    width: double.infinity,
                    height: 16,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SkeletonLoader.rectangular(
                    width: 150,
                    height: 14,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SkeletonLoader.rectangular(
                    width: 100,
                    height: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
