'use client';

import { useState } from 'react';
import {
  Box,
  Chip,
  IconButton,
  Menu,
  MenuItem,
  Stack,
  Typography,
} from '@mui/material';
import { MoreVert, Visibility, LocalShipping, CheckCircle, Cancel } from '@mui/icons-material';
import { PageHeader } from '@/components/common/page-header';
import { DataTable, Column } from '@/components/common/data-table';

// 샘플 데이터
const orders = [
  {
    id: '1',
    orderNumber: 'ORD-2024-001',
    customer: '김철수',
    products: 3,
    totalAmount: 185000,
    status: 'pending',
    paymentMethod: '카드',
    createdAt: '2024-12-07 10:30',
  },
  {
    id: '2',
    orderNumber: 'ORD-2024-002',
    customer: '이영희',
    products: 1,
    totalAmount: 45000,
    status: 'processing',
    paymentMethod: '카드',
    createdAt: '2024-12-07 09:15',
  },
  {
    id: '3',
    orderNumber: 'ORD-2024-003',
    customer: '박민수',
    products: 5,
    totalAmount: 420000,
    status: 'shipping',
    paymentMethod: '계좌이체',
    createdAt: '2024-12-06 18:45',
  },
  {
    id: '4',
    orderNumber: 'ORD-2024-004',
    customer: '정수진',
    products: 2,
    totalAmount: 95000,
    status: 'delivered',
    paymentMethod: '카드',
    createdAt: '2024-12-06 14:20',
  },
  {
    id: '5',
    orderNumber: 'ORD-2024-005',
    customer: '최영수',
    products: 1,
    totalAmount: 15000,
    status: 'cancelled',
    paymentMethod: '무통장입금',
    createdAt: '2024-12-05 11:30',
  },
];

export default function OrdersPage() {
  const [selected, setSelected] = useState<string[]>([]);
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const [currentOrder, setCurrentOrder] = useState<any>(null);

  const handleMenuOpen = (event: React.MouseEvent<HTMLElement>, order: any) => {
    setAnchorEl(event.currentTarget);
    setCurrentOrder(order);
  };

  const handleMenuClose = () => {
    setAnchorEl(null);
    setCurrentOrder(null);
  };

  const columns: Column[] = [
    {
      id: 'orderNumber',
      label: '주문번호',
      minWidth: 150,
      sortable: true,
      format: (value: string) => (
        <Typography variant="subtitle2" sx={{ fontWeight: 600, color: 'primary.main' }}>
          {value}
        </Typography>
      ),
    },
    {
      id: 'customer',
      label: '고객명',
      minWidth: 120,
      sortable: true,
    },
    {
      id: 'products',
      label: '상품수',
      minWidth: 80,
      align: 'center',
      format: (value: number) => `${value}개`,
    },
    {
      id: 'totalAmount',
      label: '주문금액',
      minWidth: 130,
      align: 'right',
      sortable: true,
      format: (value: number) => (
        <Typography variant="subtitle2" sx={{ fontWeight: 600 }}>
          ₩{value.toLocaleString()}
        </Typography>
      ),
    },
    {
      id: 'paymentMethod',
      label: '결제방법',
      minWidth: 100,
      align: 'center',
    },
    {
      id: 'status',
      label: '주문상태',
      minWidth: 120,
      align: 'center',
      format: (value: string) => {
        const statusMap: any = {
          pending: { label: '결제대기', color: 'warning' },
          processing: { label: '처리중', color: 'info' },
          shipping: { label: '배송중', color: 'primary' },
          delivered: { label: '배송완료', color: 'success' },
          cancelled: { label: '취소', color: 'error' },
        };
        const status = statusMap[value] || statusMap.pending;
        return (
          <Chip
            label={status.label}
            color={status.color}
            size="small"
            sx={{ fontWeight: 600, minWidth: 80 }}
          />
        );
      },
    },
    {
      id: 'createdAt',
      label: '주문일시',
      minWidth: 150,
      sortable: true,
    },
  ];

  return (
    <Box>
      <PageHeader
        title="주문 관리"
        subtitle="모든 주문을 확인하고 처리하세요"
        breadcrumbs={[
          { label: '홈', href: '/dashboard' },
          { label: '주문 관리' },
        ]}
      />

      {/* 주문 통계 요약 */}
      <Stack direction="row" spacing={2} sx={{ mb: 3 }}>
        {[
          { label: '전체', count: 248, color: 'default' },
          { label: '결제대기', count: 12, color: 'warning' },
          { label: '처리중', count: 35, color: 'info' },
          { label: '배송중', count: 28, color: 'primary' },
          { label: '완료', count: 168, color: 'success' },
          { label: '취소', count: 5, color: 'error' },
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
        rows={orders}
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
        <MenuItem onClick={handleMenuClose}>
          <LocalShipping fontSize="small" sx={{ mr: 1 }} />
          배송처리
        </MenuItem>
        <MenuItem onClick={handleMenuClose}>
          <CheckCircle fontSize="small" sx={{ mr: 1 }} />
          완료처리
        </MenuItem>
        <MenuItem onClick={handleMenuClose} sx={{ color: 'error.main' }}>
          <Cancel fontSize="small" sx={{ mr: 1 }} />
          주문취소
        </MenuItem>
      </Menu>
    </Box>
  );
}
