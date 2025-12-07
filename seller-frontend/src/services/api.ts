import axios from 'axios';

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

// 판매자 상품 API
export const productsApi = {
  getAll: (page = 1, limit = 10, sellerId: string) =>
    api.get<any>(`/products`, { params: { page, limit, sellerId } }),

  getById: (productId: string) =>
    api.get<any>(`/products/${productId}`),

  create: (data: any) =>
    api.post<any>(`/products`, data),

  update: (productId: string, data: any) =>
    api.put<any>(`/products/${productId}`, data),

  delete: (productId: string) =>
    api.delete<any>(`/products/${productId}`),

  updateStock: (productId: string, stock: number) =>
    api.patch<any>(`/products/${productId}/stock`, { stock }),
};

// 주문 API
export const ordersApi = {
  getAll: (page = 1, limit = 10, sellerId?: string) =>
    api.get<any>(`/orders`, { params: { page, limit, sellerId } }),

  getById: (orderId: string) =>
    api.get<any>(`/orders/${orderId}`),

  updateStatus: (orderId: string, status: string) =>
    api.patch<any>(`/orders/${orderId}/status`, { status }),
};

// 리뷰 API
export const reviewsApi = {
  getAll: (page = 1, limit = 10, sellerId?: string) =>
    api.get<any>(`/reviews`, { params: { page, limit, sellerId } }),

  getById: (reviewId: string) =>
    api.get<any>(`/reviews/${reviewId}`),

  reply: (reviewId: string, reply: string) =>
    api.post<any>(`/reviews/${reviewId}/reply`, { reply }),
};

// 정산 API
export const settlementsApi = {
  getAll: (page = 1, limit = 10, sellerId?: string) =>
    api.get<any>(`/settlements`, { params: { page, limit, sellerId } }),

  getById: (settlementId: string) =>
    api.get<any>(`/settlements/${settlementId}`),

  request: (data: any) =>
    api.post<any>(`/settlements/request`, data),
};

// 문의사항 API
export const inquiriesApi = {
  getAll: (page = 1, limit = 10, userId?: string) =>
    api.get<any>(`/admin/inquiries`, { params: { page, limit, userId } }),

  getById: (id: string) =>
    api.get<any>(`/admin/inquiries/${id}`),

  create: (data: any) =>
    api.post<any>(`/admin/inquiries`, data),

  delete: (id: string) =>
    api.delete<any>(`/admin/inquiries/${id}`),
};

export default api;
