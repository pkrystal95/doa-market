'use client';

import { useState, useEffect } from 'react';
import {
  Box,
  Button,
  Chip,
  IconButton,
  Menu,
  MenuItem,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Select,
  FormControl,
  InputLabel,
  Stack,
  Typography,
  Alert,
} from '@mui/material';
import { Add, MoreVert, Edit, Delete, FolderOpen } from '@mui/icons-material';
import { PageHeader } from '@/components/common/page-header';
import { DataTable, Column } from '@/components/common/data-table';

interface Category {
  categoryId: string;
  name: string;
  slug: string;
  parentId: string | null;
  displayOrder: number;
  isActive: boolean;
  createdAt: string;
  subcategories?: Category[];
}

export default function CategoriesPage() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [selected, setSelected] = useState<string[]>([]);
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const [currentCategory, setCurrentCategory] = useState<Category | null>(null);
  const [openDialog, setOpenDialog] = useState(false);
  const [dialogMode, setDialogMode] = useState<'create' | 'edit'>('create');
  const [formData, setFormData] = useState({
    name: '',
    slug: '',
    parentId: '',
    displayOrder: 0,
    isActive: true,
  });
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  // 카테고리 목록 조회
  useEffect(() => {
    fetchCategories();
  }, []);

  const fetchCategories = async () => {
    setLoading(true);
    try {
      const response = await fetch('http://localhost:3003/api/v1/categories');
      const data = await response.json();

      if (data.success) {
        setCategories(data.data || []);
      } else {
        setError('카테고리 목록을 불러오는데 실패했습니다');
      }
    } catch (err) {
      console.error('카테고리 조회 에러:', err);
      setError('카테고리 목록을 불러오는데 실패했습니다');
    } finally {
      setLoading(false);
    }
  };

  const handleMenuOpen = (event: React.MouseEvent<HTMLElement>, category: Category) => {
    setAnchorEl(event.currentTarget);
    setCurrentCategory(category);
  };

  const handleMenuClose = () => {
    setAnchorEl(null);
    setCurrentCategory(null);
  };

  const handleOpenDialog = (mode: 'create' | 'edit', category?: Category) => {
    setDialogMode(mode);
    if (mode === 'edit' && category) {
      setFormData({
        name: category.name,
        slug: category.slug,
        parentId: category.parentId || '',
        displayOrder: category.displayOrder,
        isActive: category.isActive,
      });
      setCurrentCategory(category);
    } else {
      setFormData({
        name: '',
        slug: '',
        parentId: '',
        displayOrder: 0,
        isActive: true,
      });
    }
    setOpenDialog(true);
    handleMenuClose();
  };

  const handleCloseDialog = () => {
    setOpenDialog(false);
    setFormData({
      name: '',
      slug: '',
      parentId: '',
      displayOrder: 0,
      isActive: true,
    });
    setCurrentCategory(null);
    setError(null);
  };

  const handleSubmit = async () => {
    try {
      setLoading(true);
      const url = dialogMode === 'create'
        ? 'http://localhost:3003/api/v1/categories'
        : `http://localhost:3003/api/v1/categories/${currentCategory?.categoryId}`;

      const method = dialogMode === 'create' ? 'POST' : 'PUT';

      const response = await fetch(url, {
        method,
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
      });

      const data = await response.json();

      if (data.success) {
        await fetchCategories();
        handleCloseDialog();
      } else {
        setError(data.message || '카테고리 저장에 실패했습니다');
      }
    } catch (err) {
      console.error('카테고리 저장 에러:', err);
      setError('카테고리 저장에 실패했습니다');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async () => {
    if (!currentCategory) return;

    if (!confirm(`"${currentCategory.name}" 카테고리를 삭제하시겠습니까?`)) {
      handleMenuClose();
      return;
    }

    try {
      setLoading(true);
      const response = await fetch(
        `http://localhost:3003/api/v1/categories/${currentCategory.categoryId}`,
        { method: 'DELETE' }
      );

      const data = await response.json();

      if (data.success) {
        await fetchCategories();
      } else {
        setError(data.message || '카테고리 삭제에 실패했습니다');
      }
    } catch (err) {
      console.error('카테고리 삭제 에러:', err);
      setError('카테고리 삭제에 실패했습니다');
    } finally {
      setLoading(false);
      handleMenuClose();
    }
  };

  // 대분류 카테고리만 필터링
  const rootCategories = categories.filter(cat => !cat.parentId);

  // 테이블용 데이터 변환 (대분류 + 중분류)
  const tableData = categories.map(cat => {
    const parent = cat.parentId ? categories.find(c => c.categoryId === cat.parentId) : null;
    return {
      ...cat,
      parentName: parent?.name || '-',
      type: cat.parentId ? '중분류' : '대분류',
    };
  });

  const columns: Column[] = [
    {
      id: 'type',
      label: '구분',
      width: '80px',
      render: (row: any) => (
        <Chip
          label={row.type}
          size="small"
          color={row.type === '대분류' ? 'primary' : 'default'}
        />
      ),
    },
    {
      id: 'name',
      label: '카테고리명',
      width: '200px',
      render: (row: any) => (
        <Stack direction="row" spacing={1} alignItems="center">
          {row.type === '대분류' && <FolderOpen fontSize="small" color="primary" />}
          <Typography variant="body2" fontWeight={row.type === '대분류' ? 600 : 400}>
            {row.name}
          </Typography>
        </Stack>
      ),
    },
    {
      id: 'slug',
      label: 'Slug',
      width: '150px',
    },
    {
      id: 'parentName',
      label: '상위 카테고리',
      width: '150px',
    },
    {
      id: 'displayOrder',
      label: '정렬순서',
      width: '100px',
      align: 'center',
    },
    {
      id: 'isActive',
      label: '상태',
      width: '100px',
      align: 'center',
      render: (row: any) => (
        <Chip
          label={row.isActive ? '활성' : '비활성'}
          size="small"
          color={row.isActive ? 'success' : 'default'}
        />
      ),
    },
    {
      id: 'createdAt',
      label: '생성일',
      width: '120px',
      render: (row: any) => new Date(row.createdAt).toLocaleDateString(),
    },
    {
      id: 'actions',
      label: '',
      width: '60px',
      align: 'right',
      render: (row: any) => (
        <IconButton
          size="small"
          onClick={(e) => handleMenuOpen(e, row)}
        >
          <MoreVert fontSize="small" />
        </IconButton>
      ),
    },
  ];

  return (
    <Box>
      <PageHeader
        title="카테고리 관리"
        subtitle="상품 카테고리를 관리합니다"
        action={
          <Button
            variant="contained"
            startIcon={<Add />}
            onClick={() => handleOpenDialog('create')}
          >
            카테고리 추가
          </Button>
        }
      />

      {error && (
        <Alert severity="error" sx={{ mb: 2 }} onClose={() => setError(null)}>
          {error}
        </Alert>
      )}

      <DataTable
        columns={columns}
        data={tableData}
        selected={selected}
        onSelectChange={setSelected}
        loading={loading}
      />

      {/* 컨텍스트 메뉴 */}
      <Menu
        anchorEl={anchorEl}
        open={Boolean(anchorEl)}
        onClose={handleMenuClose}
      >
        <MenuItem onClick={() => handleOpenDialog('edit', currentCategory!)}>
          <Edit fontSize="small" sx={{ mr: 1 }} />
          수정
        </MenuItem>
        <MenuItem onClick={handleDelete} sx={{ color: 'error.main' }}>
          <Delete fontSize="small" sx={{ mr: 1 }} />
          삭제
        </MenuItem>
      </Menu>

      {/* 카테고리 추가/수정 다이얼로그 */}
      <Dialog open={openDialog} onClose={handleCloseDialog} maxWidth="sm" fullWidth>
        <DialogTitle>
          {dialogMode === 'create' ? '카테고리 추가' : '카테고리 수정'}
        </DialogTitle>
        <DialogContent>
          <Stack spacing={2} sx={{ mt: 1 }}>
            <TextField
              label="카테고리명"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              fullWidth
              required
            />
            <TextField
              label="Slug (URL용)"
              value={formData.slug}
              onChange={(e) => setFormData({ ...formData, slug: e.target.value })}
              fullWidth
              required
              helperText="영문 소문자, 숫자, 하이픈만 사용"
            />
            <FormControl fullWidth>
              <InputLabel>상위 카테고리</InputLabel>
              <Select
                value={formData.parentId}
                label="상위 카테고리"
                onChange={(e) => setFormData({ ...formData, parentId: e.target.value })}
              >
                <MenuItem value="">없음 (대분류)</MenuItem>
                {rootCategories.map((cat) => (
                  <MenuItem key={cat.categoryId} value={cat.categoryId}>
                    {cat.name}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
            <TextField
              label="정렬순서"
              type="number"
              value={formData.displayOrder}
              onChange={(e) => setFormData({ ...formData, displayOrder: parseInt(e.target.value) || 0 })}
              fullWidth
            />
            <FormControl fullWidth>
              <InputLabel>상태</InputLabel>
              <Select
                value={formData.isActive ? 'true' : 'false'}
                label="상태"
                onChange={(e) => setFormData({ ...formData, isActive: e.target.value === 'true' })}
              >
                <MenuItem value="true">활성</MenuItem>
                <MenuItem value="false">비활성</MenuItem>
              </Select>
            </FormControl>
          </Stack>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDialog}>취소</Button>
          <Button
            onClick={handleSubmit}
            variant="contained"
            disabled={loading || !formData.name || !formData.slug}
          >
            {dialogMode === 'create' ? '추가' : '수정'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}
