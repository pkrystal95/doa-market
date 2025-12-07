import {
  Card,
  CardContent,
  Stack,
  Box,
  Avatar,
  Typography,
  alpha,
} from '@mui/material';
import { TrendingUp, TrendingDown } from '@mui/icons-material';

interface StatsCardProps {
  title: string;
  value: string | number;
  growth?: number;
  icon: React.ElementType;
  color?: 'primary' | 'success' | 'warning' | 'error' | 'info';
  bgGradient?: string;
}

export function StatsCard({
  title,
  value,
  growth,
  icon: Icon,
  color = 'primary',
  bgGradient = 'linear-gradient(135deg, #FFE4CC 0%, #FFB366 100%)',
}: StatsCardProps) {
  const isPositive = (growth ?? 0) >= 0;

  return (
    <Card
      sx={{
        height: '100%',
        background: 'linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%)',
        position: 'relative',
        overflow: 'hidden',
        transition: 'all 0.3s',
        '&:hover': {
          transform: 'translateY(-4px)',
          boxShadow: (theme) => theme.shadows[12],
        },
        '&::before': {
          content: '""',
          position: 'absolute',
          top: 0,
          right: 0,
          width: '50%',
          height: '100%',
          background: bgGradient,
          opacity: 0.08,
          borderRadius: '50% 0 0 50%',
        },
      }}
    >
      <CardContent>
        <Stack direction="row" alignItems="center" justifyContent="space-between">
          <Box>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
              {title}
            </Typography>
            <Typography variant="h4" sx={{ fontWeight: 700, mb: 1 }}>
              {value}
            </Typography>
            {growth !== undefined && (
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
                  {isPositive ? '+' : ''}{growth}%
                </Typography>
                <Typography variant="caption" color="text.secondary">
                  지난 달 대비
                </Typography>
              </Stack>
            )}
          </Box>
          <Avatar
            sx={{
              width: 64,
              height: 64,
              background: bgGradient,
              boxShadow: (theme) => `0 8px 16px 0 ${alpha(theme.palette.grey[900], 0.24)}`,
            }}
          >
            <Icon sx={{ fontSize: 32 }} />
          </Avatar>
        </Stack>
      </CardContent>
    </Card>
  );
}

