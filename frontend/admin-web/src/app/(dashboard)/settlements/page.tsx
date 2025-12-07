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
import { MoreVert, CheckCircle, Receipt, Download } from '@mui/icons-material';
import { PageHeader } from '@/components/common/page-header';
import { DataTable, Column } from '@/components/common/data-table';

// 샘플 데이터
const settlements = [
  {
    id: '1',
    settlementId: 'SET-2024-12-001',
    seller: '테크샵',
    period: '2024.11.01 ~ 2024.11.30',
    totalSales: 12450000,
    commission: 622500,
    amount: 11827500,
    status: 'pending',
    createdAt: '2024-12-01',
  },
  {
    id: '2',
    settlementId: 'SET-2024-12-002',
    seller: '패션몰',
    period: '2024.11.01 ~ 2024.11.30',
    totalSales: 8900000,
    commission: 445000,
    amount: 8455000,
    status: 'completed',
    createdAt: '2024-12-01',
    paidAt: '2024-12-05',
  },
  {
    id: '3',
    settlementId: 'SET-2024-11-001',
    seller: '테크샵',
    period: '2024.10.01 ~ 2024.10.31',
    totalSales: 10200000,
    commission: 510000,
    amount: 9690000,
    status: 'completed',
    createdAt: '2024-11-01',
    paidAt: '2024-11-05',
  },
  {
    id: '4',
    settlementId: 'SET-2024-11-002',
    seller: '북스토어',
    period: '2024.10.01 ~ 2024.10.31',
    totalSales: 5600000,
    commission: 280000,
    amount: 5320000,
    status: 'rejected',
    createdAt: '2024-11-01',
  },
];

export default function SettlementsPage() {
  const [selected, setSelected] = useState<string[]>([]);
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const [currentSettlement, setCurrentSettlement] = useState<any>(null);

  const handleMenuOpen = (event: React.MouseEvent<HTMLElement>, settlement: any) => {
    setAnchorEl(event.currentTarget);
    setCurrentSettlement(settlement);
  };

  const handleMenuClose = () => {
    setAnchorEl(null);
    setCurrentSettlement(null);
  };

  const columns: Column[] = [
    {
      id: 'settlementId',
      label: '정산 ID',
      minWidth: 150,
      sortable: true,
      format: (value: string) => (
        <Typography variant="subtitle2" sx={{ fontWeight: 600, color: 'primary.main' }}>
          {value}
        </Typography>
      ),
    },
    {
      id: 'seller',
      label: '판매자',
      minWidth: 120,
      sortable: true,
    },
    {
      id: 'period',
      label: '정산 기간',
      minWidth: 200,
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
      label: '수수료 (5%)',
      minWidth: 130,
      align: 'right',
      sortable: true,
      format: (value: number) => (
        <Typography variant="body2" color="error.main" sx={{ fontWeight: 600 }}>
          -₩{value.toLocaleString()}
        </Typography>
      ),
    },
    {
      id: 'amount',
      label: '정산 금액',
      minWidth: 150,
      align: 'right',
      sortable: true,
      format: (value: number) => (
        <Typography variant="subtitle2" sx={{ fontWeight: 700, color: 'success.main' }}>
          ₩{value.toLocaleString()}
        </Typography>
      ),
    },
    {
      id: 'status',
      label: '상태',
      minWidth: 100,
      align: 'center',
      format: (value: string) => {
        const statusMap: any = {
          pending: { label: '대기중', color: 'warning' },
          completed: { label: '완료', color: 'success' },
          rejected: { label: '반려', color: 'error' },
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
      label: '신청일',
      minWidth: 120,
      sortable: true,
    },
  ];

  return (
    <Box>
      <PageHeader
        title="정산 관리"
        subtitle="판매자 정산을 처리하고 관리하세요"
        breadcrumbs={[
          { label: '홈', href: '/dashboard' },
          { label: '정산 관리' },
        ]}
      />

      {/* 정산 통계 */}
      <Stack direction="row" spacing={2} sx={{ mb: 3 }}>
        {[
          { label: '이번 달 정산', count: '₩28.2M', color: 'primary' },
          { label: '대기중', count: 8, color: 'warning' },
          { label: '완료', count: 142, color: 'success' },
          { label: '반려', count: 3, color: 'error' },
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
        rows={settlements}
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
          <Receipt fontSize="small" sx={{ mr: 1 }} />
          상세보기
        </MenuItem>
        {currentSettlement?.status === 'pending' && (
          <MenuItem onClick={handleMenuClose}>
            <CheckCircle fontSize="small" sx={{ mr: 1 }} />
            승인
          </MenuItem>
        )}
        <MenuItem onClick={handleMenuClose}>
          <Download fontSize="small" sx={{ mr: 1 }} />
          정산서 다운로드
        </MenuItem>
      </Menu>
    </Box>
  );
}
