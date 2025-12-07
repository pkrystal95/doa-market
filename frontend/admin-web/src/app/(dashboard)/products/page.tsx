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
import { Add, MoreVert, Edit, Delete, Visibility, VisibilityOff } from '@mui/icons-material';
import { PageHeader } from '@/components/common/page-header';
import { DataTable, Column } from '@/components/common/data-table';

// 샘플 데이터
const products = [
  {
    id: '1',
    name: '무선 마우스',
    category: '전자기기',
    seller: '테크샵',
    price: 45000,
    stock: 150,
    sales: 1250,
    status: 'active',
    image: '',
    createdAt: '2024-01-10',
  },
  {
    id: '2',
    name: '기계식 키보드',
    category: '전자기기',
    seller: '테크샵',
    price: 120000,
    stock: 80,
    sales: 680,
    status: 'active',
    image: '',
    createdAt: '2024-01-15',
  },
  {
    id: '3',
    name: '청바지',
    category: '의류',
    seller: '패션몰',
    price: 59000,
    stock: 200,
    sales: 890,
    status: 'active',
    image: '',
    createdAt: '2024-02-01',
  },
  {
    id: '4',
    name: '노트북 스탠드',
    category: '전자기기',
    seller: '테크샵',
    price: 35000,
    stock: 0,
    sales: 450,
    status: 'soldout',
    image: '',
    createdAt: '2024-02-10',
  },
  {
    id: '5',
    name: 'USB 케이블',
    category: '전자기기',
    seller: '테크샵',
    price: 15000,
    stock: 500,
    sales: 2340,
    status: 'active',
    image: '',
    createdAt: '2024-03-01',
  },
];

export default function ProductsPage() {
  const [selected, setSelected] = useState<string[]>([]);
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const [currentProduct, setCurrentProduct] = useState<any>(null);

  const handleMenuOpen = (event: React.MouseEvent<HTMLElement>, product: any) => {
    setAnchorEl(event.currentTarget);
    setCurrentProduct(product);
  };

  const handleMenuClose = () => {
    setAnchorEl(null);
    setCurrentProduct(null);
  };

  const columns: Column[] = [
    {
      id: 'name',
      label: '상품',
      minWidth: 250,
      sortable: true,
      format: (value: string, row: any) => (
        <Stack direction="row" alignItems="center" spacing={2}>
          <Avatar
            variant="rounded"
            sx={{ bgcolor: 'primary.lighter', color: 'primary.main', width: 48, height: 48 }}
          >
            {value[0]}
          </Avatar>
          <Box>
            <Typography variant="subtitle2" sx={{ fontWeight: 600 }}>
              {value}
            </Typography>
            <Typography variant="caption" color="text.secondary">
              {row.category} • {row.seller}
            </Typography>
          </Box>
        </Stack>
      ),
    },
    {
      id: 'price',
      label: '가격',
      minWidth: 120,
      align: 'right',
      sortable: true,
      format: (value: number) => `₩${value.toLocaleString()}`,
    },
    {
      id: 'stock',
      label: '재고',
      minWidth: 80,
      align: 'center',
      sortable: true,
      format: (value: number) => (
        <Chip
          label={value}
          color={value === 0 ? 'error' : value < 50 ? 'warning' : 'success'}
          size="small"
          sx={{ fontWeight: 600, minWidth: 60 }}
        />
      ),
    },
    {
      id: 'sales',
      label: '판매량',
      minWidth: 100,
      align: 'center',
      sortable: true,
      format: (value: number) => `${value.toLocaleString()}개`,
    },
    {
      id: 'status',
      label: '상태',
      minWidth: 100,
      align: 'center',
      format: (value: string) => {
        const statusMap: any = {
          active: { label: '판매중', color: 'success' },
          soldout: { label: '품절', color: 'error' },
          hidden: { label: '숨김', color: 'default' },
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
      label: '등록일',
      minWidth: 120,
      sortable: true,
    },
  ];

  return (
    <Box>
      <PageHeader
        title="상품 관리"
        subtitle="등록된 모든 상품을 관리하세요"
        breadcrumbs={[
          { label: '홈', href: '/dashboard' },
          { label: '상품 관리' },
        ]}
        action={{
          label: '상품 추가',
          onClick: () => console.log('Add product'),
          icon: <Add />,
        }}
      />

      <DataTable
        columns={columns}
        rows={products}
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
          {currentProduct?.status === 'hidden' ? (
            <>
              <Visibility fontSize="small" sx={{ mr: 1 }} />
              표시
            </>
          ) : (
            <>
              <VisibilityOff fontSize="small" sx={{ mr: 1 }} />
              숨김
            </>
          )}
        </MenuItem>
        <MenuItem onClick={handleMenuClose} sx={{ color: 'error.main' }}>
          <Delete fontSize="small" sx={{ mr: 1 }} />
          삭제
        </MenuItem>
      </Menu>
    </Box>
  );
}
