'use client';

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { sellersApi } from '@/lib/api';
import { Seller } from '@/types';
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
import { Check, X, Ban, Unlock } from 'lucide-react';

export default function SellersPage() {
  const [page, setPage] = useState(1);
  const [filter, setFilter] = useState<string | undefined>(undefined);
  const queryClient = useQueryClient();

  const { data: sellers, isLoading } = useQuery({
    queryKey: ['sellers', page, filter],
    queryFn: async () => {
      const response = await sellersApi.getSellers({
        page,
        limit: 20,
        filters: filter ? { status: filter } : undefined,
      });
      return response;
    },
  });

  const approveMutation = useMutation({
    mutationFn: (sellerId: string) => sellersApi.approveSeller(sellerId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['sellers'] });
    },
  });

  const rejectMutation = useMutation({
    mutationFn: ({ sellerId, reason }: { sellerId: string; reason: string }) =>
      sellersApi.rejectSeller(sellerId, reason),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['sellers'] });
    },
  });

  const suspendMutation = useMutation({
    mutationFn: ({ sellerId, reason }: { sellerId: string; reason: string }) =>
      sellersApi.suspendSeller(sellerId, reason),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['sellers'] });
    },
  });

  const unsuspendMutation = useMutation({
    mutationFn: (sellerId: string) => sellersApi.unsuspendSeller(sellerId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['sellers'] });
    },
  });

  const handleApprove = (sellerId: string) => {
    if (confirm('이 판매자를 승인하시겠습니까?')) {
      approveMutation.mutate(sellerId);
    }
  };

  const handleReject = (sellerId: string) => {
    const reason = prompt('거부 사유를 입력하세요:');
    if (reason) {
      rejectMutation.mutate({ sellerId, reason });
    }
  };

  const handleSuspend = (sellerId: string) => {
    const reason = prompt('정지 사유를 입력하세요:');
    if (reason) {
      suspendMutation.mutate({ sellerId, reason });
    }
  };

  const handleUnsuspend = (sellerId: string) => {
    if (confirm('이 판매자의 정지를 해제하시겠습니까?')) {
      unsuspendMutation.mutate(sellerId);
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'pending':
        return <Badge variant="warning">승인대기</Badge>;
      case 'approved':
        return <Badge variant="success">승인됨</Badge>;
      case 'rejected':
        return <Badge variant="destructive">거부됨</Badge>;
      case 'suspended':
        return <Badge variant="secondary">정지됨</Badge>;
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
          <h1 className="text-3xl font-bold">판매자 관리</h1>
          <p className="text-gray-500 mt-2">판매자 승인 및 관리</p>
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
          승인대기
        </Button>
        <Button
          variant={filter === 'approved' ? 'default' : 'outline'}
          onClick={() => setFilter('approved')}
        >
          승인됨
        </Button>
        <Button
          variant={filter === 'suspended' ? 'default' : 'outline'}
          onClick={() => setFilter('suspended')}
        >
          정지됨
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>판매자 목록</CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>상호명</TableHead>
                <TableHead>사업자번호</TableHead>
                <TableHead>대표자</TableHead>
                <TableHead>이메일</TableHead>
                <TableHead>전화번호</TableHead>
                <TableHead>상태</TableHead>
                <TableHead>신청일</TableHead>
                <TableHead className="text-right">작업</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {sellers?.data?.map((seller: Seller) => (
                <TableRow key={seller.id}>
                  <TableCell className="font-medium">{seller.businessName}</TableCell>
                  <TableCell>{seller.businessNumber}</TableCell>
                  <TableCell>{seller.ownerName}</TableCell>
                  <TableCell>{seller.email}</TableCell>
                  <TableCell>{seller.phone}</TableCell>
                  <TableCell>{getStatusBadge(seller.status)}</TableCell>
                  <TableCell>
                    {new Date(seller.createdAt).toLocaleDateString('ko-KR')}
                  </TableCell>
                  <TableCell className="text-right space-x-2">
                    {seller.status === 'pending' && (
                      <>
                        <Button
                          size="sm"
                          variant="default"
                          onClick={() => handleApprove(seller.id)}
                        >
                          <Check className="h-4 w-4 mr-1" />
                          승인
                        </Button>
                        <Button
                          size="sm"
                          variant="destructive"
                          onClick={() => handleReject(seller.id)}
                        >
                          <X className="h-4 w-4 mr-1" />
                          거부
                        </Button>
                      </>
                    )}
                    {seller.status === 'approved' && (
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => handleSuspend(seller.id)}
                      >
                        <Ban className="h-4 w-4 mr-1" />
                        정지
                      </Button>
                    )}
                    {seller.status === 'suspended' && (
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => handleUnsuspend(seller.id)}
                      >
                        <Unlock className="h-4 w-4 mr-1" />
                        해제
                      </Button>
                    )}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>

          {/* Pagination */}
          {sellers?.meta && (
            <div className="flex items-center justify-between mt-4">
              <div className="text-sm text-gray-500">
                총 {sellers.meta.total}개 중 {(page - 1) * 20 + 1}-
                {Math.min(page * 20, sellers.meta.total)}개 표시
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
                  disabled={page >= sellers.meta.totalPages}
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

