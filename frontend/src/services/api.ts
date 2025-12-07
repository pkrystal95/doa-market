import axios from 'axios';
import type { ApiResponse, PaginatedResponse, User, Product, Order, Seller } from '@/types';

const API_BASE_URL = '/api/v1';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

api.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error('API Error:', error);
    return Promise.reject(error);
  }
);

export const usersApi = {
  getAll: (page = 1, limit = 10) =>
    api.get<PaginatedResponse<User>>(`/profiles`, { params: { page, limit } }),

  getById: (userId: string) =>
    api.get<ApiResponse<User>>(`/profiles/${userId}`),

  search: (query: string) =>
    api.get<ApiResponse<User[]>>(`/profiles/search`, { params: { q: query } }),

  create: (data: Partial<User>) =>
    api.post<ApiResponse<User>>(`/profiles`, data),

  update: (userId: string, data: Partial<User>) =>
    api.put<ApiResponse<User>>(`/profiles/${userId}`, data),

  delete: (userId: string) =>
    api.delete<ApiResponse<void>>(`/profiles/${userId}`),
};

export const productsApi = {
  getAll: (page = 1, limit = 10) =>
    api.get<PaginatedResponse<Product>>(`/products`, { params: { page, limit } }),

  getById: (productId: string) =>
    api.get<ApiResponse<Product>>(`/products/${productId}`),

  search: (query: string) =>
    api.get<ApiResponse<Product[]>>(`/products/search`, { params: { query } }),

  create: (data: Partial<Product>) =>
    api.post<ApiResponse<Product>>(`/products`, data),

  update: (productId: string, data: Partial<Product>) =>
    api.put<ApiResponse<Product>>(`/products/${productId}`, data),

  delete: (productId: string) =>
    api.delete<ApiResponse<void>>(`/products/${productId}`),
};

export const ordersApi = {
  getAll: (page = 1, limit = 10) =>
    api.get<PaginatedResponse<Order>>(`/orders`, { params: { page, limit } }),

  getById: (orderId: string) =>
    api.get<ApiResponse<Order>>(`/orders/${orderId}`),

  getByUser: (userId: string) =>
    api.get<ApiResponse<Order[]>>(`/orders/user/${userId}`),

  create: (data: Partial<Order>) =>
    api.post<ApiResponse<Order>>(`/orders`, data),

  updateStatus: (orderId: string, status: Order['status']) =>
    api.patch<ApiResponse<Order>>(`/orders/${orderId}/status`, { status }),
};

export const sellersApi = {
  getAll: (page = 1, limit = 10) =>
    api.get<PaginatedResponse<Seller>>(`/sellers`, { params: { page, limit } }),

  getById: (sellerId: string) =>
    api.get<ApiResponse<Seller>>(`/sellers/${sellerId}`),

  approve: (sellerId: string) =>
    api.post<ApiResponse<Seller>>(`/sellers/${sellerId}/approve`),

  suspend: (sellerId: string) =>
    api.post<ApiResponse<Seller>>(`/sellers/${sellerId}/suspend`),
};

export const noticesApi = {
  getAll: (page = 1, limit = 10, params?: any) =>
    api.get<any>(`/admin/notices`, { params: { page, limit, ...params } }),

  getById: (id: string) =>
    api.get<any>(`/admin/notices/${id}`),

  create: (data: any) =>
    api.post<any>(`/admin/notices`, data),

  update: (id: string, data: any) =>
    api.put<any>(`/admin/notices/${id}`, data),

  delete: (id: string) =>
    api.delete<any>(`/admin/notices/${id}`),
};

export const inquiriesApi = {
  getAll: (page = 1, limit = 10, params?: any) =>
    api.get<any>(`/admin/inquiries`, { params: { page, limit, ...params } }),

  getById: (id: string) =>
    api.get<any>(`/admin/inquiries/${id}`),

  create: (data: any) =>
    api.post<any>(`/admin/inquiries`, data),

  answer: (id: string, answer: string, answeredBy: string) =>
    api.post<any>(`/admin/inquiries/${id}/answer`, { answer, answeredBy }),

  updateStatus: (id: string, status: string) =>
    api.patch<any>(`/admin/inquiries/${id}/status`, { status }),

  delete: (id: string) =>
    api.delete<any>(`/admin/inquiries/${id}`),
};

export const policiesApi = {
  getAll: (page = 1, limit = 10, params?: any) =>
    api.get<any>(`/admin/policies`, { params: { page, limit, ...params } }),

  getById: (id: string) =>
    api.get<any>(`/admin/policies/${id}`),

  getActiveByType: (type: string) =>
    api.get<any>(`/admin/policies/type/${type}/active`),

  create: (data: any) =>
    api.post<any>(`/admin/policies`, data),

  update: (id: string, data: any) =>
    api.put<any>(`/admin/policies/${id}`, data),

  activate: (id: string) =>
    api.post<any>(`/admin/policies/${id}/activate`),

  delete: (id: string) =>
    api.delete<any>(`/admin/policies/${id}`),
};

export default api;
