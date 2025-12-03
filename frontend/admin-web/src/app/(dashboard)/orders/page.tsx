'use client';

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { ordersApi } from '@/lib/api';
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
import { Eye, XCircle } from 'lucide-react';
import Link from 'next/link';

export default function OrdersPage() {
  const [page, setPage] = useState(1);
  const [filter, setFilter] = useState<string | undefined>(undefined);
  const queryClient = useQueryClient();

  const { data: orders, isLoading } = useQuery({
    queryKey: ['orders', page, filter],
    queryFn: async () => {
      const response = await ordersApi.getOrders({
        page,
        limit: 20,
        filters: filter ? { status: filter } : undefined,
      });
      return response;
    },
  });

  const cancelMutation = useMutation({
    mutationFn: ({ orderId, reason }: { orderId: string; reason: string }) =>
      ordersApi.cancelOrder(orderId, reason),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['orders'] });
    },
  });

  const handleCancel = (orderId: string) => {
    const reason = prompt('취소 사유를 입력하세요:');
    if (reason) {
      cancelMutation.mutate({ orderId, reason });
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
      case 'refunded':
        return <Badge variant="secondary">환불됨</Badge>;
      default:
        return <Badge>{status}</Badge>;
    }
  };

  const getPaymentStatusBadge = (status: string) => {
    switch (status) {
      case 'pending':
        return <Badge variant="warning">결제대기</Badge>;
      case 'completed':
        return <Badge variant="success">결제완료</Badge>;
      case 'failed':
        return <Badge variant="destructive">결제실패</Badge>;
      case 'cancelled':
        return <Badge variant="secondary">결제취소</Badge>;
      case 'refunded':
        return <Badge variant="secondary">환불완료</Badge>;
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
          <p className="text-gray-500 mt-2">전체 주문을 관리합니다</p>
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
        <Button
          variant={filter === 'cancelled' ? 'default' : 'outline'}
          onClick={() => setFilter('cancelled')}
        >
          취소됨
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
                <TableHead>사용자</TableHead>
                <TableHead>판매자</TableHead>
                <TableHead>상품수</TableHead>
                <TableHead>총금액</TableHead>
                <TableHead>결제상태</TableHead>
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
                  <TableCell>{order.seller?.businessName || '-'}</TableCell>
                  <TableCell>{order.items.length}개</TableCell>
                  <TableCell className="font-medium">
                    ₩{order.totalAmount.toLocaleString()}
                  </TableCell>
                  <TableCell>{getPaymentStatusBadge(order.paymentStatus)}</TableCell>
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
                    {order.status !== 'cancelled' && order.status !== 'delivered' && (
                      <Button
                        size="sm"
                        variant="destructive"
                        onClick={() => handleCancel(order.id)}
                      >
                        <XCircle className="h-4 w-4 mr-1" />
                        취소
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

