import { apiClient } from '../api-client';
import { ApiResponse, Review, PaginationParams } from '@/types';

export const reviewsApi = {
  // 리뷰 목록 조회
  getReviews: async (params?: PaginationParams): Promise<ApiResponse<Review[]>> => {
    return apiClient.get('/api/v1/admin/reviews', { params });
  },

  // 리뷰 상세 조회
  getReview: async (reviewId: string): Promise<ApiResponse<Review>> => {
    return apiClient.get(`/api/v1/admin/reviews/${reviewId}`);
  },

  // 리뷰 삭제 (부적절한 리뷰)
  deleteReview: async (reviewId: string): Promise<ApiResponse<void>> => {
    return apiClient.delete(`/api/v1/admin/reviews/${reviewId}`);
  },

  // 베스트 리뷰 지정
  markAsBest: async (reviewId: string): Promise<ApiResponse<Review>> => {
    return apiClient.post(`/api/v1/admin/reviews/${reviewId}/best`);
  },

  // 베스트 리뷰 해제
  unmarkAsBest: async (reviewId: string): Promise<ApiResponse<Review>> => {
    return apiClient.delete(`/api/v1/admin/reviews/${reviewId}/best`);
  },
};

