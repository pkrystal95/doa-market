// Admin Web의 타입을 재사용
export * from '../../admin-web/src/types';

// Seller-specific types
export interface SellerDashboardStats {
  totalProducts: number;
  totalOrders: number;
  totalRevenue: number;
  pendingOrders: number;
  productGrowth: number;
  orderGrowth: number;
  revenueGrowth: number;
}

export interface SellerOrderSummary {
  totalOrders: number;
  pendingOrders: number;
  processingOrders: number;
  shippedOrders: number;
  deliveredOrders: number;
  cancelledOrders: number;
}

