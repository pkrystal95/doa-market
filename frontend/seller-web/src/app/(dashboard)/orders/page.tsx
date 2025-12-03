'use client';

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tantml:react-query';
import { sellerApi } from '@/lib/api/seller';
import { Order } from '@/types';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { Eye, Package } from 'lucide-react';
import Link from 'next/link';

export default function SellerOrdersPage() {
  const [page, setPage] = useState(1);
  const [filter, setFilter] = useState<string | undefined>(undefined);
  const queryClient = useQueryClient();

  const { data: orders, isLoading } = useQuery({
    queryKey: ['seller-orders', page, filter],
    queryFn: async () => {
      const response = await sellerApi.getMyOrders({
        page,
        limit: 20,
        filters: filter ? { status: filter } : undefined,
      });
      return response;
    },
  });

  const updateStatusMutation = useMutation({
    mutationFn: ({ orderId, status }: { orderId: string; status: string }) =>
      sellerApi.updateOrderStatus(orderId, status),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['seller-orders'] });
    },
  });

  const handleUpdateStatus = (orderId: string, status: string) => {
    if (confirm(`주문 상태를 "${status}"(으)로 변경하시겠습니까?`)) {
      updateStatusMutation.mutate({ orderId, status });
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'pending':
        return <Badge variant="warning">대기중</Badge>;
      case 'confirmed':
        return <Badge variant="default">주문확인</Badge>;
      case 'processing':
        return <Badge variant="default">처리중</Badge>;
      case 'shipped':
        return <Badge variant="default">배송중</Badge>;
      case 'delivered':
        return <Badge variant="success">배송완료</Badge>;
      case 'cancelled':
        return <Badge variant="destructive">취소됨</Badge>;
      default:
        return <Badge>{status}</Badge>;
    }
  };

  if (isLoading) {
    return <div className="p-8">로딩 중...</div>;
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">주문 관리</h1>
          <p className="text-gray-500 mt-2">내 상품 주문을 관리합니다</p>
        </div>
      </div>

      {/* 필터 */}
      <div className="flex space-x-2">
        <Button
          variant={filter === undefined ? 'default' : 'outline'}
          onClick={() => setFilter(undefined)}
        >
          전체
        </Button>
        <Button
          variant={filter === 'pending' ? 'default' : 'outline'}
          onClick={() => setFilter('pending')}
        >
          대기중
        </Button>
        <Button
          variant={filter === 'processing' ? 'default' : 'outline'}
          onClick={() => setFilter('processing')}
        >
          처리중
        </Button>
        <Button
          variant={filter === 'shipped' ? 'default' : 'outline'}
          onClick={() => setFilter('shipped')}
        >
          배송중
        </Button>
        <Button
          variant={filter === 'delivered' ? 'default' : 'outline'}
          onClick={() => setFilter('delivered')}
        >
          배송완료
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>주문 목록</CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>주문번호</TableHead>
                <TableHead>고객명</TableHead>
                <TableHead>상품수</TableHead>
                <TableHead>총금액</TableHead>
                <TableHead>주문상태</TableHead>
                <TableHead>주문일시</TableHead>
                <TableHead className="text-right">작업</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {orders?.data?.map((order: Order) => (
                <TableRow key={order.id}>
                  <TableCell className="font-medium">{order.orderNumber}</TableCell>
                  <TableCell>
                    {order.user?.name || order.userId}
                    <br />
                    <span className="text-sm text-gray-500">
                      {order.user?.email}
                    </span>
                  </TableCell>
                  <TableCell>{order.items.length}개</TableCell>
                  <TableCell className="font-medium">
                    ₩{order.totalAmount.toLocaleString()}
                  </TableCell>
                  <TableCell>{getStatusBadge(order.status)}</TableCell>
                  <TableCell>
                    {new Date(order.createdAt).toLocaleString('ko-KR')}
                  </TableCell>
                  <TableCell className="text-right space-x-2">
                    <Link href={`/orders/${order.id}`}>
                      <Button size="sm" variant="outline">
                        <Eye className="h-4 w-4 mr-1" />
                        상세
                      </Button>
                    </Link>
                    {order.status === 'confirmed' && (
                      <Button
                        size="sm"
                        variant="default"
                        onClick={() => handleUpdateStatus(order.id, 'processing')}
                      >
                        <Package className="h-4 w-4 mr-1" />
                        처리중으로 변경
                      </Button>
                    )}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>

          {/* Pagination */}
          {orders?.meta && (
            <div className="flex items-center justify-between mt-4">
              <div className="text-sm text-gray-500">
                총 {orders.meta.total}개 중 {(page - 1) * 20 + 1}-
                {Math.min(page * 20, orders.meta.total)}개 표시
              </div>
              <div className="flex space-x-2">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setPage(page - 1)}
                  disabled={page === 1}
                >
                  이전
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setPage(page + 1)}
                  disabled={page >= orders.meta.totalPages}
                >
                  다음
                </Button>
              </div>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}

