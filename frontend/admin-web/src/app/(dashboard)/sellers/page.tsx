'use client';

import { useState } from 'react';
import {
  Box,
  Button,
  Chip,
  IconButton,
  Menu,
  MenuItem,
  Avatar,
  Stack,
  Typography,
} from '@mui/material';
import { Add, MoreVert, CheckCircle, Block, Visibility, Store } from '@mui/icons-material';
import { PageHeader } from '@/components/common/page-header';
import { DataTable, Column } from '@/components/common/data-table';

// 샘플 데이터
const sellers = [
  {
    id: '1',
    storeName: '테크샵',
    ownerName: '김판매',
    email: 'seller1@doamarket.com',
    phone: '010-1111-2222',
    status: 'active',
    products: 124,
    totalSales: 45000000,
    commission: 2250000,
    rating: 4.8,
    createdAt: '2023-10-15',
  },
  {
    id: '2',
    storeName: '패션몰',
    ownerName: '이상인',
    email: 'seller2@doamarket.com',
    phone: '010-2222-3333',
    status: 'active',
    products: 89,
    totalSales: 32000000,
    commission: 1600000,
    rating: 4.6,
    createdAt: '2023-11-20',
  },
  {
    id: '3',
    storeName: '푸드마켓',
    ownerName: '박식품',
    email: 'seller3@doamarket.com',
    phone: '010-3333-4444',
    status: 'pending',
    products: 45,
    totalSales: 0,
    commission: 0,
    rating: 0,
    createdAt: '2024-12-01',
  },
  {
    id: '4',
    storeName: '북스토어',
    ownerName: '정도서',
    email: 'seller4@doamarket.com',
    phone: '010-4444-5555',
    status: 'suspended',
    products: 156,
    totalSales: 28000000,
    commission: 1400000,
    rating: 3.9,
    createdAt: '2023-09-10',
  },
];

export default function SellersPage() {
  const [selected, setSelected] = useState<string[]>([]);
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const [currentSeller, setCurrentSeller] = useState<any>(null);

  const handleMenuOpen = (event: React.MouseEvent<HTMLElement>, seller: any) => {
    setAnchorEl(event.currentTarget);
    setCurrentSeller(seller);
  };

  const handleMenuClose = () => {
    setAnchorEl(null);
    setCurrentSeller(null);
  };

  const columns: Column[] = [
    {
      id: 'storeName',
      label: '스토어',
      minWidth: 200,
      sortable: true,
      format: (value: string, row: any) => (
        <Stack direction="row" alignItems="center" spacing={2}>
          <Avatar sx={{ bgcolor: 'primary.main' }}>
            <Store />
          </Avatar>
          <Box>
            <Typography variant="subtitle2" sx={{ fontWeight: 600 }}>
              {value}
            </Typography>
            <Typography variant="caption" color="text.secondary">
              {row.ownerName}
            </Typography>
          </Box>
        </Stack>
      ),
    },
    {
      id: 'email',
      label: '이메일',
      minWidth: 180,
    },
    {
      id: 'phone',
      label: '연락처',
      minWidth: 130,
    },
    {
      id: 'products',
      label: '상품수',
      minWidth: 80,
      align: 'center',
      sortable: true,
      format: (value: number) => `${value}개`,
    },
    {
      id: 'totalSales',
      label: '총 매출',
      minWidth: 130,
      align: 'right',
      sortable: true,
      format: (value: number) => `₩${value.toLocaleString()}`,
    },
    {
      id: 'commission',
      label: '수수료',
      minWidth: 120,
      align: 'right',
      sortable: true,
      format: (value: number) => `₩${value.toLocaleString()}`,
    },
    {
      id: 'rating',
      label: '평점',
      minWidth: 80,
      align: 'center',
      sortable: true,
      format: (value: number) => value > 0 ? `⭐ ${value}` : '-',
    },
    {
      id: 'status',
      label: '상태',
      minWidth: 100,
      align: 'center',
      format: (value: string) => {
        const statusMap: any = {
          active: { label: '활성', color: 'success' },
          pending: { label: '승인대기', color: 'warning' },
          suspended: { label: '정지', color: 'error' },
        };
        const status = statusMap[value] || statusMap.active;
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
      label: '가입일',
      minWidth: 120,
      sortable: true,
    },
  ];

  return (
    <Box>
      <PageHeader
        title="판매자 관리"
        subtitle="입점 판매자를 관리하고 승인하세요"
        breadcrumbs={[
          { label: '홈', href: '/dashboard' },
          { label: '판매자 관리' },
        ]}
        action={{
          label: '판매자 추가',
          onClick: () => console.log('Add seller'),
          icon: <Add />,
        }}
      />

      {/* 판매자 통계 */}
      <Stack direction="row" spacing={2} sx={{ mb: 3 }}>
        {[
          { label: '전체', count: 148, color: 'default' },
          { label: '활성', count: 135, color: 'success' },
          { label: '승인대기', count: 8, color: 'warning' },
          { label: '정지', count: 5, color: 'error' },
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
        rows={sellers}
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
        {currentSeller?.status === 'pending' && (
          <MenuItem onClick={handleMenuClose}>
            <CheckCircle fontSize="small" sx={{ mr: 1 }} />
            승인
          </MenuItem>
        )}
        <MenuItem onClick={handleMenuClose} sx={{ color: 'error.main' }}>
          <Block fontSize="small" sx={{ mr: 1 }} />
          정지
        </MenuItem>
      </Menu>
    </Box>
  );
}
