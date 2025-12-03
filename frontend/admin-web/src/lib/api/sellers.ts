import { apiClient } from '../api-client';
import { ApiResponse, Seller, PaginationParams, SellerStats } from '@/types';

export const sellersApi = {
  // 판매자 목록 조회
  getSellers: async (params?: PaginationParams): Promise<ApiResponse<Seller[]>> => {
    return apiClient.get('/api/v1/admin/sellers', { params });
  },

  // 판매자 상세 조회
  getSeller: async (sellerId: string): Promise<ApiResponse<Seller>> => {
    return apiClient.get(`/api/v1/admin/sellers/${sellerId}`);
  },

  // 판매자 승인
  approveSeller: async (sellerId: string): Promise<ApiResponse<Seller>> => {
    return apiClient.post(`/api/v1/admin/sellers/${sellerId}/approve`);
  },

  // 판매자 거부
  rejectSeller: async (sellerId: string, reason: string): Promise<ApiResponse<Seller>> => {
    return apiClient.post(`/api/v1/admin/sellers/${sellerId}/reject`, { reason });
  },

  // 판매자 정지
  suspendSeller: async (sellerId: string, reason: string): Promise<ApiResponse<Seller>> => {
    return apiClient.post(`/api/v1/admin/sellers/${sellerId}/suspend`, { reason });
  },

  // 판매자 정지 해제
  unsuspendSeller: async (sellerId: string): Promise<ApiResponse<Seller>> => {
    return apiClient.post(`/api/v1/admin/sellers/${sellerId}/unsuspend`);
  },

  // 판매자 통계
  getSellerStats: async (sellerId: string): Promise<ApiResponse<SellerStats>> => {
    return apiClient.get(`/api/v1/admin/sellers/${sellerId}/stats`);
  },

  // 전체 판매자 통계
  getAllSellerStats: async (): Promise<ApiResponse<{
    totalSellers: number;
    pendingSellers: number;
    approvedSellers: number;
    suspendedSellers: number;
  }>> => {
    return apiClient.get('/api/v1/admin/sellers/stats');
  },
};

