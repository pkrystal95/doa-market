import { apiClient } from '../api-client';
import { ApiResponse, User, PaginationParams } from '@/types';

export const usersApi = {
  // 사용자 목록 조회
  getUsers: async (params?: PaginationParams): Promise<ApiResponse<User[]>> => {
    return apiClient.get('/api/v1/admin/users', { params });
  },

  // 사용자 상세 조회
  getUser: async (userId: string): Promise<ApiResponse<User>> => {
    return apiClient.get(`/api/v1/admin/users/${userId}`);
  },

  // 사용자 상태 업데이트 (정지/복구)
  updateUserStatus: async (userId: string, status: 'active' | 'suspended'): Promise<ApiResponse<User>> => {
    return apiClient.patch(`/api/v1/admin/users/${userId}/status`, { status });
  },

  // 사용자 삭제
  deleteUser: async (userId: string): Promise<ApiResponse<void>> => {
    return apiClient.delete(`/api/v1/admin/users/${userId}`);
  },

  // 사용자 통계
  getUserStats: async (): Promise<ApiResponse<{
    totalUsers: number;
    activeUsers: number;
    suspendedUsers: number;
    newUsersToday: number;
    newUsersThisWeek: number;
    newUsersThisMonth: number;
  }>> => {
    return apiClient.get('/api/v1/admin/users/stats');
  },
};

