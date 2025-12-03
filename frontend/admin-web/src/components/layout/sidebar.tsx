'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';
import {
  LayoutDashboard,
  Package,
  ShoppingCart,
  Users,
  Store,
  Settings,
  DollarSign,
  BarChart3,
  Bell,
  MessageSquare,
  Tag,
  Star,
} from 'lucide-react';

const navigation = [
  { name: '대시보드', href: '/dashboard', icon: LayoutDashboard },
  { name: '사용자 관리', href: '/users', icon: Users },
  { name: '판매자 관리', href: '/sellers', icon: Store },
  { name: '상품 관리', href: '/products', icon: Package },
  { name: '주문 관리', href: '/orders', icon: ShoppingCart },
  { name: '정산 관리', href: '/settlements', icon: DollarSign },
  { name: '리뷰 관리', href: '/reviews', icon: Star },
  { name: '쿠폰 관리', href: '/coupons', icon: Tag },
  { name: '공지사항', href: '/notices', icon: Bell },
  { name: '통계', href: '/analytics', icon: BarChart3 },
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
                'flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors',
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
