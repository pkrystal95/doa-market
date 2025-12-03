import { apiClient } from '../api-client';
import { ApiResponse, LoginRequest, LoginResponse, User } from '@/types';

export const authApi = {
  // 로그인
  login: async (data: LoginRequest): Promise<ApiResponse<LoginResponse>> => {
    return apiClient.post('/api/v1/auth/login', data);
  },

  // 로그아웃
  logout: async (): Promise<ApiResponse<void>> => {
    return apiClient.post('/api/v1/auth/logout');
  },

  // 토큰 갱신
  refresh: async (refreshToken: string): Promise<ApiResponse<{ accessToken: string }>> => {
    return apiClient.post('/api/v1/auth/refresh', { refreshToken });
  },

  // 현재 사용자 정보
  me: async (): Promise<ApiResponse<User>> => {
    return apiClient.get('/api/v1/auth/me');
  },

  // 비밀번호 재설정 요청
  requestPasswordReset: async (email: string): Promise<ApiResponse<void>> => {
    return apiClient.post('/api/v1/auth/password/reset-request', { email });
  },

  // 비밀번호 재설정
  resetPassword: async (token: string, newPassword: string): Promise<ApiResponse<void>> => {
    return apiClient.post('/api/v1/auth/password/reset', { token, newPassword });
  },
};

