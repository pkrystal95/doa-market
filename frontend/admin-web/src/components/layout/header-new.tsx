'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import {
  AppBar,
  Box,
  Toolbar,
  IconButton,
  Typography,
  Badge,
  Menu,
  MenuItem,
  Avatar,
  Divider,
  ListItemIcon,
  ListItemText,
  InputBase,
  alpha,
  Stack,
  Tooltip,
} from '@mui/material';
import {
  Menu as MenuIcon,
  Search as SearchIcon,
  Notifications as NotificationsIcon,
  AccountCircle,
  Settings,
  Logout,
  ChevronLeft,
  ChevronRight,
  LightMode,
  DarkMode,
} from '@mui/icons-material';
import { useAuthStore } from '@/store/auth-store';

const DRAWER_WIDTH = 280;
const DRAWER_MINI_WIDTH = 88;

interface HeaderProps {
  onMenuClick: () => void;
  isMini: boolean;
  onToggleMini: () => void;
}

export function HeaderNew({ onMenuClick, isMini, onToggleMini }: HeaderProps) {
  const router = useRouter();
  const { user, clearAuth } = useAuthStore();
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const [notificationAnchor, setNotificationAnchor] = useState<null | HTMLElement>(null);

  const handleProfileMenuOpen = (event: React.MouseEvent<HTMLElement>) => {
    setAnchorEl(event.currentTarget);
  };

  const handleNotificationMenuOpen = (event: React.MouseEvent<HTMLElement>) => {
    setNotificationAnchor(event.currentTarget);
  };

  const handleMenuClose = () => {
    setAnchorEl(null);
    setNotificationAnchor(null);
  };

  const handleLogout = () => {
    clearAuth();
    router.push('/login');
  };

  return (
    <AppBar
      position="fixed"
      elevation={0}
      sx={{
        zIndex: (theme) => theme.zIndex.drawer + 1,
        bgcolor: 'background.paper',
        color: 'text.primary',
        borderBottom: (theme) => `1px solid ${theme.palette.divider}`,
      }}
    >
      <Toolbar>
        {/* Mobile Menu Button */}
        <IconButton
          edge="start"
          color="inherit"
          aria-label="menu"
          onClick={onMenuClick}
          sx={{ mr: 2, display: { md: 'none' } }}
        >
          <MenuIcon />
        </IconButton>

        {/* Logo */}
        <Stack direction="row" spacing={1.5} alignItems="center" sx={{ mr: 3 }}>
          <Avatar
            sx={{
              width: 40,
              height: 40,
              bgcolor: 'primary.main',
              fontWeight: 700,
            }}
          >
            D
          </Avatar>
          <Box sx={{ display: { xs: 'none', sm: 'block' } }}>
            <Typography variant="h6" sx={{ fontWeight: 700, lineHeight: 1.2 }}>
              DOA Market
            </Typography>
            <Typography variant="caption" color="text.secondary">
              Admin
            </Typography>
          </Box>
        </Stack>

        {/* Desktop Mini Toggle Button */}
        <Tooltip title={isMini ? '사이드바 펼치기' : '사이드바 접기'}>
          <IconButton
            color="inherit"
            onClick={onToggleMini}
            sx={{ mr: 2, display: { xs: 'none', md: 'inline-flex' } }}
          >
            {isMini ? <ChevronRight /> : <ChevronLeft />}
          </IconButton>
        </Tooltip>

        {/* Search Bar */}
        <Box
          sx={{
            position: 'relative',
            borderRadius: 1.5,
            backgroundColor: (theme) => alpha(theme.palette.grey[500], 0.08),
            '&:hover': {
              backgroundColor: (theme) => alpha(theme.palette.grey[500], 0.12),
            },
            marginLeft: 0,
            width: { xs: 'auto', sm: '400px' },
          }}
        >
          <Box
            sx={{
              padding: (theme) => theme.spacing(0, 2),
              height: '100%',
              position: 'absolute',
              pointerEvents: 'none',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <SearchIcon sx={{ color: 'text.secondary' }} />
          </Box>
          <InputBase
            placeholder="검색..."
            sx={{
              color: 'inherit',
              width: '100%',
              '& .MuiInputBase-input': {
                padding: (theme) => theme.spacing(1, 1, 1, 0),
                paddingLeft: (theme) => `calc(1em + ${theme.spacing(4)})`,
                transition: (theme) => theme.transitions.create('width'),
                width: '100%',
              },
            }}
          />
        </Box>

        <Box sx={{ flexGrow: 1 }} />

        {/* Right Side Actions */}
        <Stack direction="row" spacing={1} alignItems="center">
          {/* Theme Toggle */}
          <Tooltip title="테마 변경">
            <IconButton color="inherit">
              <LightMode />
            </IconButton>
          </Tooltip>

          {/* Notifications */}
          <Tooltip title="알림">
            <IconButton color="inherit" onClick={handleNotificationMenuOpen}>
              <Badge badgeContent={4} color="error">
                <NotificationsIcon />
              </Badge>
            </IconButton>
          </Tooltip>

          {/* Profile */}
          <Tooltip title="프로필">
            <IconButton onClick={handleProfileMenuOpen} sx={{ p: 0.5 }}>
              <Avatar
                sx={{
                  width: 36,
                  height: 36,
                  bgcolor: 'primary.main',
                }}
              >
                {user?.name?.[0] || 'A'}
              </Avatar>
            </IconButton>
          </Tooltip>
        </Stack>

        {/* Profile Menu */}
        <Menu
          anchorEl={anchorEl}
          open={Boolean(anchorEl)}
          onClose={handleMenuClose}
          transformOrigin={{ horizontal: 'right', vertical: 'top' }}
          anchorOrigin={{ horizontal: 'right', vertical: 'bottom' }}
          PaperProps={{
            sx: {
              mt: 1.5,
              minWidth: 200,
            },
          }}
        >
          <Box sx={{ px: 2, py: 1.5 }}>
            <Typography variant="subtitle2">{user?.name || '관리자'}</Typography>
            <Typography variant="caption" color="text.secondary">
              {user?.email || 'admin@doamarket.com'}
            </Typography>
          </Box>
          <Divider />
          <MenuItem onClick={handleMenuClose}>
            <ListItemIcon>
              <AccountCircle fontSize="small" />
            </ListItemIcon>
            <ListItemText>내 프로필</ListItemText>
          </MenuItem>
          <MenuItem onClick={handleMenuClose}>
            <ListItemIcon>
              <Settings fontSize="small" />
            </ListItemIcon>
            <ListItemText>설정</ListItemText>
          </MenuItem>
          <Divider />
          <MenuItem onClick={handleLogout}>
            <ListItemIcon>
              <Logout fontSize="small" />
            </ListItemIcon>
            <ListItemText>로그아웃</ListItemText>
          </MenuItem>
        </Menu>

        {/* Notification Menu */}
        <Menu
          anchorEl={notificationAnchor}
          open={Boolean(notificationAnchor)}
          onClose={handleMenuClose}
          transformOrigin={{ horizontal: 'right', vertical: 'top' }}
          anchorOrigin={{ horizontal: 'right', vertical: 'bottom' }}
          PaperProps={{
            sx: {
              mt: 1.5,
              minWidth: 320,
              maxWidth: 360,
            },
          }}
        >
          <Box sx={{ px: 2, py: 1.5 }}>
            <Typography variant="subtitle2">알림</Typography>
          </Box>
          <Divider />
          <MenuItem onClick={handleMenuClose}>
            <Box>
              <Typography variant="body2">새로운 주문이 있습니다</Typography>
              <Typography variant="caption" color="text.secondary">
                5분 전
              </Typography>
            </Box>
          </MenuItem>
          <MenuItem onClick={handleMenuClose}>
            <Box>
              <Typography variant="body2">신규 판매자 승인 요청</Typography>
              <Typography variant="caption" color="text.secondary">
                1시간 전
              </Typography>
            </Box>
          </MenuItem>
          <MenuItem onClick={handleMenuClose}>
            <Box>
              <Typography variant="body2">새로운 리뷰가 등록되었습니다</Typography>
              <Typography variant="caption" color="text.secondary">
                2시간 전
              </Typography>
            </Box>
          </MenuItem>
          <Divider />
          <MenuItem onClick={handleMenuClose} sx={{ justifyContent: 'center' }}>
            <Typography variant="body2" color="primary">
              모든 알림 보기
            </Typography>
          </MenuItem>
        </Menu>
      </Toolbar>
    </AppBar>
  );
}

