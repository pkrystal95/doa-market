# 9. Next.js 관리자/판매자 페이지 구조 코드

## 개요

이 문서는 DOA Market의 관리자(Admin) 웹과 판매자(Seller) 웹 애플리케이션의 Next.js 구현을 설명합니다.

## 기술 스택

```yaml
프레임워크:
  - Next.js: 15.0+ (App Router)
  - React: 18.3+
  - TypeScript: 5.3+

상태 관리:
  - Zustand: 4.4+ (전역 상태)
  - TanStack Query: 5.17+ (서버 상태)

HTTP 클라이언트:
  - Axios: 1.6+

스타일링:
  - Tailwind CSS: 3.4+
  - Radix UI: 컴포넌트 기본
  - class-variance-authority: 조건부 스타일링

폼 관리:
  - React Hook Form: 7.49+
  - Zod: 3.22+ (스키마 검증)

차트:
  - Recharts: 2.10+

유틸리티:
  - date-fns: 3.0+ (날짜 포맷팅)
  - lucide-react: 0.303+ (아이콘)
```

## 프로젝트 구조

### Admin Web

```
frontend/admin-web/
├── src/
│   ├── app/                    # App Router
│   │   ├── (auth)/             # 인증 그룹 레이아웃
│   │   │   └── login/
│   │   │       └── page.tsx
│   │   ├── (dashboard)/        # 대시보드 그룹 레이아웃
│   │   │   ├── layout.tsx      # 공통 레이아웃
│   │   │   ├── dashboard/
│   │   │   │   └── page.tsx
│   │   │   ├── products/
│   │   │   │   ├── page.tsx
│   │   │   │   ├── [id]/
│   │   │   │   │   └── page.tsx
│   │   │   │   └── new/
│   │   │   │       └── page.tsx
│   │   │   ├── orders/
│   │   │   ├── users/
│   │   │   ├── sellers/
│   │   │   ├── settlements/
│   │   │   └── settings/
│   │   ├── api/                # API Routes
│   │   │   └── [...route]/
│   │   ├── layout.tsx          # 루트 레이아웃
│   │   └── globals.css
│   ├── components/             # React 컴포넌트
│   │   ├── ui/                 # 기본 UI 컴포넌트 (shadcn/ui)
│   │   │   ├── button.tsx
│   │   │   ├── card.tsx
│   │   │   ├── dialog.tsx
│   │   │   ├── input.tsx
│   │   │   ├── table.tsx
│   │   │   └── ...
│   │   ├── layout/             # 레이아웃 컴포넌트
│   │   │   ├── sidebar.tsx
│   │   │   └── header.tsx
│   │   ├── products/           # 도메인별 컴포넌트
│   │   ├── orders/
│   │   └── providers.tsx       # Context Providers
│   ├── lib/                    # 유틸리티 및 설정
│   │   ├── api-client.ts       # Axios 클라이언트
│   │   ├── api/                # API 함수
│   │   │   ├── products.ts
│   │   │   ├── orders.ts
│   │   │   └── ...
│   │   └── utils.ts
│   ├── hooks/                  # Custom Hooks
│   │   ├── use-toast.ts
│   │   └── ...
│   ├── store/                  # Zustand 스토어
│   │   ├── auth-store.ts
│   │   └── ...
│   └── types/                  # TypeScript 타입
│       └── index.ts
├── public/
├── .env.example
├── next.config.js
├── package.json
├── tailwind.config.ts
└── tsconfig.json
```

### Seller Web

판매자 웹은 관리자 웹과 동일한 구조를 가지지만, 도메인별 페이지와 기능이 다릅니다:

```
frontend/seller-web/
├── src/
│   ├── app/
│   │   ├── (dashboard)/
│   │   │   ├── dashboard/       # 판매자 대시보드
│   │   │   ├── products/        # 내 상품 관리
│   │   │   ├── orders/          # 내 주문 관리
│   │   │   ├── settlements/     # 정산 내역
│   │   │   ├── analytics/       # 판매 통계
│   │   │   └── profile/         # 판매자 프로필
│   │   └── ...
│   └── ...
```

