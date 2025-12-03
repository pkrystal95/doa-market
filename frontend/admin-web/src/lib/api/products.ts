import { apiClient } from '../api-client';
import { ApiResponse, Product, PaginationParams, Category } from '@/types';

export const productsApi = {
  // 상품 목록 조회 (관리자)
  getProducts: async (params?: PaginationParams): Promise<ApiResponse<Product[]>> => {
    return apiClient.get('/api/v1/admin/products', { params });
  },

  // 상품 상세 조회
  getProduct: async (productId: string): Promise<ApiResponse<Product>> => {
    return apiClient.get(`/api/v1/admin/products/${productId}`);
  },

  // 상품 승인 (심사 완료)
  approveProduct: async (productId: string): Promise<ApiResponse<Product>> => {
    return apiClient.post(`/api/v1/admin/products/${productId}/approve`);
  },

  // 상품 거부
  rejectProduct: async (productId: string, reason: string): Promise<ApiResponse<Product>> => {
    return apiClient.post(`/api/v1/admin/products/${productId}/reject`, { reason });
  },

  // 상품 삭제
  deleteProduct: async (productId: string): Promise<ApiResponse<void>> => {
    return apiClient.delete(`/api/v1/admin/products/${productId}`);
  },

  // 상품 상태 변경
  updateProductStatus: async (productId: string, status: string): Promise<ApiResponse<Product>> => {
    return apiClient.patch(`/api/v1/admin/products/${productId}/status`, { status });
  },

  // 카테고리 목록
  getCategories: async (): Promise<ApiResponse<Category[]>> => {
    return apiClient.get('/api/v1/products/categories');
  },

  // 카테고리 생성
  createCategory: async (data: Partial<Category>): Promise<ApiResponse<Category>> => {
    return apiClient.post('/api/v1/admin/products/categories', data);
  },

  // 카테고리 수정
  updateCategory: async (categoryId: string, data: Partial<Category>): Promise<ApiResponse<Category>> => {
    return apiClient.patch(`/api/v1/admin/products/categories/${categoryId}`, data);
  },

  // 카테고리 삭제
  deleteCategory: async (categoryId: string): Promise<ApiResponse<void>> => {
    return apiClient.delete(`/api/v1/admin/products/categories/${categoryId}`);
  },

  // 상품 통계
  getProductStats: async (): Promise<ApiResponse<{
    totalProducts: number;
    pendingProducts: number;
    activeProducts: number;
    outOfStockProducts: number;
  }>> => {
    return apiClient.get('/api/v1/admin/products/stats');
  },
};
