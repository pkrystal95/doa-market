import { apiClient } from '../api-client';
import { ApiResponse, Settlement, PaginationParams } from '@/types';

export const settlementsApi = {
  // 정산 목록 조회
  getSettlements: async (params?: PaginationParams): Promise<ApiResponse<Settlement[]>> => {
    return apiClient.get('/api/v1/admin/settlements', { params });
  },

  // 정산 상세 조회
  getSettlement: async (settlementId: string): Promise<ApiResponse<Settlement>> => {
    return apiClient.get(`/api/v1/admin/settlements/${settlementId}`);
  },

  // 정산 확정
  confirmSettlement: async (settlementId: string): Promise<ApiResponse<Settlement>> => {
    return apiClient.post(`/api/v1/admin/settlements/${settlementId}/confirm`);
  },

  // 정산 지급 완료 처리
  markSettlementAsPaid: async (settlementId: string): Promise<ApiResponse<Settlement>> => {
    return apiClient.post(`/api/v1/admin/settlements/${settlementId}/paid`);
  },

  // 판매자별 정산 목록
  getSellerSettlements: async (sellerId: string, params?: PaginationParams): Promise<ApiResponse<Settlement[]>> => {
    return apiClient.get(`/api/v1/admin/settlements/seller/${sellerId}`, { params });
  },

  // 정산 통계
  getSettlementStats: async (): Promise<ApiResponse<{
    totalSettlements: number;
    calculatedAmount: number;
    confirmedAmount: number;
    paidAmount: number;
    pendingCount: number;
  }>> => {
    return apiClient.get('/api/v1/admin/settlements/stats');
  },
};

