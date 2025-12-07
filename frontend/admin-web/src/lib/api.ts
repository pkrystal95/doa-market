import axios from 'axios';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor
apiClient.interceptors.request.use(
  (config) => {
    if (typeof window !== 'undefined') {
      const token = localStorage.getItem('accessToken');
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor
apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      // Token expired, try refresh
      if (typeof window !== 'undefined') {
        localStorage.removeItem('accessToken');
        localStorage.removeItem('refreshToken');
        window.location.href = '/login';
      }
    }
    return Promise.reject(error);
  }
);

// Auth API
export const authApi = {
  login: async (credentials: { email: string; password: string }) => {
    const response = await apiClient.post('/api/v1/auth/login', credentials);
    return response.data;
  },
  register: async (data: any) => {
    const response = await apiClient.post('/api/v1/auth/register', data);
    return response.data;
  },
  logout: async () => {
    const response = await apiClient.post('/api/v1/auth/logout');
    return response.data;
  },
};

// Dashboard API
export const dashboardApi = {
  getStats: async () => {
    // Mock data for now
    return {
      data: {
        totalUsers: 1248,
        userGrowth: 12,
        totalOrders: 3567,
        orderGrowth: 23,
        totalProducts: 892,
        productGrowth: 8,
        totalRevenue: 125000000,
        revenueGrowth: 18,
      },
    };
  },
  getSalesChart: async (period: string) => {
    return { data: [] };
  },
  getRecentOrders: async (limit: number) => {
    return { data: [] };
  },
};

export default apiClient;