## 핵심 구현

### 1. Next.js 설정 (next.config.js)

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '**.amazonaws.com',
      },
      {
        protocol: 'https',
        hostname: 'cdn.doamarket.com',
      },
    ],
  },
  env: {
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL || 'https://api.doamarket.com',
    NEXT_PUBLIC_CDN_URL: process.env.NEXT_PUBLIC_CDN_URL || 'https://cdn.doamarket.com',
  },
  experimental: {
    serverActions: {
      allowedOrigins: ['localhost:3100', 'admin.doamarket.com'],
    },
  },
};

module.exports = nextConfig;
```

**핵심 기능:**
- 이미지 최적화 (Next/Image)
- 환경 변수 설정
- Server Actions 허용 도메인 설정

### 2. API 클라이언트 (lib/api-client.ts)

```typescript
import axios, { AxiosInstance } from 'axios';

class ApiClient {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: process.env.NEXT_PUBLIC_API_URL,
      timeout: 30000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    this.setupInterceptors();
  }

  private setupInterceptors() {
    // Request interceptor - JWT 토큰 추가
    this.client.interceptors.request.use((config) => {
      const token = localStorage.getItem('accessToken');
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
      return config;
    });

    // Response interceptor - 401 처리 및 토큰 갱신
    this.client.interceptors.response.use(
      (response) => response,
      async (error) => {
        const originalRequest = error.config;

        if (error.response?.status === 401 && !originalRequest._retry) {
          originalRequest._retry = true;

          try {
            const refreshToken = localStorage.getItem('refreshToken');
            const response = await axios.post(`${API_URL}/api/v1/auth/refresh`, {
              refreshToken,
            });

            const { accessToken } = response.data.data;
            localStorage.setItem('accessToken', accessToken);
            originalRequest.headers.Authorization = `Bearer ${accessToken}`;

            return this.client(originalRequest);
          } catch (refreshError) {
            // Refresh 실패 시 로그인 페이지로 리다이렉트
            localStorage.removeItem('accessToken');
            localStorage.removeItem('refreshToken');
            window.location.href = '/login';
          }
        }

        return Promise.reject(error);
      }
    );
  }

  async get<T>(url: string, config?) { ... }
  async post<T>(url: string, data?, config?) { ... }
  async put<T>(url: string, data?, config?) { ... }
  async delete<T>(url: string, config?) { ... }
}

export const apiClient = new ApiClient();
```

**핵심 기능:**
- Axios 인터셉터로 JWT 자동 추가
- 401 에러 시 자동 토큰 갱신
- Refresh 실패 시 로그인 페이지 리다이렉트

### 3. 인증 상태 관리 (store/auth-store.ts)

```typescript
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface AuthState {
  user: User | null;
  accessToken: string | null;
  refreshToken: string | null;
  setAuth: (user: User, accessToken: string, refreshToken: string) => void;
  clearAuth: () => void;
  updateUser: (user: Partial<User>) => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      accessToken: null,
      refreshToken: null,

      setAuth: (user, accessToken, refreshToken) => {
        set({ user, accessToken, refreshToken });
        localStorage.setItem('accessToken', accessToken);
        localStorage.setItem('refreshToken', refreshToken);
      },

      clearAuth: () => {
        set({ user: null, accessToken: null, refreshToken: null });
        localStorage.removeItem('accessToken');
        localStorage.removeItem('refreshToken');
      },

      updateUser: (userData) => {
        set((state) => ({
          user: state.user ? { ...state.user, ...userData } : null,
        }));
      },
    }),
    {
      name: 'auth-storage',
      partialize: (state) => ({ user: state.user }),
    }
  )
);
```

**핵심 기능:**
- Zustand로 전역 인증 상태 관리
- persist 미들웨어로 localStorage에 자동 저장
- 사용자 정보 및 토큰 관리

### 4. API 함수 (lib/api/products.ts)

```typescript
import { apiClient } from '../api-client';
import { ApiResponse, Product } from '@/types';

