import { apiClient } from '../api-client';
import { ApiResponse, Coupon, PaginationParams } from '@/types';

export const couponsApi = {
  // 쿠폰 목록 조회
  getCoupons: async (params?: PaginationParams): Promise<ApiResponse<Coupon[]>> => {
    return apiClient.get('/api/v1/admin/coupons', { params });
  },

  // 쿠폰 상세 조회
  getCoupon: async (couponId: string): Promise<ApiResponse<Coupon>> => {
    return apiClient.get(`/api/v1/admin/coupons/${couponId}`);
  },

  // 쿠폰 생성
  createCoupon: async (data: Partial<Coupon>): Promise<ApiResponse<Coupon>> => {
    return apiClient.post('/api/v1/admin/coupons', data);
  },

  // 쿠폰 수정
  updateCoupon: async (couponId: string, data: Partial<Coupon>): Promise<ApiResponse<Coupon>> => {
    return apiClient.patch(`/api/v1/admin/coupons/${couponId}`, data);
  },

  // 쿠폰 삭제
  deleteCoupon: async (couponId: string): Promise<ApiResponse<void>> => {
    return apiClient.delete(`/api/v1/admin/coupons/${couponId}`);
  },

  // 쿠폰 전체 발급
  issueCouponToAll: async (couponId: string): Promise<ApiResponse<{ issuedCount: number }>> => {
    return apiClient.post(`/api/v1/admin/coupons/${couponId}/issue-all`);
  },

  // 특정 사용자에게 쿠폰 발급
  issueCouponToUser: async (couponId: string, userId: string): Promise<ApiResponse<void>> => {
    return apiClient.post(`/api/v1/admin/coupons/${couponId}/issue`, { userId });
  },
};

