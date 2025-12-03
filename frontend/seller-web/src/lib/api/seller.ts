import { apiClient } from '../api-client';
import { ApiResponse, Product, Order, Settlement, PaginationParams, SellerDashboardStats } from '@/types';

export const sellerApi = {
  // 대시보드 통계
  getDashboardStats: async (): Promise<ApiResponse<SellerDashboardStats>> => {
    return apiClient.get('/api/v1/seller/dashboard/stats');
  },

  // 상품 관리
  getMyProducts: async (params?: PaginationParams): Promise<ApiResponse<Product[]>> => {
    return apiClient.get('/api/v1/seller/products', { params });
  },

  getProduct: async (productId: string): Promise<ApiResponse<Product>> => {
    return apiClient.get(`/api/v1/seller/products/${productId}`);
  },

  createProduct: async (data: Partial<Product>): Promise<ApiResponse<Product>> => {
    return apiClient.post('/api/v1/seller/products', data);
  },

  updateProduct: async (productId: string, data: Partial<Product>): Promise<ApiResponse<Product>> => {
    return apiClient.put(`/api/v1/seller/products/${productId}`, data);
  },

  deleteProduct: async (productId: string): Promise<ApiResponse<void>> => {
    return apiClient.delete(`/api/v1/seller/products/${productId}`);
  },

  // 주문 관리
  getMyOrders: async (params?: PaginationParams): Promise<ApiResponse<Order[]>> => {
    return apiClient.get('/api/v1/seller/orders', { params });
  },

  getOrder: async (orderId: string): Promise<ApiResponse<Order>> => {
    return apiClient.get(`/api/v1/seller/orders/${orderId}`);
  },

  updateOrderStatus: async (orderId: string, status: string): Promise<ApiResponse<Order>> => {
    return apiClient.patch(`/api/v1/seller/orders/${orderId}/status`, { status });
  },

  // 정산 관리
  getMySettlements: async (params?: PaginationParams): Promise<ApiResponse<Settlement[]>> => {
    return apiClient.get('/api/v1/seller/settlements', { params });
  },

  getSettlement: async (settlementId: string): Promise<ApiResponse<Settlement>> => {
    return apiClient.get(`/api/v1/seller/settlements/${settlementId}`);
  },

  // 스토어 정보
  getMyStore: async (): Promise<ApiResponse<any>> => {
    return apiClient.get('/api/v1/seller/store');
  },

  updateMyStore: async (data: any): Promise<ApiResponse<any>> => {
    return apiClient.put('/api/v1/seller/store', data);
  },

  // 통계
  getSalesStats: async (period: 'week' | 'month' | 'year'): Promise<ApiResponse<any[]>> => {
    return apiClient.get('/api/v1/seller/stats/sales', { params: { period } });
  },

  getProductStats: async (): Promise<ApiResponse<any>> => {
    return apiClient.get('/api/v1/seller/stats/products');
  },
};

