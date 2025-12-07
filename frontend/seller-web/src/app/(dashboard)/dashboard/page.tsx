'use client';

import {
  Box,
  Grid,
  Card,
  CardContent,
  Typography,
  Stack,
  LinearProgress,
  Chip,
  alpha,
} from '@mui/material';
import {
  Inventory,
  ShoppingCart,
  AttachMoney,
  TrendingUp,
  Star,
} from '@mui/icons-material';
import { StatsCard } from '@/components/common';

export default function SellerDashboardPage() {
  const stats = [
    {
      title: '내 상품',
      value: '124',
      growth: 8,
      icon: Inventory,
      bgGradient: 'linear-gradient(135deg, #FFE4CC 0%, #FFB366 100%)',
    },
    {
      title: '신규 주문',
      value: '32',
      growth: 12,
      icon: ShoppingCart,
      bgGradient: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
    },
    {
      title: '이번 달 매출',
      value: '₩12,450,000',
      growth: 23,
      icon: AttachMoney,
      bgGradient: 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
    },
    {
      title: '평균 평점',
      value: '4.8',
      growth: 2,
      icon: Star,
      bgGradient: 'linear-gradient(135deg, #fa709a 0%, #fee140 100%)',
    },
  ];

  return (
    <Box>
      {/* Page Header */}
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" sx={{ fontWeight: 700, mb: 0.5 }}>
          판매자 대시보드 🏪
        </Typography>
        <Typography variant="body2" color="text.secondary">
          안녕하세요, 테크샵님! 오늘도 좋은 판매 되세요 ✨
        </Typography>
      </Box>

      {/* Stats Cards */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        {stats.map((stat) => (
          <Grid item xs={12} sm={6} md={3} key={stat.title}>
            <StatsCard {...stat} />
          </Grid>
        ))}
      </Grid>

      <Grid container spacing={3}>
        {/* 최근 주문 현황 */}
        <Grid item xs={12} md={8}>
          <Card>
            <CardContent>
              <Typography variant="h6" sx={{ mb: 3, fontWeight: 600 }}>
                최근 주문 현황
              </Typography>
              <Stack spacing={2}>
                {[
                  { id: 'ORD-001', product: '무선 마우스', amount: 45000, status: '배송중', statusColor: 'info' },
                  { id: 'ORD-002', product: '기계식 키보드', amount: 120000, status: '대기중', statusColor: 'warning' },
                  { id: 'ORD-003', product: 'USB 케이블', amount: 15000, status: '완료', statusColor: 'success' },
                  { id: 'ORD-004', product: '모니터 스탠드', amount: 55000, status: '배송중', statusColor: 'info' },
                ].map((order) => (
                  <Box
                    key={order.id}
                    sx={{
                      p: 2,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      bgcolor: (theme) => alpha(theme.palette.grey[500], 0.04),
                      borderRadius: 2,
                      border: (theme) => `1px solid ${theme.palette.divider}`,
                      '&:hover': {
                        bgcolor: (theme) => alpha(theme.palette.primary.main, 0.04),
                        borderColor: 'primary.main',
                      },
                      transition: 'all 0.2s',
                    }}
                  >
                    <Box>
                      <Typography variant="subtitle2" sx={{ fontWeight: 600 }}>
                        {order.id}
                      </Typography>
                      <Typography variant="body2" color="text.secondary">
                        {order.product}
                      </Typography>
                    </Box>
                    <Stack alignItems="flex-end" spacing={0.5}>
                      <Typography variant="h6" sx={{ fontWeight: 700 }}>
                        ₩{order.amount.toLocaleString()}
                      </Typography>
                      <Chip
                        label={order.status}
                        size="small"
                        color={order.statusColor as any}
                        sx={{ fontWeight: 600 }}
                      />
                    </Stack>
                  </Box>
                ))}
              </Stack>
            </CardContent>
          </Card>
        </Grid>

        {/* 상품 현황 */}
        <Grid item xs={12} md={4}>
          <Card sx={{ height: '100%' }}>
            <CardContent>
              <Typography variant="h6" sx={{ mb: 3, fontWeight: 600 }}>
                상품 현황
              </Typography>
              <Stack spacing={2}>
                {[
                  { label: '판매중', value: 98, total: 124, color: 'success' },
                  { label: '품절', value: 15, total: 124, color: 'error' },
                  { label: '숨김', value: 11, total: 124, color: 'warning' },
                ].map((item) => (
                  <Box key={item.label}>
                    <Stack direction="row" justifyContent="space-between" sx={{ mb: 1 }}>
                      <Typography variant="body2" color="text.secondary">
                        {item.label}
                      </Typography>
                      <Typography variant="subtitle2" sx={{ fontWeight: 600 }}>
                        {item.value} / {item.total}
                      </Typography>
                    </Stack>
                    <LinearProgress
                      variant="determinate"
                      value={(item.value / item.total) * 100}
                      color={item.color as any}
                      sx={{ height: 8, borderRadius: 4 }}
                    />
                  </Box>
                ))}
              </Stack>

              <Box sx={{ mt: 4, p: 2, bgcolor: 'primary.lighter', borderRadius: 2 }}>
                <Stack direction="row" alignItems="center" spacing={1} sx={{ mb: 1 }}>
                  <TrendingUp color="primary" />
                  <Typography variant="subtitle2" color="primary.dark">
                    이번 주 판매 증가율
                  </Typography>
                </Stack>
                <Typography variant="h4" color="primary.main" sx={{ fontWeight: 700 }}>
                  +23%
                </Typography>
                <Typography variant="caption" color="text.secondary">
                  지난 주 대비 8건 증가
                </Typography>
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
}
