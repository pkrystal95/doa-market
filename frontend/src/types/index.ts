export interface User {
  id: string;
  email: string;
  name: string;
  phone?: string;
  profileImage?: string;
  role: string;
  grade: string;
  status: string;
  createdAt?: string;
  updatedAt?: string;
}

export interface Product {
  id: string;
  sellerId: string;
  categoryId: string;
  name: string;
  slug: string;
  description?: string;
  price: string;
  originalPrice?: string;
  status: string;
  stockQuantity: number;
  thumbnail?: string;
  createdAt?: string;
  updatedAt?: string;
}

export interface Order {
  orderId: string;
  userId: string;
  totalAmount: number;
  status: 'pending' | 'processing' | 'shipped' | 'delivered' | 'cancelled';
  createdAt: string;
  updatedAt?: string;
}

export interface Seller {
  id: string;
  userId: string;
  storeName: string;
  businessNumber: string;
  status: 'pending' | 'verified' | 'rejected' | 'suspended';
  verifiedAt?: string;
  createdAt?: string;
  updatedAt?: string;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface PaginatedResponse<T> {
  success: boolean;
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}
