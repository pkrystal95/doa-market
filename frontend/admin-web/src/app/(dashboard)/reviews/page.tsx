'use client';

import { useState } from 'react';
import {
  Box,
  Chip,
  IconButton,
  Menu,
  MenuItem,
  Avatar,
  Stack,
  Typography,
  Rating,
} from '@mui/material';
import { MoreVert, Visibility, Delete, CheckCircle, Report } from '@mui/icons-material';
import { PageHeader } from '@/components/common/page-header';
import { DataTable, Column } from '@/components/common/data-table';

// 샘플 데이터
const reviews = [
  {
    id: '1',
    productName: '무선 마우스',
    userName: '김철수',
    rating: 5,
    content: '정말 좋은 제품입니다. 사용감이 뛰어나요!',
    images: 2,
    helpful: 15,
    status: 'approved',
    createdAt: '2024-12-05 14:30',
  },
  {
    id: '2',
    productName: '기계식 키보드',
    userName: '이영희',
    rating: 4,
    content: '타건감은 좋은데 소음이 조금 있어요.',
    images: 1,
    helpful: 8,
    status: 'approved',
    createdAt: '2024-12-05 10:15',
  },
  {
    id: '3',
    productName: 'USB 케이블',
    userName: '박민수',
    rating: 1,
    content: '불량품입니다. 환불 요청합니다.',
    images: 3,
    helpful: 2,
    status: 'reported',
    createdAt: '2024-12-04 18:45',
  },
  {
    id: '4',
    productName: '노트북 스탠드',
    userName: '정수진',
    rating: 5,
    content: '가격 대비 훌륭합니다!',
    images: 0,
    helpful: 23,
    status: 'pending',
    createdAt: '2024-12-04 09:20',
  },
];

export default function ReviewsPage() {
  const [selected, setSelected] = useState<string[]>([]);
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const [currentReview, setCurrentReview] = useState<any>(null);

  const handleMenuOpen = (event: React.MouseEvent<HTMLElement>, review: any) => {
    setAnchorEl(event.currentTarget);
    setCurrentReview(review);
  };

  const handleMenuClose = () => {
    setAnchorEl(null);
    setCurrentReview(null);
  };

  const columns: Column[] = [
    {
      id: 'productName',
      label: '상품',
      minWidth: 200,
      sortable: true,
    },
    {
      id: 'userName',
      label: '작성자',
      minWidth: 120,
      format: (value: string) => (
        <Stack direction="row" alignItems="center" spacing={1}>
          <Avatar sx={{ width: 32, height: 32, bgcolor: 'primary.main', fontSize: 14 }}>
            {value[0]}
          </Avatar>
          <Typography variant="body2">{value}</Typography>
        </Stack>
      ),
    },
    {
      id: 'rating',
      label: '평점',
      minWidth: 150,
      align: 'center',
      sortable: true,
      format: (value: number) => (
        <Rating value={value} readOnly size="small" />
      ),
    },
    {
      id: 'content',
      label: '리뷰 내용',
      minWidth: 300,
      format: (value: string) => (
        <Typography
          variant="body2"
          sx={{
            overflow: 'hidden',
            textOverflow: 'ellipsis',
            whiteSpace: 'nowrap',
            maxWidth: 280,
          }}
        >
          {value}
        </Typography>
      ),
    },
    {
      id: 'images',
      label: '사진',
      minWidth: 60,
      align: 'center',
      format: (value: number) => value > 0 ? `📷 ${value}` : '-',
    },
    {
      id: 'helpful',
      label: '도움됨',
      minWidth: 80,
      align: 'center',
      sortable: true,
      format: (value: number) => `👍 ${value}`,
    },
    {
      id: 'status',
      label: '상태',
      minWidth: 100,
      align: 'center',
      format: (value: string) => {
        const statusMap: any = {
          approved: { label: '승인', color: 'success' },
          pending: { label: '대기', color: 'warning' },
          reported: { label: '신고됨', color: 'error' },
          deleted: { label: '삭제', color: 'default' },
        };
        const status = statusMap[value] || statusMap.pending;
        return (
          <Chip
            label={status.label}
            color={status.color}
            size="small"
            sx={{ fontWeight: 600 }}
          />
        );
      },
    },
    {
      id: 'createdAt',
      label: '작성일',
      minWidth: 140,
      sortable: true,
    },
  ];

  return (
    <Box>
      <PageHeader
        title="리뷰 관리"
        subtitle="상품 리뷰를 관리하고 모니터링하세요"
        breadcrumbs={[
          { label: '홈', href: '/dashboard' },
          { label: '리뷰 관리' },
        ]}
      />

      {/* 리뷰 통계 */}
      <Stack direction="row" spacing={2} sx={{ mb: 3 }}>
        {[
          { label: '전체 리뷰', count: 1248, color: 'default' },
          { label: '승인', count: 1180, color: 'success' },
          { label: '대기', count: 52, color: 'warning' },
          { label: '신고', count: 16, color: 'error' },
        ].map((stat) => (
          <Box
            key={stat.label}
            sx={{
              flex: 1,
              p: 2,
              bgcolor: 'background.paper',
              borderRadius: 2,
              border: (theme) => `1px solid ${theme.palette.divider}`,
            }}
          >
            <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5 }}>
              {stat.label}
            </Typography>
            <Typography variant="h5" sx={{ fontWeight: 700 }}>
              {stat.count}
            </Typography>
          </Box>
        ))}
      </Stack>

      <DataTable
        columns={columns}
        rows={reviews}
        selectable
        selected={selected}
        onSelectionChange={setSelected}
        onRowClick={(row) => console.log('Row clicked:', row)}
        actions={(row) => (
          <IconButton
            size="small"
            onClick={(e) => {
              e.stopPropagation();
              handleMenuOpen(e, row);
            }}
          >
            <MoreVert />
          </IconButton>
        )}
      />

      {/* Action Menu */}
      <Menu
        anchorEl={anchorEl}
        open={Boolean(anchorEl)}
        onClose={handleMenuClose}
      >
        <MenuItem onClick={handleMenuClose}>
          <Visibility fontSize="small" sx={{ mr: 1 }} />
          상세보기
        </MenuItem>
        {currentReview?.status === 'pending' && (
          <MenuItem onClick={handleMenuClose}>
            <CheckCircle fontSize="small" sx={{ mr: 1 }} />
            승인
          </MenuItem>
        )}
        <MenuItem onClick={handleMenuClose} sx={{ color: 'warning.main' }}>
          <Report fontSize="small" sx={{ mr: 1 }} />
          신고 처리
        </MenuItem>
        <MenuItem onClick={handleMenuClose} sx={{ color: 'error.main' }}>
          <Delete fontSize="small" sx={{ mr: 1 }} />
          삭제
        </MenuItem>
      </Menu>
    </Box>
  );
}

