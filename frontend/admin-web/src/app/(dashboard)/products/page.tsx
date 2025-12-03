'use client';

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { productsApi } from '@/lib/api';
import { Product } from '@/types';
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
import { Check, X, Trash2, Eye } from 'lucide-react';
import Link from 'next/link';

export default function ProductsPage() {
  const [page, setPage] = useState(1);
  const [filter, setFilter] = useState<string | undefined>(undefined);
  const queryClient = useQueryClient();

  const { data: products, isLoading } = useQuery({
    queryKey: ['products', page, filter],
    queryFn: async () => {
      const response = await productsApi.getProducts({
        page,
        limit: 20,
        filters: filter ? { approvalStatus: filter } : undefined,
      });
      return response;
    },
  });

  const approveMutation = useMutation({
    mutationFn: (productId: string) => productsApi.approveProduct(productId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
    },
  });

  const rejectMutation = useMutation({
    mutationFn: ({ productId, reason }: { productId: string; reason: string }) =>
      productsApi.rejectProduct(productId, reason),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (productId: string) => productsApi.deleteProduct(productId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
    },
  });

  const handleApprove = (productId: string) => {
    if (confirm('이 상품을 승인하시겠습니까?')) {
      approveMutation.mutate(productId);
    }
  };

  const handleReject = (productId: string) => {
    const reason = prompt('거부 사유를 입력하세요:');
    if (reason) {
      rejectMutation.mutate({ productId, reason });
    }
  };

  const handleDelete = (productId: string) => {
    if (confirm('이 상품을 삭제하시겠습니까?')) {
      deleteMutation.mutate(productId);
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'pending':
        return <Badge variant="warning">승인대기</Badge>;
      case 'approved':
      case 'active':
        return <Badge variant="success">활성</Badge>;
      case 'rejected':
        return <Badge variant="destructive">거부됨</Badge>;
      case 'inactive':
        return <Badge variant="secondary">비활성</Badge>;
      case 'out_of_stock':
        return <Badge variant="secondary">품절</Badge>;
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
          <h1 className="text-3xl font-bold">상품 관리</h1>
          <p className="text-gray-500 mt-2">상품 심사 및 관리</p>
        </div>
        <Link href="/products/categories">
          <Button variant="outline">카테고리 관리</Button>
        </Link>
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
          variant={filter === 'rejected' ? 'default' : 'outline'}
          onClick={() => setFilter('rejected')}
        >
          거부됨
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>상품 목록</CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>이미지</TableHead>
                <TableHead>상품명</TableHead>
                <TableHead>판매자</TableHead>
                <TableHead>카테고리</TableHead>
                <TableHead>가격</TableHead>
                <TableHead>재고</TableHead>
                <TableHead>상태</TableHead>
                <TableHead>등록일</TableHead>
                <TableHead className="text-right">작업</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {products?.data?.map((product: Product) => (
                <TableRow key={product.id}>
                  <TableCell>
                    {product.thumbnail ? (
                      <img
                        src={product.thumbnail}
                        alt={product.name}
                        className="w-12 h-12 object-cover rounded"
                      />
                    ) : (
                      <div className="w-12 h-12 bg-gray-200 rounded flex items-center justify-center">
                        <Eye className="h-5 w-5 text-gray-400" />
                      </div>
                    )}
                  </TableCell>
                  <TableCell className="font-medium">{product.name}</TableCell>
                  <TableCell>{product.seller?.businessName || '-'}</TableCell>
                  <TableCell>{product.category?.name || '-'}</TableCell>
                  <TableCell>₩{product.price.toLocaleString()}</TableCell>
                  <TableCell>{product.stockQuantity}</TableCell>
                  <TableCell>{getStatusBadge(product.status)}</TableCell>
                  <TableCell>
                    {new Date(product.createdAt).toLocaleDateString('ko-KR')}
                  </TableCell>
                  <TableCell className="text-right space-x-2">
                    {product.approvalStatus === 'pending' && (
                      <>
                        <Button
                          size="sm"
                          variant="default"
                          onClick={() => handleApprove(product.id)}
                        >
                          <Check className="h-4 w-4 mr-1" />
                          승인
                        </Button>
                        <Button
                          size="sm"
                          variant="destructive"
                          onClick={() => handleReject(product.id)}
                        >
                          <X className="h-4 w-4 mr-1" />
                          거부
                        </Button>
                      </>
                    )}
                    <Button
                      size="sm"
                      variant="outline"
                      onClick={() => handleDelete(product.id)}
                    >
                      <Trash2 className="h-4 w-4 mr-1" />
                      삭제
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>

          {/* Pagination */}
          {products?.meta && (
            <div className="flex items-center justify-between mt-4">
              <div className="text-sm text-gray-500">
                총 {products.meta.total}개 중 {(page - 1) * 20 + 1}-
                {Math.min(page * 20, products.meta.total)}개 표시
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
                  disabled={page >= products.meta.totalPages}
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
