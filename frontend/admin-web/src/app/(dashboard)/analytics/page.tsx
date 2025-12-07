'use client';

import {
  Box,
  Grid,
  Card,
  CardContent,
  Typography,
  Stack,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
} from '@mui/material';
import { useState } from 'react';
import {
  TrendingUp,
  People,
  ShoppingCart,
  AttachMoney,
} from '@mui/icons-material';
import { PageHeader } from '@/components/common/page-header';
import { StatsCard } from '@/components/common/stats-card';
import { SalesChart, CategoryChart } from '@/components/charts';

export default function AnalyticsPage() {
  const [period, setPeriod] = useState('month');

  const stats = [
    {
      title: '총 방문자',
      value: '45,892',
      growth: 12,
      icon: People,
      color: 'primary',
      bgGradient: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    },
    {
      title: '전환율',
      value: '3.24%',
      growth: 0.8,
      icon: TrendingUp,
      color: 'success',
      bgGradient: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
    },
    {
      title: '평균 주문액',
      value: '₩127,500',
      growth: 5,
      icon: ShoppingCart,
      color: 'warning',
      bgGradient: 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
    },
    {
      title: '총 수익',
      value: '₩5,850,000',
      growth: 18,
      icon: AttachMoney,
      color: 'error',
      bgGradient: 'linear-gradient(135deg, #fa709a 0%, #fee140 100%)',
    },
  ];

  return (
    <Box>
      <PageHeader
        title="통계"
        subtitle="비즈니스 성과를 분석하세요"
        breadcrumbs={[
          { label: '홈', href: '/dashboard' },
          { label: '통계' },
        ]}
      />

      <Box sx={{ mb: 3, display: 'flex', justifyContent: 'flex-end' }}>
        <FormControl sx={{ minWidth: 150 }}>
          <InputLabel>기간</InputLabel>
          <Select
            value={period}
            label="기간"
            onChange={(e) => setPeriod(e.target.value)}
          >
            <MenuItem value="day">일간</MenuItem>
            <MenuItem value="week">주간</MenuItem>
            <MenuItem value="month">월간</MenuItem>
            <MenuItem value="year">연간</MenuItem>
          </Select>
        </FormControl>
      </Box>

      {/* Stats Cards */}
      <Grid container spacing={2.5} sx={{ mb: 2.5 }}>
        {stats.map((stat) => (
          <Grid item xs={12} sm={6} md={3} key={stat.title}>
            <StatsCard {...stat} />
          </Grid>
        ))}
      </Grid>

      <Grid container spacing={2.5} sx={{ mb: 2.5 }}>
        {/* Sales Chart */}
        <Grid item xs={12} md={8}>
          <SalesChart height={400} />
        </Grid>

        {/* Category Chart */}
        <Grid item xs={12} md={4}>
          <CategoryChart height={400} />
        </Grid>
      </Grid>

      <Grid container spacing={2.5}>
        {/* 상위 상품 */}
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Typography variant="h6" sx={{ mb: 3, fontWeight: 600 }}>
                인기 상품 TOP 5
              </Typography>
              <Stack spacing={2}>
                {[
                  { name: '무선 마우스', sales: 1250, revenue: 56250000 },
                  { name: '기계식 키보드', sales: 890, revenue: 106800000 },
                  { name: 'USB 케이블', sales: 2340, revenue: 35100000 },
                  { name: '노트북 스탠드', sales: 456, revenue: 15960000 },
                  { name: '모니터', sales: 234, revenue: 70200000 },
                ].map((product, index) => (
                  <Stack
                    key={product.name}
                    direction="row"
                    justifyContent="space-between"
                    alignItems="center"
                    sx={{
                      p: 2,
                      bgcolor: 'grey.50',
                      borderRadius: 2,
                    }}
                  >
                    <Stack direction="row" spacing={2} alignItems="center">
                      <Box
                        sx={{
                          width: 40,
                          height: 40,
                          borderRadius: '50%',
                          bgcolor: 'primary.main',
                          color: 'white',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          fontWeight: 700,
                        }}
                      >
                        {index + 1}
                      </Box>
                      <Box>
                        <Typography variant="subtitle2" sx={{ fontWeight: 600 }}>
                          {product.name}
                        </Typography>
                        <Typography variant="caption" color="text.secondary">
                          판매 {product.sales.toLocaleString()}개
                        </Typography>
                      </Box>
                    </Stack>
                    <Typography variant="subtitle2" sx={{ fontWeight: 700 }}>
                      ₩{(product.revenue / 1000000).toFixed(1)}M
                    </Typography>
                  </Stack>
                ))}
              </Stack>
            </CardContent>
          </Card>
        </Grid>

        {/* 상위 판매자 */}
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Typography variant="h6" sx={{ mb: 3, fontWeight: 600 }}>
                우수 판매자 TOP 5
              </Typography>
              <Stack spacing={2}>
                {[
                  { name: '테크샵', sales: 45000000, orders: 1250 },
                  { name: '패션몰', sales: 32000000, orders: 890 },
                  { name: '푸드마켓', sales: 28000000, orders: 1560 },
                  { name: '북스토어', sales: 24000000, orders: 680 },
                  { name: '뷰티샵', sales: 19000000, orders: 450 },
                ].map((seller, index) => (
                  <Stack
                    key={seller.name}
                    direction="row"
                    justifyContent="space-between"
                    alignItems="center"
                    sx={{
                      p: 2,
                      bgcolor: 'grey.50',
                      borderRadius: 2,
                    }}
                  >
                    <Stack direction="row" spacing={2} alignItems="center">
                      <Box
                        sx={{
                          width: 40,
                          height: 40,
                          borderRadius: '50%',
                          bgcolor: 'success.main',
                          color: 'white',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          fontWeight: 700,
                        }}
                      >
                        {index + 1}
                      </Box>
                      <Box>
                        <Typography variant="subtitle2" sx={{ fontWeight: 600 }}>
                          {seller.name}
                        </Typography>
                        <Typography variant="caption" color="text.secondary">
                          주문 {seller.orders.toLocaleString()}건
                        </Typography>
                      </Box>
                    </Stack>
                    <Typography variant="subtitle2" sx={{ fontWeight: 700 }}>
                      ₩{(seller.sales / 1000000).toFixed(1)}M
                    </Typography>
                  </Stack>
                ))}
              </Stack>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
}

