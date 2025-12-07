'use client';

import { Card, CardContent, Typography, Box } from '@mui/material';
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
} from 'recharts';

interface SalesChartProps {
  data?: any[];
  height?: number;
}

const defaultData = [
  { month: '1월', revenue: 12000000, orders: 145 },
  { month: '2월', revenue: 15000000, orders: 178 },
  { month: '3월', revenue: 18000000, orders: 215 },
  { month: '4월', revenue: 22000000, orders: 264 },
  { month: '5월', revenue: 19000000, orders: 228 },
  { month: '6월', revenue: 24000000, orders: 287 },
  { month: '7월', revenue: 28000000, orders: 335 },
  { month: '8월', revenue: 26000000, orders: 312 },
  { month: '9월', revenue: 30000000, orders: 358 },
  { month: '10월', revenue: 32000000, orders: 383 },
  { month: '11월', revenue: 35000000, orders: 419 },
  { month: '12월', revenue: 40000000, orders: 478 },
];

export function SalesChart({ data = defaultData, height = 350 }: SalesChartProps) {
  return (
    <Card>
      <CardContent>
        <Typography variant="h6" sx={{ mb: 3, fontWeight: 600 }}>
          월별 매출 추이
        </Typography>
        <Box sx={{ width: '100%', height }}>
          <ResponsiveContainer width="100%" height="100%">
            <AreaChart
              data={data}
              margin={{ top: 10, right: 30, left: 0, bottom: 0 }}
            >
              <defs>
                <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#667eea" stopOpacity={0.8} />
                  <stop offset="95%" stopColor="#667eea" stopOpacity={0.1} />
                </linearGradient>
                <linearGradient id="colorOrders" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#f093fb" stopOpacity={0.8} />
                  <stop offset="95%" stopColor="#f093fb" stopOpacity={0.1} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
              <XAxis
                dataKey="month"
                stroke="#888888"
                fontSize={12}
                tickLine={false}
              />
              <YAxis
                yAxisId="left"
                stroke="#888888"
                fontSize={12}
                tickLine={false}
                tickFormatter={(value) => `₩${(value / 1000000).toFixed(0)}M`}
              />
              <YAxis
                yAxisId="right"
                orientation="right"
                stroke="#888888"
                fontSize={12}
                tickLine={false}
              />
              <Tooltip
                contentStyle={{
                  backgroundColor: '#fff',
                  border: '1px solid #e0e0e0',
                  borderRadius: 8,
                  boxShadow: '0 4px 12px rgba(0,0,0,0.1)',
                }}
                formatter={(value: any, name: string) => {
                  if (name === 'revenue') {
                    return [`₩${Number(value).toLocaleString()}`, '매출'];
                  }
                  return [value, '주문수'];
                }}
              />
              <Legend
                verticalAlign="top"
                height={36}
                formatter={(value) => (value === 'revenue' ? '매출' : '주문수')}
              />
              <Area
                type="monotone"
                dataKey="revenue"
                stroke="#667eea"
                strokeWidth={2}
                fillOpacity={1}
                fill="url(#colorRevenue)"
                yAxisId="left"
              />
              <Area
                type="monotone"
                dataKey="orders"
                stroke="#f093fb"
                strokeWidth={2}
                fillOpacity={1}
                fill="url(#colorOrders)"
                yAxisId="right"
              />
            </AreaChart>
          </ResponsiveContainer>
        </Box>
      </CardContent>
    </Card>
  );
}

