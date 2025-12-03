import { apiClient } from '../api-client';
import { ApiResponse, Order, PaginationParams, Payment, Shipment } from '@/types';

export const ordersApi = {
  // 주문 목록 조회
  getOrders: async (params?: PaginationParams): Promise<ApiResponse<Order[]>> => {
    return apiClient.get('/api/v1/admin/orders', { params });
  },

  // 주문 상세 조회
  getOrder: async (orderId: string): Promise<ApiResponse<Order>> => {
    return apiClient.get(`/api/v1/admin/orders/${orderId}`);
  },

  // 주문 상태 변경
  updateOrderStatus: async (orderId: string, status: string): Promise<ApiResponse<Order>> => {
    return apiClient.patch(`/api/v1/admin/orders/${orderId}/status`, { status });
  },

  // 주문 취소 (관리자)
  cancelOrder: async (orderId: string, reason: string): Promise<ApiResponse<Order>> => {
    return apiClient.post(`/api/v1/admin/orders/${orderId}/cancel`, { reason });
  },

  // 주문 결제 정보
  getOrderPayment: async (orderId: string): Promise<ApiResponse<Payment>> => {
    return apiClient.get(`/api/v1/admin/orders/${orderId}/payment`);
  },

  // 주문 배송 정보
  getOrderShipment: async (orderId: string): Promise<ApiResponse<Shipment>> => {
    return apiClient.get(`/api/v1/admin/orders/${orderId}/shipment`);
  },

  // 주문 통계
  getOrderStats: async (): Promise<ApiResponse<{
    totalOrders: number;
    pendingOrders: number;
    processingOrders: number;
    shippedOrders: number;
    deliveredOrders: number;
    cancelledOrders: number;
    todayOrders: number;
    todayRevenue: number;
  }>> => {
    return apiClient.get('/api/v1/admin/orders/stats');
  },
};
