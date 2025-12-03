import { apiClient } from '../api-client';
import { ApiResponse, Notice, PaginationParams } from '@/types';

export const noticesApi = {
  // 공지사항 목록
  getNotices: async (params?: PaginationParams): Promise<ApiResponse<Notice[]>> => {
    return apiClient.get('/api/v1/admin/notices', { params });
  },

  // 공지사항 상세
  getNotice: async (noticeId: string): Promise<ApiResponse<Notice>> => {
    return apiClient.get(`/api/v1/admin/notices/${noticeId}`);
  },

  // 공지사항 생성
  createNotice: async (data: Partial<Notice>): Promise<ApiResponse<Notice>> => {
    return apiClient.post('/api/v1/admin/notices', data);
  },

  // 공지사항 수정
  updateNotice: async (noticeId: string, data: Partial<Notice>): Promise<ApiResponse<Notice>> => {
    return apiClient.patch(`/api/v1/admin/notices/${noticeId}`, data);
  },

  // 공지사항 삭제
  deleteNotice: async (noticeId: string): Promise<ApiResponse<void>> => {
    return apiClient.delete(`/api/v1/admin/notices/${noticeId}`);
  },

  // 공지사항 발행
  publishNotice: async (noticeId: string): Promise<ApiResponse<Notice>> => {
    return apiClient.post(`/api/v1/admin/notices/${noticeId}/publish`);
  },
};

