'use client';

import { useState } from 'react';
import {
  Box,
  Button,
  Chip,
  IconButton,
  Menu,
  MenuItem,
  Stack,
  Typography,
} from '@mui/material';
import { Add, MoreVert, Edit, Delete, Pause, PlayArrow } from '@mui/icons-material';
import { PageHeader } from '@/components/common/page-header';
import { DataTable, Column } from '@/components/common/data-table';

// 샘플 데이터
const coupons = [
  {
    id: '1',
    code: 'WELCOME2024',
    name: '신규회원 환영 쿠폰',
    discountType: 'percent',
    discountValue: 10,
    minAmount: 50000,
    maxDiscount: 10000,
    usageLimit: 1000,
    usageCount: 487,
    status: 'active',
    startDate: '2024-01-01',
    endDate: '2024-12-31',
  },
  {
    id: '2',
    code: 'SUMMER50',
    name: '여름 특가 쿠폰',
    discountType: 'fixed',
    discountValue: 5000,
    minAmount: 30000,
    maxDiscount: 5000,
    usageLimit: 500,
    usageCount: 325,
    status: 'active',
    startDate: '2024-06-01',
    endDate: '2024-08-31',
  },
  {
    id: '3',
    code: 'VIP2024',
    name: 'VIP 전용 쿠폰',
    discountType: 'percent',
    discountValue: 20,
    minAmount: 100000,
    maxDiscount: 50000,
    usageLimit: 100,
    usageCount: 89,
    status: 'active',
    startDate: '2024-01-01',
    endDate: '2024-12-31',
  },
  {
    id: '4',
    code: 'EXPIRED2023',
    name: '만료된 쿠폰',
    discountType: 'percent',
    discountValue: 15,
    minAmount: 40000,
    maxDiscount: 15000,
    usageLimit: 200,
    usageCount: 200,
    status: 'expired',
    startDate: '2023-01-01',
    endDate: '2023-12-31',
  },
];

export default function CouponsPage() {
  const [selected, setSelected] = useState<string[]>([]);
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const [currentCoupon, setCurrentCoupon] = useState<any>(null);

  const handleMenuOpen = (event: React.MouseEvent<HTMLElement>, coupon: any) => {
    setAnchorEl(event.currentTarget);
    setCurrentCoupon(coupon);
  };

  const handleMenuClose = () => {
    setAnchorEl(null);
    setCurrentCoupon(null);
  };

  const columns: Column[] = [
    {
      id: 'code',
      label: '쿠폰 코드',
      minWidth: 150,
      sortable: true,
      format: (value: string) => (
        <Typography
          variant="subtitle2"
          sx={{
            fontWeight: 700,
            fontFamily: 'monospace',
            color: 'primary.main',
            bgcolor: (theme) => theme.palette.primary.lighter,
            px: 1,
            py: 0.5,
            borderRadius: 1,
            display: 'inline-block',
          }}
        >
          {value}
        </Typography>
      ),
    },
    {
      id: 'name',
      label: '쿠폰명',
      minWidth: 200,
      sortable: true,
    },
    {
      id: 'discountValue',
      label: '할인',
      minWidth: 120,
      align: 'center',
      format: (value: number, row: any) => (
        <Typography variant="subtitle2" sx={{ fontWeight: 600, color: 'error.main' }}>
          {row.discountType === 'percent' ? `${value}%` : `₩${value.toLocaleString()}`}
        </Typography>
      ),
    },
    {
      id: 'minAmount',
      label: '최소 금액',
      minWidth: 120,
      align: 'right',
      format: (value: number) => `₩${value.toLocaleString()}`,
    },
    {
      id: 'usageCount',
      label: '사용 현황',
      minWidth: 150,
      align: 'center',
      format: (value: number, row: any) => (
        <Stack alignItems="center" spacing={0.5}>
          <Typography variant="body2">
            {value} / {row.usageLimit}
          </Typography>
          <Box
            sx={{
              width: '100%',
              height: 4,
              bgcolor: 'grey.200',
              borderRadius: 2,
              overflow: 'hidden',
            }}
          >
            <Box
              sx={{
                width: `${(value / row.usageLimit) * 100}%`,
                height: '100%',
                bgcolor: value >= row.usageLimit ? 'error.main' : 'primary.main',
              }}
            />
          </Box>
        </Stack>
      ),
    },
    {
      id: 'status',
      label: '상태',
      minWidth: 100,
      align: 'center',
      format: (value: string) => {
        const statusMap: any = {
          active: { label: '활성', color: 'success' },
          paused: { label: '일시정지', color: 'warning' },
          expired: { label: '만료', color: 'default' },
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
      id: 'endDate',
      label: '만료일',
      minWidth: 120,
      sortable: true,
    },
  ];

  return (
    <Box>
      <PageHeader
        title="쿠폰 관리"
        subtitle="할인 쿠폰을 생성하고 관리하세요"
        breadcrumbs={[
          { label: '홈', href: '/dashboard' },
          { label: '쿠폰 관리' },
        ]}
        action={{
          label: '쿠폰 생성',
          onClick: () => console.log('Create coupon'),
          icon: <Add />,
        }}
      />

      {/* 쿠폰 통계 */}
      <Stack direction="row" spacing={2} sx={{ mb: 3 }}>
        {[
          { label: '전체 쿠폰', count: 48, color: 'default' },
          { label: '활성', count: 35, color: 'success' },
          { label: '일시정지', count: 5, color: 'warning' },
          { label: '만료', count: 8, color: 'default' },
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
        rows={coupons}
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
          <Edit fontSize="small" sx={{ mr: 1 }} />
          수정
        </MenuItem>
        {currentCoupon?.status === 'active' ? (
          <MenuItem onClick={handleMenuClose}>
            <Pause fontSize="small" sx={{ mr: 1 }} />
            일시정지
          </MenuItem>
        ) : (
          <MenuItem onClick={handleMenuClose}>
            <PlayArrow fontSize="small" sx={{ mr: 1 }} />
            활성화
          </MenuItem>
        )}
        <MenuItem onClick={handleMenuClose} sx={{ color: 'error.main' }}>
          <Delete fontSize="small" sx={{ mr: 1 }} />
          삭제
        </MenuItem>
      </Menu>
    </Box>
  );
}

