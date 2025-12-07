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
import { Add, MoreVert, Edit, Delete, Block } from '@mui/icons-material';
import { PageHeader } from '@/components/common/page-header';
import { DataTable, Column } from '@/components/common/data-table';

// 샘플 데이터
const users = [
  {
    id: '1',
    name: '김철수',
    email: 'kim@example.com',
    phone: '010-1234-5678',
    tier: 'GOLD',
    status: 'active',
    createdAt: '2024-01-15',
    totalOrders: 45,
    totalSpent: 3500000,
  },
  {
    id: '2',
    name: '이영희',
    email: 'lee@example.com',
    phone: '010-2345-6789',
    tier: 'SILVER',
    status: 'active',
    createdAt: '2024-02-20',
    totalOrders: 28,
    totalSpent: 1800000,
  },
  {
    id: '3',
    name: '박민수',
    email: 'park@example.com',
    phone: '010-3456-7890',
    tier: 'PLATINUM',
    status: 'active',
    createdAt: '2023-12-10',
    totalOrders: 89,
    totalSpent: 8200000,
  },
  {
    id: '4',
    name: '정수진',
    email: 'jung@example.com',
    phone: '010-4567-8901',
    tier: 'BRONZE',
    status: 'inactive',
    createdAt: '2024-03-05',
    totalOrders: 12,
    totalSpent: 450000,
  },
];

export default function UsersPage() {
  const [selected, setSelected] = useState<string[]>([]);
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const [currentUser, setCurrentUser] = useState<any>(null);

  const handleMenuOpen = (event: React.MouseEvent<HTMLElement>, user: any) => {
    setAnchorEl(event.currentTarget);
    setCurrentUser(user);
  };

  const handleMenuClose = () => {
    setAnchorEl(null);
    setCurrentUser(null);
  };

  const columns: Column[] = [
    {
      id: 'name',
      label: '사용자',
      minWidth: 200,
      sortable: true,
      format: (value: string, row: any) => (
        <Stack direction="row" alignItems="center" spacing={2}>
          <Avatar sx={{ bgcolor: 'primary.main' }}>{value[0]}</Avatar>
          <Box>
            <Typography variant="subtitle2" sx={{ fontWeight: 600 }}>
              {value}
            </Typography>
            <Typography variant="caption" color="text.secondary">
              {row.email}
            </Typography>
          </Box>
        </Stack>
      ),
    },
    {
      id: 'phone',
      label: '연락처',
      minWidth: 130,
    },
    {
      id: 'tier',
      label: '등급',
      minWidth: 100,
      align: 'center',
      format: (value: string) => {
        const colors: any = {
          PLATINUM: 'error',
          GOLD: 'warning',
          SILVER: 'info',
          BRONZE: 'default',
        };
        return (
          <Chip
            label={value}
            color={colors[value]}
            size="small"
            sx={{ fontWeight: 600 }}
          />
        );
      },
    },
    {
      id: 'totalOrders',
      label: '주문수',
      minWidth: 80,
      align: 'center',
      sortable: true,
    },
    {
      id: 'totalSpent',
      label: '총 구매액',
      minWidth: 130,
      align: 'right',
      sortable: true,
      format: (value: number) => `₩${value.toLocaleString()}`,
    },
    {
      id: 'status',
      label: '상태',
      minWidth: 100,
      align: 'center',
      format: (value: string) => (
        <Chip
          label={value === 'active' ? '활성' : '비활성'}
          color={value === 'active' ? 'success' : 'default'}
          size="small"
        />
      ),
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
        title="사용자 관리"
        subtitle="전체 사용자를 관리하고 모니터링하세요"
        breadcrumbs={[
          { label: '홈', href: '/dashboard' },
          { label: '사용자 관리' },
        ]}
        action={{
          label: '사용자 추가',
          onClick: () => console.log('Add user'),
          icon: <Add />,
        }}
      />

      <DataTable
        columns={columns}
        rows={users}
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
        <MenuItem onClick={handleMenuClose}>
          <Block fontSize="small" sx={{ mr: 1 }} />
          정지
        </MenuItem>
        <MenuItem onClick={handleMenuClose} sx={{ color: 'error.main' }}>
          <Delete fontSize="small" sx={{ mr: 1 }} />
          삭제
        </MenuItem>
      </Menu>
    </Box>
  );
}