export interface ProductFilters {
  page?: number;
  limit?: number;
  categoryId?: string;
  status?: string;
  search?: string;
}

export const productsApi = {
  getProducts: async (filters?: ProductFilters): Promise<ApiResponse<Product[]>> => {
    const params = new URLSearchParams();
    if (filters) {
      Object.entries(filters).forEach(([key, value]) => {
        if (value !== undefined) {
          params.append(key, String(value));
        }
      });
    }
    return apiClient.get<ApiResponse<Product[]>>(`/api/v1/products?${params.toString()}`);
  },

  getProduct: async (id: string): Promise<ApiResponse<Product>> => {
    return apiClient.get<ApiResponse<Product>>(`/api/v1/products/${id}`);
  },

  createProduct: async (data: Partial<Product>): Promise<ApiResponse<Product>> => {
    return apiClient.post<ApiResponse<Product>>('/api/v1/products', data);
  },

  updateProduct: async (id: string, data: Partial<Product>): Promise<ApiResponse<Product>> => {
    return apiClient.put<ApiResponse<Product>>(`/api/v1/products/${id}`, data);
  },

  deleteProduct: async (id: string): Promise<ApiResponse<void>> => {
    return apiClient.delete<ApiResponse<void>>(`/api/v1/products/${id}`);
  },
};
```

**핵심 기능:**
- 타입 안전 API 함수
- 쿼리 파라미터 자동 생성
- 일관된 응답 타입

### 5. 로그인 페이지 (app/(auth)/login/page.tsx)

```typescript
'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import { useAuthStore } from '@/store/auth-store';
import { apiClient } from '@/lib/api-client';

const loginSchema = z.object({
  email: z.string().email('올바른 이메일 주소를 입력해주세요'),
  password: z.string().min(6, '비밀번호는 최소 6자 이상이어야 합니다'),
});

type LoginFormData = z.infer<typeof loginSchema>;

