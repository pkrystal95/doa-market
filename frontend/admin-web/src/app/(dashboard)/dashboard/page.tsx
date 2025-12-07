'use client';

import { useQuery } from '@tanstack/react-query';
import { dashboardApi } from '@/lib/api';
import {
  Box,
  Card,
  CardContent,
  Typography,
  Stack,
  Avatar,
  LinearProgress,
  alpha,
  Paper,
  Chip,
} from '@mui/material';
import {
  TrendingUp,
  TrendingDown,
  People,
  ShoppingCart,
  Inventory,
  AttachMoney,
} from '@mui/icons-material';
import { SalesChart } from '@/components/charts';

export default function DashboardPage() {
  const { data: stats, isLoading } = useQuery({
    queryKey: ['dashboard-stats'],
    queryFn: async () => {
      const response = await dashboardApi.getStats();
      return response.data;
    },
  });

  const { data: recentOrders } = useQuery({
    queryKey: ['recent-orders'],
    queryFn: async () => {
      const response = await dashboardApi.getRecentOrders(10);
      return response.data;
    },
  });

  if (isLoading) {
    return (
      <Box sx={{ width: '100%', mt: 2 }}>
        <LinearProgress />
      </Box>
    );
  }

  const statCards = [
    {
      title: '총 사용자',
      value: stats?.totalUsers?.toLocaleString() || '0',
      growth: stats?.userGrowth || 0,
      icon: People,
      bgGradient: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    },
    {
      title: '총 주문',
      value: stats?.totalOrders?.toLocaleString() || '0',
      growth: stats?.orderGrowth || 0,
      icon: ShoppingCart,
      bgGradient: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
    },
    {
      title: '총 상품',
      value: stats?.totalProducts?.toLocaleString() || '0',
      growth: stats?.productGrowth || 0,
      icon: Inventory,
      bgGradient: 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
    },
    {
      title: '총 매출',
      value: `₩${stats?.totalRevenue?.toLocaleString() || '0'}`,
      growth: stats?.revenueGrowth || 0,
      icon: AttachMoney,
      bgGradient: 'linear-gradient(135deg, #fa709a 0%, #fee140 100%)',
    },
  ];

  return (
    <Box>
      {/* Page Header */}
      <Box sx={{ mb: 3 }}>
        <Typography variant="h4" sx={{ fontWeight: 700, mb: 0.5 }}>
          대시보드 📊
        </Typography>
        <Typography variant="body2" color="text.secondary">
          전체 시스템 현황을 확인하세요
        </Typography>
      </Box>

      <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
        {/* Stats Cards - 4개 */}
        <Box
          sx={{
            display: 'grid',
            gridTemplateColumns: {
              xs: '1fr',
              sm: '1fr 1fr',
              lg: 'repeat(4, 1fr)',
            },
            gap: 2.5,
          }}
        >
          {statCards.map((stat) => {
            const Icon = stat.icon;
            const isPositive = stat.growth >= 0;

            return (
              <Card
                key={stat.title}
                sx={{
                  background: 'linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%)',
                  position: 'relative',
                  overflow: 'hidden',
                  '&::before': {
                    content: '""',
                    position: 'absolute',
                    top: 0,
                    right: 0,
                    width: '50%',
                    height: '100%',
                    background: stat.bgGradient,
                    opacity: 0.08,
                    borderRadius: '50% 0 0 50%',
                  },
                }}
              >
                <CardContent>
                  <Stack direction="row" alignItems="center" justifyContent="space-between">
                    <Box>
                      <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                        {stat.title}
                      </Typography>
                      <Typography variant="h4" sx={{ fontWeight: 700, mb: 1 }}>
                        {stat.value}
                      </Typography>
                      <Stack direction="row" alignItems="center" spacing={0.5}>
                        {isPositive ? (
                          <TrendingUp sx={{ fontSize: 18, color: 'success.main' }} />
                        ) : (
                          <TrendingDown sx={{ fontSize: 18, color: 'error.main' }} />
                        )}
                        <Typography
                          variant="caption"
                          sx={{
                            color: isPositive ? 'success.main' : 'error.main',
                            fontWeight: 600,
                          }}
                        >
                          {isPositive ? '+' : ''}{stat.growth}%
                        </Typography>
                        <Typography variant="caption" color="text.secondary">
                          지난 달 대비
                        </Typography>
                      </Stack>
                    </Box>
                    <Avatar
                      sx={{
                        width: 56,
                        height: 56,
                        background: stat.bgGradient,
                        boxShadow: (theme) => `0 8px 16px 0 ${alpha(theme.palette.grey[900], 0.24)}`,
                      }}
                    >
                      <Icon sx={{ fontSize: 28 }} />
                    </Avatar>
                  </Stack>
                </CardContent>
              </Card>
            );
          })}
        </Box>

        {/* 매출 차트 + 주문 현황 */}
        <Box
          sx={{
            display: 'grid',
            gridTemplateColumns: { xs: '1fr', md: '2fr 1fr' },
            gap: 2.5,
          }}
        >
          {/* 매출 차트 */}
          <SalesChart />

          {/* 주문 현황 */}
          <Card>
            <CardContent>
              <Typography variant="h6" sx={{ mb: 2.5, fontWeight: 600 }}>
                주문 현황
              </Typography>
              <Stack spacing={2}>
                {[
                  { label: '대기중', value: 12, color: 'warning' },
                  { label: '배송중', value: 35, color: 'info' },
                  { label: '완료', value: 248, color: 'success' },
                  { label: '취소', value: 5, color: 'error' },
                ].map((item) => (
                  <Box key={item.label}>
                    <Stack direction="row" justifyContent="space-between" sx={{ mb: 1 }}>
                      <Typography variant="body2" color="text.secondary">
                        {item.label}
                      </Typography>
                      <Typography variant="subtitle2" sx={{ fontWeight: 600 }}>
                        {item.value}
                      </Typography>
                    </Stack>
                    <LinearProgress
                      variant="determinate"
                      value={(item.value / 300) * 100}
                      color={item.color as any}
                      sx={{ height: 6, borderRadius: 3 }}
                    />
                  </Box>
                ))}
              </Stack>
            </CardContent>
          </Card>
        </Box>

        {/* 최근 주문 */}
        <Card>
          <CardContent>
            <Typography variant="h6" sx={{ mb: 2.5, fontWeight: 600 }}>
              최근 주문
            </Typography>
            {recentOrders && recentOrders.length > 0 ? (
              <Stack spacing={2}>
                {recentOrders.slice(0, 5).map((order: any) => (
                  <Paper
                    key={order.id}
                    sx={{
                      p: 2,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      bgcolor: 'grey.50',
                      border: 1,
                      borderColor: 'divider',
                      '&:hover': {
                        bgcolor: 'primary.lighter',
                        borderColor: 'primary.main',
                      },
                      transition: 'all 0.2s',
                    }}
                  >
                    <Stack direction="row" alignItems="center" spacing={2}>
                      <Avatar sx={{ bgcolor: 'primary.main' }}>
                        <ShoppingCart />
                      </Avatar>
                      <Box>
                        <Typography variant="subtitle2" sx={{ fontWeight: 600 }}>
                          {order.orderNumber || `주문 #${order.id?.slice(0, 8)}`}
                        </Typography>
                        <Typography variant="caption" color="text.secondary">
                          {new Date(order.createdAt).toLocaleString('ko-KR', {
                            year: 'numeric',
                            month: 'short',
                            day: 'numeric',
                            hour: '2-digit',
                            minute: '2-digit',
                          })}
                        </Typography>
                      </Box>
                    </Stack>
                    <Stack alignItems="flex-end" spacing={0.5}>
                      <Typography variant="h6" sx={{ fontWeight: 700 }}>
                        ₩{order.totalAmount?.toLocaleString() || '0'}
                      </Typography>
                      <Chip
                        label={order.status || '처리중'}
                        size="small"
                        color="primary"
                        sx={{ fontWeight: 600 }}
                      />
                    </Stack>
                  </Paper>
                ))}
              </Stack>
            ) : (
              <Box
                sx={{
                  py: 8,
                  textAlign: 'center',
                  color: 'text.secondary',
                }}
              >
                <ShoppingCart sx={{ fontSize: 48, mb: 1, opacity: 0.5 }} />
                <Typography>주문이 없습니다</Typography>
              </Box>
            )}
          </CardContent>
        </Card>
      </Box>
    </Box>
  );
}
