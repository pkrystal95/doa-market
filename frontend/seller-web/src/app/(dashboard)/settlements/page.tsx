'use client';

import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { sellerApi } from '@/lib/api/seller';
import { Settlement } from '@/types';
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
import { Eye, Download } from 'lucide-react';

export default function SellerSettlementsPage() {
  const [page, setPage] = useState(1);

  const { data: settlements, isLoading } = useQuery({
    queryKey: ['seller-settlements', page],
    queryFn: async () => {
      const response = await sellerApi.getMySettlements({ page, limit: 20 });
      return response;
    },
  });

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'calculated':
        return <Badge variant="warning">계산됨</Badge>;
      case 'confirmed':
        return <Badge variant="default">확정됨</Badge>;
      case 'paid':
        return <Badge variant="success">지급완료</Badge>;
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
          <h1 className="text-3xl font-bold">정산 관리</h1>
          <p className="text-gray-500 mt-2">판매 정산 내역을 확인합니다</p>
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>정산 목록</CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>정산기간</TableHead>
                <TableHead>총 매출액</TableHead>
                <TableHead>수수료</TableHead>
                <TableHead>배송비</TableHead>
                <TableHead>환불액</TableHead>
                <TableHead>최종 정산액</TableHead>
                <TableHead>상태</TableHead>
                <TableHead>지급일</TableHead>
                <TableHead className="text-right">작업</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {settlements?.data?.map((settlement: Settlement) => (
                <TableRow key={settlement.id}>
                  <TableCell>
                    {new Date(settlement.periodStart).toLocaleDateString('ko-KR')}
                    <br />~{' '}
                    {new Date(settlement.periodEnd).toLocaleDateString('ko-KR')}
                  </TableCell>
                  <TableCell>
                    ₩{settlement.totalSalesAmount.toLocaleString()}
                  </TableCell>
                  <TableCell className="text-red-600">
                    -₩{settlement.commissionAmount.toLocaleString()}
                  </TableCell>
                  <TableCell>
                    ₩{settlement.shippingAmount.toLocaleString()}
                  </TableCell>
                  <TableCell className="text-red-600">
                    -₩{settlement.refundAmount.toLocaleString()}
                  </TableCell>
                  <TableCell className="font-bold text-blue-600">
                    ₩{settlement.finalAmount.toLocaleString()}
                  </TableCell>
                  <TableCell>{getStatusBadge(settlement.status)}</TableCell>
                  <TableCell>
                    {settlement.paidAt
                      ? new Date(settlement.paidAt).toLocaleDateString('ko-KR')
                      : '-'}
                  </TableCell>
                  <TableCell className="text-right space-x-2">
                    <Button size="sm" variant="outline">
                      <Eye className="h-4 w-4 mr-1" />
                      상세
                    </Button>
                    {settlement.status === 'paid' && (
                      <Button size="sm" variant="outline">
                        <Download className="h-4 w-4 mr-1" />
                        정산서
                      </Button>
                    )}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>

          {/* Pagination */}
          {settlements?.meta && (
            <div className="flex items-center justify-between mt-4">
              <div className="text-sm text-gray-500">
                총 {settlements.meta.total}개 중 {(page - 1) * 20 + 1}-
                {Math.min(page * 20, settlements.meta.total)}개 표시
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
                  disabled={page >= settlements.meta.totalPages}
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

