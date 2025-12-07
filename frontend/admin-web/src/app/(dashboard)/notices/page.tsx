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
import { Add, MoreVert, Edit, Delete, PushPin, Visibility } from '@mui/icons-material';
import { PageHeader } from '@/components/common/page-header';
import { DataTable, Column } from '@/components/common/data-table';

// 샘플 데이터
const notices = [
  {
    id: '1',
    title: '[중요] 설 연휴 배송 안내',
    category: 'announcement',
    author: '관리자',
    views: 1250,
    isPinned: true,
    status: 'published',
    createdAt: '2024-12-01 10:00',
  },
  {
    id: '2',
    title: '12월 정산 일정 변경 안내',
    category: 'settlement',
    author: '관리자',
    views: 589,
    isPinned: false,
    status: 'published',
    createdAt: '2024-11-28 14:30',
  },
  {
    id: '3',
    title: '신규 카테고리 추가 안내',
    category: 'update',
    author: '운영팀',
    views: 342,
    isPinned: false,
    status: 'published',
    createdAt: '2024-11-25 09:15',
  },
  {
    id: '4',
    title: '시스템 점검 예정 안내',
    category: 'maintenance',
    author: '기술팀',
    views: 0,
    isPinned: false,
    status: 'draft',
    createdAt: '2024-11-20 16:45',
  },
];

export default function NoticesPage() {
  const [selected, setSelected] = useState<string[]>([]);
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const [currentNotice, setCurrentNotice] = useState<any>(null);

  const handleMenuOpen = (event: React.MouseEvent<HTMLElement>, notice: any) => {
    setAnchorEl(event.currentTarget);
    setCurrentNotice(notice);
  };

  const handleMenuClose = () => {
    setAnchorEl(null);
    setCurrentNotice(null);
  };

  const columns: Column[] = [
    {
      id: 'title',
      label: '제목',
      minWidth: 350,
      sortable: true,
      format: (value: string, row: any) => (
        <Stack direction="row" alignItems="center" spacing={1}>
          {row.isPinned && <PushPin sx={{ fontSize: 16, color: 'error.main' }} />}
          <Typography variant="subtitle2" sx={{ fontWeight: 600 }}>
            {value}
          </Typography>
        </Stack>
      ),
    },
    {
      id: 'category',
      label: '카테고리',
      minWidth: 120,
      align: 'center',
      format: (value: string) => {
        const categoryMap: any = {
          announcement: { label: '공지', color: 'primary' },
          settlement: { label: '정산', color: 'warning' },
          update: { label: '업데이트', color: 'info' },
          maintenance: { label: '점검', color: 'error' },
        };
        const category = categoryMap[value] || categoryMap.announcement;
        return (
          <Chip
            label={category.label}
            color={category.color}
            size="small"
            sx={{ fontWeight: 600 }}
          />
        );
      },
    },
    {
      id: 'author',
      label: '작성자',
      minWidth: 100,
      align: 'center',
    },
    {
      id: 'views',
      label: '조회수',
      minWidth: 100,
      align: 'center',
      sortable: true,
      format: (value: number) => value.toLocaleString(),
    },
    {
      id: 'status',
      label: '상태',
      minWidth: 100,
      align: 'center',
      format: (value: string) => {
        const statusMap: any = {
          published: { label: '게시중', color: 'success' },
          draft: { label: '임시저장', color: 'default' },
        };
        const status = statusMap[value] || statusMap.draft;
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
        title="공지사항"
        subtitle="공지사항을 작성하고 관리하세요"
        breadcrumbs={[
          { label: '홈', href: '/dashboard' },
          { label: '공지사항' },
        ]}
        action={{
          label: '공지 작성',
          onClick: () => console.log('Create notice'),
          icon: <Add />,
        }}
      />

      {/* 공지사항 통계 */}
      <Stack direction="row" spacing={2} sx={{ mb: 3 }}>
        {[
          { label: '전체 공지', count: 156, color: 'default' },
          { label: '게시중', count: 145, color: 'success' },
          { label: '임시저장', count: 11, color: 'default' },
          { label: '고정 공지', count: 3, color: 'error' },
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
        rows={notices}
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
          미리보기
        </MenuItem>
        <MenuItem onClick={handleMenuClose}>
          <Edit fontSize="small" sx={{ mr: 1 }} />
          수정
        </MenuItem>
        <MenuItem onClick={handleMenuClose}>
          <PushPin fontSize="small" sx={{ mr: 1 }} />
          {currentNotice?.isPinned ? '고정 해제' : '상단 고정'}
        </MenuItem>
        <MenuItem onClick={handleMenuClose} sx={{ color: 'error.main' }}>
          <Delete fontSize="small" sx={{ mr: 1 }} />
          삭제
        </MenuItem>
      </Menu>
    </Box>
  );
}
