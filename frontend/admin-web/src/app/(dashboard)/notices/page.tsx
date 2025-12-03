'use client';

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { noticesApi } from '@/lib/api';
import { Notice } from '@/types';
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
import { Plus, Send, Edit, Trash2 } from 'lucide-react';

export default function NoticesPage() {
  const [page, setPage] = useState(1);
  const queryClient = useQueryClient();

  const { data: notices, isLoading } = useQuery({
    queryKey: ['notices', page],
    queryFn: async () => {
      const response = await noticesApi.getNotices({ page, limit: 20 });
      return response;
    },
  });

  const publishMutation = useMutation({
    mutationFn: (noticeId: string) => noticesApi.publishNotice(noticeId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notices'] });
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (noticeId: string) => noticesApi.deleteNotice(noticeId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notices'] });
    },
  });

  const handlePublish = (noticeId: string) => {
    if (confirm('이 공지사항을 발행하시겠습니까?')) {
      publishMutation.mutate(noticeId);
    }
  };

  const handleDelete = (noticeId: string) => {
    if (confirm('이 공지사항을 삭제하시겠습니까?')) {
      deleteMutation.mutate(noticeId);
    }
  };

  const getTypeBadge = (type: string) => {
    switch (type) {
      case 'general':
        return <Badge variant="default">일반</Badge>;
      case 'maintenance':
        return <Badge variant="warning">점검</Badge>;
      case 'urgent':
        return <Badge variant="destructive">긴급</Badge>;
      default:
        return <Badge>{type}</Badge>;
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'draft':
        return <Badge variant="secondary">임시저장</Badge>;
      case 'published':
        return <Badge variant="success">발행됨</Badge>;
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
          <h1 className="text-3xl font-bold">공지사항 관리</h1>
          <p className="text-gray-500 mt-2">시스템 공지사항을 관리합니다</p>
        </div>
        <Button>
          <Plus className="h-4 w-4 mr-2" />
          공지사항 작성
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>공지사항 목록</CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>제목</TableHead>
                <TableHead>유형</TableHead>
                <TableHead>상태</TableHead>
                <TableHead>발행일</TableHead>
                <TableHead>작성일</TableHead>
                <TableHead className="text-right">작업</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {notices?.data?.map((notice: Notice) => (
                <TableRow key={notice.id}>
                  <TableCell className="font-medium">{notice.title}</TableCell>
                  <TableCell>{getTypeBadge(notice.type)}</TableCell>
                  <TableCell>{getStatusBadge(notice.status)}</TableCell>
                  <TableCell>
                    {notice.publishedAt
                      ? new Date(notice.publishedAt).toLocaleDateString('ko-KR')
                      : '-'}
                  </TableCell>
                  <TableCell>
                    {new Date(notice.createdAt).toLocaleDateString('ko-KR')}
                  </TableCell>
                  <TableCell className="text-right space-x-2">
                    {notice.status === 'draft' && (
                      <Button
                        size="sm"
                        variant="default"
                        onClick={() => handlePublish(notice.id)}
                      >
                        <Send className="h-4 w-4 mr-1" />
                        발행
                      </Button>
                    )}
                    <Button size="sm" variant="outline">
                      <Edit className="h-4 w-4 mr-1" />
                      수정
                    </Button>
                    <Button
                      size="sm"
                      variant="destructive"
                      onClick={() => handleDelete(notice.id)}
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
          {notices?.meta && (
            <div className="flex items-center justify-between mt-4">
              <div className="text-sm text-gray-500">
                총 {notices.meta.total}개 중 {(page - 1) * 20 + 1}-
                {Math.min(page * 20, notices.meta.total)}개 표시
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
                  disabled={page >= notices.meta.totalPages}
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