export default function LoginPage() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);
  const { setAuth } = useAuthStore();

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  });

  const onSubmit = async (data: LoginFormData) => {
    setIsLoading(true);

    try {
      const response = await apiClient.post('/api/v1/auth/login', data);

      if (response.success) {
        const { user, accessToken, refreshToken } = response.data;

        // Check admin role
        if (user.role !== 'admin') {
          toast({ title: '접근 권한 없음', variant: 'destructive' });
          return;
        }

        setAuth(user, accessToken, refreshToken);
        router.push('/dashboard');
      }
    } catch (error) {
      toast({ title: '로그인 실패', variant: 'destructive' });
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center">
      <Card className="w-full max-w-md">
        <CardHeader>
          <CardTitle>관리자 로그인</CardTitle>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit(onSubmit)}>
            <Input {...register('email')} placeholder="이메일" />
            {errors.email && <p className="text-red-500">{errors.email.message}</p>}

            <Input type="password" {...register('password')} placeholder="비밀번호" />
            {errors.password && <p className="text-red-500">{errors.password.message}</p>}

            <Button type="submit" disabled={isLoading}>
              {isLoading ? '로그인 중...' : '로그인'}
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
```

**핵심 기능:**
- React Hook Form + Zod 검증
- 로그인 후 role 체크
- 에러 핸들링

### 6. 대시보드 레이아웃 (app/(dashboard)/layout.tsx)

```typescript
'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '@/store/auth-store';
import { Sidebar } from '@/components/layout/sidebar';
import { Header } from '@/components/layout/header';

export default function DashboardLayout({ children }) {
  const router = useRouter();
  const { user } = useAuthStore();

  useEffect(() => {
    if (!user) {
      router.push('/login');
    }
  }, [user, router]);

  if (!user) return null;

  return (
    <div className="flex h-screen overflow-hidden">
      <Sidebar />
      <div className="flex flex-1 flex-col overflow-hidden">
        <Header />
        <main className="flex-1 overflow-y-auto bg-gray-50 p-6">
          {children}
        </main>
      </div>
    </div>
  );
}
```

**핵심 기능:**
- 인증 체크 및 리다이렉트
- 공통 레이아웃 (Sidebar + Header)
- Route Groups로 레이아웃 분리

### 7. 상품 목록 페이지 (app/(dashboard)/products/page.tsx)

```typescript
'use client';

import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { productsApi } from '@/lib/api/products';
import { Table, TableBody, TableCell, TableHead, TableRow } from '@/components/ui/table';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';

export default function ProductsPage() {
  const [filters, setFilters] = useState({ page: 1, limit: 20 });

  const { data, isLoading } = useQuery({
    queryKey: ['products', filters],
    queryFn: () => productsApi.getProducts(filters),
  });

  const products = data?.data || [];
  const meta = data?.meta;

  return (
    <div className="space-y-6">
      <div className="flex justify-between">
        <h1 className="text-3xl font-bold">상품 관리</h1>
        <Button>상품 등록</Button>
      </div>

      <Input
        placeholder="상품명 검색..."
        value={filters.search || ''}
        onChange={(e) => setFilters({ ...filters, search: e.target.value, page: 1 })}
      />

      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>상품명</TableHead>
            <TableHead>가격</TableHead>
            <TableHead>재고</TableHead>
            <TableHead>상태</TableHead>
            <TableHead>액션</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {products.map((product) => (
            <TableRow key={product.id}>
              <TableCell>{product.name}</TableCell>
              <TableCell>₩{product.price.toLocaleString()}</TableCell>
              <TableCell>{product.stockQuantity}</TableCell>
              <TableCell><Badge>{product.status}</Badge></TableCell>
              <TableCell>
                <Button variant="ghost">상세</Button>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>

      {/* Pagination */}
      <div className="flex justify-center gap-2">
        <Button
          disabled={filters.page === 1}
          onClick={() => setFilters({ ...filters, page: filters.page - 1 })}
        >
          이전
        </Button>
        <span>{filters.page} / {meta?.totalPages}</span>
        <Button
          disabled={filters.page === meta?.totalPages}
          onClick={() => setFilters({ ...filters, page: filters.page + 1 })}
        >
          다음
        </Button>
      </div>
    </div>
  );
}
```

**핵심 기능:**
- TanStack Query로 서버 상태 관리
- 검색 및 필터링
- 페이지네이션

### 8. Sidebar 컴포넌트 (components/layout/sidebar.tsx)

```typescript
'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';
import { LayoutDashboard, Package, ShoppingCart, Users, Settings } from 'lucide-react';

const navigation = [
  { name: '대시보드', href: '/dashboard', icon: LayoutDashboard },
  { name: '상품 관리', href: '/products', icon: Package },
  { name: '주문 관리', href: '/orders', icon: ShoppingCart },
  { name: '사용자 관리', href: '/users', icon: Users },
  { name: '설정', href: '/settings', icon: Settings },
];

export function Sidebar() {
  const pathname = usePathname();

  return (
    <div className="flex w-64 flex-col border-r bg-white">
      <div className="flex h-16 items-center border-b px-6">
        <h1 className="text-xl font-bold text-primary">DOA Market</h1>
      </div>
      <nav className="flex-1 space-y-1 px-3 py-4">
        {navigation.map((item) => {
          const Icon = item.icon;
          const isActive = pathname === item.href || pathname.startsWith(`${item.href}/`);

          return (
            <Link
              key={item.name}
              href={item.href}
              className={cn(
                'flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium',
                isActive
                  ? 'bg-primary text-white'
                  : 'text-gray-700 hover:bg-gray-100'
              )}
            >
              <Icon className="h-5 w-5" />
              {item.name}
            </Link>
          );
        })}
      </nav>
    </div>
  );
}
```

**핵심 기능:**
- Next.js App Router 네비게이션
- 현재 경로 기반 active 상태
- Lucide React 아이콘

## React Server Components vs Client Components

### Server Components (기본)

```typescript
// app/(dashboard)/products/page.tsx
import { productsApi } from '@/lib/api/products';

// Server Component - 서버에서 데이터 fetch
export default async function ProductsPage() {
  const products = await productsApi.getProducts();

  return (
    <div>
      {products.map(product => (
        <div key={product.id}>{product.name}</div>
      ))}
    </div>
  );
}
```

### Client Components ('use client')

```typescript
// 상태, 이벤트 핸들러, 훅을 사용할 때
'use client';

import { useState } from 'react';

export default function ProductForm() {
  const [name, setName] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    // ...
  };

  return <form onSubmit={handleSubmit}>...</form>;
}
```

**사용 기준:**
- **Server Components**: 데이터 페칭, SEO, 초기 렌더링 성능
- **Client Components**: 상호작용, 상태 관리, 브라우저 API

## 환경 변수

```bash
# .env.local
NEXT_PUBLIC_API_URL=https://api.doamarket.com
NEXT_PUBLIC_CDN_URL=https://cdn.doamarket.com
NEXTAUTH_URL=https://admin.doamarket.com
NEXTAUTH_SECRET=your_secret_here
```

**주의사항:**
- `NEXT_PUBLIC_` 접두사: 브라우저에 노출
- 민감한 정보는 접두사 없이 서버 전용

## 빌드 및 배포

```bash
# 개발 서버
npm run dev

# 프로덕션 빌드
npm run build

# 프로덕션 실행
npm run start

# 타입 체크
npm run type-check
```

## Dockerfile

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

EXPOSE 3100
CMD ["node", "server.js"]
```

## 주요 페이지 목록

### Admin Web

1. **인증**
   - `/login` - 로그인
   - `/forgot-password` - 비밀번호 찾기

2. **대시보드**
   - `/dashboard` - 메인 대시보드

3. **상품 관리**
   - `/products` - 상품 목록
   - `/products/[id]` - 상품 상세
   - `/products/new` - 상품 등록

4. **주문 관리**
   - `/orders` - 주문 목록
   - `/orders/[id]` - 주문 상세

5. **사용자 관리**
   - `/users` - 사용자 목록
   - `/users/[id]` - 사용자 상세

6. **판매자 관리**
   - `/sellers` - 판매자 목록
   - `/sellers/[id]` - 판매자 상세
   - `/sellers/approvals` - 승인 대기

7. **정산 관리**
   - `/settlements` - 정산 목록
   - `/settlements/[id]` - 정산 상세

### Seller Web

1. **대시보드**
   - `/dashboard` - 판매자 대시보드

2. **상품 관리**
   - `/products` - 내 상품 목록
   - `/products/[id]` - 상품 수정
   - `/products/new` - 상품 등록

3. **주문 관리**
   - `/orders` - 내 주문 목록
   - `/orders/[id]` - 주문 처리

4. **정산**
   - `/settlements` - 정산 내역

5. **통계**
   - `/analytics` - 판매 통계

## 핵심 설계 원칙

1. **App Router 활용**
   - Server Components 우선
   - 필요한 경우만 Client Components

2. **타입 안전성**
   - TypeScript strict mode
   - Zod 런타임 검증

3. **성능 최적화**
   - Next/Image 이미지 최적화
   - 코드 스플리팅
   - React Query 캐싱

4. **재사용성**
   - 공통 컴포넌트 (ui/)
   - 도메인별 컴포넌트 분리
   - Custom Hooks

5. **일관성**
   - 통일된 폴더 구조
   - 코딩 컨벤션
   - 에러 처리 패턴

## 다음 단계

다음 문서에서는:
- Flutter 앱 폴더 구조 및 기본 화면 코드
- 이벤트 기반 주문 처리 흐름 구현 예시

를 다룹니다.
