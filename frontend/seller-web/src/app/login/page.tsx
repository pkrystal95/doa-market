'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import {
  Box,
  Card,
  Stack,
  Alert,
  Button,
  TextField,
  Typography,
  IconButton,
  InputAdornment,
  Container,
  alpha,
  Avatar,
} from '@mui/material';
import {
  Visibility,
  VisibilityOff,
  Store as StoreIcon,
  Login as LoginIcon,
} from '@mui/icons-material';

export default function SellerLoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState('seller@doamarket.com');
  const [password, setPassword] = useState('seller123');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);

    try {
      // TODO: 실제 API 연동
      setTimeout(() => {
        router.push('/dashboard');
      }, 1000);
    } catch (err: any) {
      setError('로그인에 실패했습니다.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <Box
      sx={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        background: (theme) =>
          `linear-gradient(135deg, ${alpha(theme.palette.primary.main, 0.1)} 0%, ${alpha(theme.palette.secondary.main, 0.1)} 100%)`,
        backgroundImage: 'url("data:image/svg+xml,%3Csvg width=\'60\' height=\'60\' viewBox=\'0 0 60 60\' xmlns=\'http://www.w3.org/2000/svg\'%3E%3Cg fill=\'none\' fill-rule=\'evenodd\'%3E%3Cg fill=\'%23FF7A00\' fill-opacity=\'0.05\'%3E%3Cpath d=\'M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z\'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")',
      }}
    >
      <Container maxWidth="sm">
        <Card
          sx={{
            p: 5,
            boxShadow: (theme) => theme.shadows[20],
            borderRadius: 2,
          }}
        >
          <Box sx={{ mb: 5, textAlign: 'center' }}>
            <Avatar
              sx={{
                width: 80,
                height: 80,
                bgcolor: 'primary.main',
                margin: '0 auto 16px',
              }}
            >
              <StoreIcon sx={{ fontSize: 48 }} />
            </Avatar>
            <Typography
              variant="h3"
              sx={{
                mb: 1,
                fontWeight: 700,
                background: (theme) =>
                  `linear-gradient(135deg, ${theme.palette.primary.main} 0%, ${theme.palette.secondary.main} 100%)`,
                backgroundClip: 'text',
                WebkitBackgroundClip: 'text',
                WebkitTextFillColor: 'transparent',
              }}
            >
              DOA Market
            </Typography>
            <Typography variant="h5" sx={{ mb: 1, fontWeight: 600 }}>
              판매자 센터
            </Typography>
            <Typography variant="body2" color="text.secondary">
              판매자 계정으로 로그인하세요
            </Typography>
          </Box>

          {/* Demo 계정 안내 */}
          <Alert 
            severity="info" 
            icon={<LoginIcon />}
            sx={{ mb: 3 }}
          >
            <Typography variant="body2">
              <strong>테스트 계정:</strong> {email}
              <br />
              <strong>비밀번호:</strong> {password}
            </Typography>
          </Alert>

          {/* 에러 메시지 */}
          {error && (
            <Alert 
              severity="error" 
              sx={{ mb: 3 }}
              onClose={() => setError('')}
            >
              {error}
            </Alert>
          )}

          {/* 로그인 폼 */}
          <form onSubmit={handleSubmit}>
            <Stack spacing={3}>
              <TextField
                fullWidth
                label="이메일"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                InputLabelProps={{ shrink: true }}
                placeholder="seller@doamarket.com"
              />

              <TextField
                fullWidth
                label="비밀번호"
                type={showPassword ? 'text' : 'password'}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                InputLabelProps={{ shrink: true }}
                placeholder="6자 이상 입력하세요"
                InputProps={{
                  endAdornment: (
                    <InputAdornment position="end">
                      <IconButton
                        onClick={() => setShowPassword(!showPassword)}
                        edge="end"
                      >
                        {showPassword ? <VisibilityOff /> : <Visibility />}
                      </IconButton>
                    </InputAdornment>
                  ),
                }}
              />

              <Button
                fullWidth
                size="large"
                type="submit"
                variant="contained"
                disabled={isLoading}
                sx={{
                  py: 1.5,
                  fontSize: 16,
                  fontWeight: 600,
                  textTransform: 'none',
                  boxShadow: (theme) => theme.shadows[8],
                  '&:hover': {
                    boxShadow: (theme) => theme.shadows[12],
                  },
                }}
              >
                {isLoading ? '로그인 중...' : '로그인'}
              </Button>
            </Stack>
          </form>

          <Box sx={{ mt: 4, textAlign: 'center' }}>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
              아직 판매자 계정이 없으신가요?
            </Typography>
            <Button
              variant="outlined"
              onClick={() => router.push('/register')}
              sx={{ textTransform: 'none' }}
            >
              판매자 입점 신청
            </Button>
          </Box>

          <Box sx={{ mt: 3, textAlign: 'center' }}>
            <Typography variant="caption" color="text.secondary">
              © 2025 DOA Market. All rights reserved.
            </Typography>
          </Box>
        </Card>
      </Container>
    </Box>
  );
}

