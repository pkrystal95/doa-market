// ============================================================
// Core Types
// ============================================================

export interface User {
  id: string;
  email: string;
  name: string;
  phone?: string;
  role: 'admin' | 'seller' | 'user';
  status: 'active' | 'suspended' | 'deleted';
  grade?: 'bronze' | 'silver' | 'gold' | 'vip';
  createdAt: string;
  updatedAt: string;
}

export interface Address {
  id?: string;
  recipientName: string;
  phone: string;
  zipCode: string;
  address: string;
  addressDetail: string;
  isDefault?: boolean;
}

// ============================================================
// Product Types
// ============================================================

export interface Category {
  id: string;
  name: string;
  slug: string;
  parentId?: string;
  level: number;
  order: number;
  children?: Category[];
}

export interface ProductOption {
  id: string;
  name: string;
  values: string[];
  required: boolean;
}

export interface Product {
  id: string;
  sellerId: string;
  seller?: {
    id: string;
    businessName: string;
  };
  categoryId: string;
  category?: Category;
  name: string;
  slug: string;
  description?: string;
  price: number;
  originalPrice?: number;
  discountRate: number;
  status: 'draft' | 'pending' | 'active' | 'inactive' | 'rejected' | 'out_of_stock';
  approvalStatus?: 'pending' | 'approved' | 'rejected';
  stockQuantity: number;
  ratingAvg: number;
  reviewCount: number;
  salesCount: number;
  viewCount: number;
  thumbnail?: string;
  images?: string[];
  options?: ProductOption[];
  createdAt: string;
  updatedAt: string;
}

// ============================================================
// Order Types
// ============================================================

export interface OrderItem {
  id: string;
  orderId: string;
  productId: string;
  productName: string;
  productImage?: string;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
  options?: Record<string, string>;
}

export interface Order {
  id: string;
  orderNumber: string;
  userId: string;
  user?: {
    id: string;
    name: string;
    email: string;
  };
  sellerId: string;
  seller?: {
    id: string;
    businessName: string;
  };
  status: 'pending' | 'confirmed' | 'processing' | 'shipped' | 'delivered' | 'cancelled' | 'refunded';
  items: OrderItem[];
  subtotalAmount: number;
  shippingAmount: number;
  discountAmount: number;
  totalAmount: number;
  paymentMethod: 'card' | 'transfer' | 'virtual_account' | 'mobile';
  paymentStatus: 'pending' | 'completed' | 'failed' | 'cancelled' | 'refunded';
  shippingAddress: Address;
  memo?: string;
  createdAt: string;
  updatedAt: string;
}

// ============================================================
// Payment Types
// ============================================================

export interface Payment {
  id: string;
  orderId: string;
  amount: number;
  method: 'card' | 'transfer' | 'virtual_account' | 'mobile';
  status: 'pending' | 'completed' | 'failed' | 'cancelled' | 'refunded';
  pgTransactionId?: string;
  pgProvider?: string;
  paidAt?: string;
  failReason?: string;
  createdAt: string;
}

export interface Refund {
  id: string;
  paymentId: string;
  orderId: string;
  amount: number;
  reason: string;
  status: 'pending' | 'completed' | 'failed';
  refundedAt?: string;
  createdAt: string;
}

// ============================================================
// Seller Types
// ============================================================

export interface Seller {
  id: string;
  userId: string;
  user?: User;
  businessName: string;
  businessNumber: string;
  ownerName: string;
  phone: string;
  email: string;
  status: 'pending' | 'approved' | 'rejected' | 'suspended';
  address?: string;
  bankAccount?: {
    bank: string;
    accountNumber: string;
    accountHolder: string;
  };
  documents?: string[];
  rejectionReason?: string;
  approvedAt?: string;
  createdAt: string;
  updatedAt: string;
}

export interface Store {
  id: string;
  sellerId: string;
  name: string;
  slug: string;
  description?: string;
  logo?: string;
  banner?: string;
  rating: number;
  productCount: number;
  orderCount: number;
  createdAt: string;
}

// ============================================================
// Settlement Types
// ============================================================

export interface Settlement {
  id: string;
  sellerId: string;
  seller?: {
    id: string;
    businessName: string;
  };
  periodStart: string;
  periodEnd: string;
  totalSalesAmount: number;
  commissionAmount: number;
  shippingAmount: number;
  refundAmount: number;
  finalAmount: number;
  status: 'calculated' | 'confirmed' | 'paid';
  paidAt?: string;
  items: SettlementItem[];
  createdAt: string;
}

export interface SettlementItem {
  id: string;
  orderId: string;
  orderNumber: string;
  productName: string;
  quantity: number;
  salesAmount: number;
  commissionRate: number;
  commissionAmount: number;
  finalAmount: number;
  orderDate: string;
}

// ============================================================
// Shipping Types
// ============================================================

export interface Shipment {
  id: string;
  orderId: string;
  carrier: string;
  trackingNumber: string;
  status: 'pending' | 'dispatched' | 'in_transit' | 'delivered' | 'failed' | 'returned';
  estimatedDelivery?: string;
  dispatchedAt?: string;
  deliveredAt?: string;
  createdAt: string;
}

// ============================================================
// Review Types
// ============================================================

export interface Review {
  id: string;
  userId: string;
  user?: {
    id: string;
    name: string;
  };
  productId: string;
  product?: {
    id: string;
    name: string;
  };
  orderId: string;
  rating: number;
  content: string;
  images?: string[];
  isBest: boolean;
  createdAt: string;
  updatedAt: string;
}

// ============================================================
// Coupon Types
// ============================================================

export interface Coupon {
  id: string;
  name: string;
  code: string;
  type: 'percentage' | 'fixed_amount';
  discountValue: number;
  minOrderAmount?: number;
  maxDiscountAmount?: number;
  quantity?: number;
  usedQuantity: number;
  startDate: string;
  endDate: string;
  status: 'active' | 'inactive' | 'expired';
  createdAt: string;
}

// ============================================================
// Notice Types
// ============================================================

export interface Notice {
  id: string;
  title: string;
  content: string;
  type: 'general' | 'maintenance' | 'urgent';
  status: 'draft' | 'published';
  publishedAt?: string;
  createdAt: string;
  updatedAt: string;
}

// ============================================================
// Statistics Types
// ============================================================

export interface DashboardStats {
  totalUsers: number;
  totalSellers: number;
  totalProducts: number;
  totalOrders: number;
  totalRevenue: number;
  todayOrders: number;
  todayRevenue: number;
  userGrowth: number;
  orderGrowth: number;
  revenueGrowth: number;
  productGrowth: number;
}

export interface SalesChart {
  date: string;
  revenue: number;
  orders: number;
}

export interface CategoryStats {
  categoryId: string;
  categoryName: string;
  productCount: number;
  salesCount: number;
  revenue: number;
}

export interface SellerStats {
  sellerId: string;
  businessName: string;
  productCount: number;
  orderCount: number;
  revenue: number;
  rating: number;
}

// ============================================================
// API Types
// ============================================================

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: {
    code: string;
    message: string;
    details?: any;
  };
  meta?: PaginationMeta;
  timestamp: string;
}

export interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

export interface PaginationParams {
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: 'ASC' | 'DESC';
  search?: string;
  filters?: Record<string, any>;
}

// ============================================================
// Auth Types
// ============================================================

export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  accessToken: string;
  refreshToken: string;
  user: User;
}

export interface AuthState {
  user: User | null;
  accessToken: string | null;
  refreshToken: string | null;
  isAuthenticated: boolean;
}
