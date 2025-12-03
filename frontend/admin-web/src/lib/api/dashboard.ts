import { apiClient } from '../api-client';
import { ApiResponse, DashboardStats, SalesChart, CategoryStats, SellerStats } from '@/types';

export const dashboardApi = {
  // 대시보드 전체 통계
  getStats: async (): Promise<ApiResponse<DashboardStats>> => {
    return apiClient.get('/api/v1/admin/dashboard/stats');
  },

  // 매출 차트 데이터
  getSalesChart: async (period: 'week' | 'month' | 'year'): Promise<ApiResponse<SalesChart[]>> => {
    return apiClient.get('/api/v1/admin/dashboard/sales-chart', { params: { period } });
  },

  // 카테고리별 통계
  getCategoryStats: async (limit?: number): Promise<ApiResponse<CategoryStats[]>> => {
    return apiClient.get('/api/v1/admin/dashboard/category-stats', { params: { limit } });
  },

  // 상위 판매자 통계
  getTopSellers: async (limit?: number): Promise<ApiResponse<SellerStats[]>> => {
    return apiClient.get('/api/v1/admin/dashboard/top-sellers', { params: { limit } });
  },

  // 최근 주문 목록
  getRecentOrders: async (limit?: number): Promise<ApiResponse<any[]>> => {
    return apiClient.get('/api/v1/admin/dashboard/recent-orders', { params: { limit } });
  },
};

