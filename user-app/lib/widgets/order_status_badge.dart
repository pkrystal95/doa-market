import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

/// Order status enum
enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
}

/// Extension for OrderStatus to get display name and color
extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return '결제 대기';
      case OrderStatus.confirmed:
        return '결제 완료';
      case OrderStatus.processing:
        return '상품 준비중';
      case OrderStatus.shipped:
        return '배송중';
      case OrderStatus.delivered:
        return '배송 완료';
      case OrderStatus.cancelled:
        return '취소됨';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return AppColors.statusPending;
      case OrderStatus.confirmed:
        return AppColors.statusConfirmed;
      case OrderStatus.processing:
        return AppColors.statusProcessing;
      case OrderStatus.shipped:
        return AppColors.statusShipped;
      case OrderStatus.delivered:
        return AppColors.statusDelivered;
      case OrderStatus.cancelled:
        return AppColors.statusCancelled;
    }
  }

  /// Parse from string
  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}

/// Reusable order status badge widget
class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;
  final bool compact;

  const OrderStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  /// Create from string
  factory OrderStatusBadge.fromString(String status, {bool compact = false}) {
    return OrderStatusBadge(
      status: OrderStatusExtension.fromString(status),
      compact: compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xxs,
            )
          : const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusFull,
        border: Border.all(
          color: status.color,
          width: 1,
        ),
      ),
      child: Text(
        status.displayName,
        style: compact
            ? AppTypography.labelSmall.copyWith(
                color: status.color,
                fontWeight: FontWeight.w600,
              )
            : AppTypography.labelMedium.copyWith(
                color: status.color,
                fontWeight: FontWeight.w600,
              ),
      ),
    );
  }
}
