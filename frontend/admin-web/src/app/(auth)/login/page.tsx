'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useMutation } from '@tanstack/react-query';
import { authApi } from '@/lib/api';
import { useAuthStore } from '@/store/auth-store';
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
} from '@mui/material';
import {
  Visibility,
  VisibilityOff,
  Login as LoginIcon,
} from '@mui/icons-material';

export default function LoginPage() {
  const router = useRouter();
  const { setAuth } = useAuthStore();
  const [email, setEmail] = useState('admin@doamarket.com');
  const [password, setPassword] = useState('admin123');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');

  const loginMutation = useMutation({
    mutationFn: authApi.login,
    onSuccess: (response) => {
      console.log('Login response:', response);
      
      if (response && response.data) {
        const { accessToken, refreshToken, user } = response.data;
        
        console.log('User:', user);
        console.log('Role:', user?.role);
        
        // 관리자 권한 확인
        if (user.role !== 'admin') {
          setError('관리자 권한이 필요합니다.');
          return;
        }

        setAuth(user, accessToken, refreshToken);
        
        // 토큰 저장
        if (typeof window !== 'undefined') {
          localStorage.setItem('accessToken', accessToken);
          localStorage.setItem('refreshToken', refreshToken);
        }
        
        console.log('Redirecting to dashboard...');
        router.push('/dashboard');
      } else {
        console.error('Invalid response format:', response);
        setError('서버 응답 형식이 올바르지 않습니다.');
      }
    },
    onError: (err: any) => {
      console.error('Login error:', err);
      setError(err.response?.data?.message || '로그인에 실패했습니다.');
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    loginMutation.mutate({ email, password });
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
        backgroundImage: 'url("data:image/svg+xml,%3Csvg width=\'60\' height=\'60\' viewBox=\'0 0 60 60\' xmlns=\'http://www.w3.org/2000/svg\'%3E%3Cg fill=\'none\' fill-rule=\'evenodd\'%3E%3Cg fill=\'%239C92AC\' fill-opacity=\'0.05\'%3E%3Cpath d=\'M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z\'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")',
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
              Admin Dashboard
            </Typography>
            <Typography variant="body2" color="text.secondary">
              관리자 계정으로 로그인하세요
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
                placeholder="admin@doamarket.com"
                sx={{
                  '& .MuiOutlinedInput-root': {
                    '&:hover fieldset': {
                      borderColor: 'primary.main',
                    },
                  },
                }}
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
                sx={{
                  '& .MuiOutlinedInput-root': {
                    '&:hover fieldset': {
                      borderColor: 'primary.main',
                    },
                  },
                }}
              />

              <Button
                fullWidth
                size="large"
                type="submit"
                variant="contained"
                disabled={loginMutation.isPending}
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
                {loginMutation.isPending ? '로그인 중...' : '로그인'}
              </Button>
            </Stack>
          </form>

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
