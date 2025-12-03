'use client';

import { useQuery } from '@tanstack/react-query';
import { sellerApi } from '@/lib/api/seller';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { ArrowUp, ArrowDown, Package, ShoppingCart, DollarSign, Clock } from 'lucide-react';

export default function SellerDashboardPage() {
  const { data: stats } = useQuery({
    queryKey: ['seller-dashboard-stats'],
    queryFn: async () => {
      const response = await sellerApi.getDashboardStats();
      return response.data;
    },
  });

  const { data: recentOrders } = useQuery({
    queryKey: ['seller-recent-orders'],
    queryFn: async () => {
      const response = await sellerApi.getMyOrders({ page: 1, limit: 5 });
      return response.data;
    },
  });

  if (!stats) {
    return <div className="p-8">로딩 중...</div>;
  }

  const statCards = [
    {
      title: '총 상품',
      value: stats.totalProducts.toLocaleString(),
      growth: stats.productGrowth,
      icon: Package,
      color: 'text-blue-600',
    },
    {
      title: '총 주문',
      value: stats.totalOrders.toLocaleString(),
      growth: stats.orderGrowth,
      icon: ShoppingCart,
      color: 'text-green-600',
    },
    {
      title: '대기 주문',
      value: stats.pendingOrders.toLocaleString(),
      growth: 0,
      icon: Clock,
      color: 'text-orange-600',
    },
    {
      title: '총 매출',
      value: `₩${stats.totalRevenue.toLocaleString()}`,
      growth: stats.revenueGrowth,
      icon: DollarSign,
      color: 'text-purple-600',
    },
  ];

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold">대시보드</h1>
        <p className="text-gray-500 mt-2">판매 현황을 한눈에 확인하세요</p>
      </div>

      {/* 통계 카드 */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {statCards.map((stat) => {
          const Icon = stat.icon;
          const isPositive = stat.growth >= 0;
          
          return (
            <Card key={stat.title}>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium text-gray-500">
                  {stat.title}
                </CardTitle>
                <Icon className={`h-5 w-5 ${stat.color}`} />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stat.value}</div>
                {stat.growth !== 0 && (
                  <div className="flex items-center text-xs text-gray-500 mt-1">
                    {isPositive ? (
                      <ArrowUp className="h-4 w-4 text-green-600 mr-1" />
                    ) : (
                      <ArrowDown className="h-4 w-4 text-red-600 mr-1" />
                    )}
                    <span className={isPositive ? 'text-green-600' : 'text-red-600'}>
                      {Math.abs(stat.growth)}%
                    </span>
                    <span className="ml-1">지난 달 대비</span>
                  </div>
                )}
              </CardContent>
            </Card>
          );
        })}
      </div>

      {/* 최근 주문 */}
      <Card>
        <CardHeader>
          <CardTitle>최근 주문</CardTitle>
        </CardHeader>
        <CardContent>
          {recentOrders && recentOrders.length > 0 ? (
            <div className="space-y-4">
              {recentOrders.map((order: any) => (
                <div 
                  key={order.id} 
                  className="flex items-center justify-between border-b pb-4 last:border-0"
                >
                  <div>
                    <p className="font-medium">{order.orderNumber}</p>
                    <p className="text-sm text-gray-500">
                      {new Date(order.createdAt).toLocaleString('ko-KR')}
                    </p>
                  </div>
                  <div className="text-right">
                    <p className="font-medium">₩{order.totalAmount.toLocaleString()}</p>
                    <p className="text-sm text-gray-500">{order.status}</p>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center text-gray-500 py-8">
              주문이 없습니다
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
