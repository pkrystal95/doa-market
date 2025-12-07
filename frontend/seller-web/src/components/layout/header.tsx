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
  Store,
} from '@mui/icons-material';

const DRAWER_WIDTH = 280;
const DRAWER_MINI_WIDTH = 88;

interface HeaderProps {
  onMenuClick: () => void;
  isMini: boolean;
  onToggleMini: () => void;
}

export function Header({ onMenuClick, isMini, onToggleMini }: HeaderProps) {
  const router = useRouter();
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
        ml: { md: isMini ? `${DRAWER_MINI_WIDTH}px` : `${DRAWER_WIDTH}px` },
        width: { md: isMini ? `calc(100% - ${DRAWER_MINI_WIDTH}px)` : `calc(100% - ${DRAWER_WIDTH}px)` },
        transition: (theme) =>
          theme.transitions.create(['width', 'margin'], {
            easing: theme.transitions.easing.sharp,
            duration: theme.transitions.duration.enteringScreen,
          }),
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

        {/* Store Info */}
        <Stack direction="row" spacing={1} alignItems="center" sx={{ mr: 2 }}>
          <Store color="primary" />
          <Box>
            <Typography variant="subtitle2" sx={{ fontWeight: 600 }}>
              테크샵
            </Typography>
            <Typography variant="caption" color="text.secondary">
              판매자
            </Typography>
          </Box>
        </Stack>

        {/* Search Bar */}
        <Box
          sx={{
            position: 'relative',
            borderRadius: 1.5,
            backgroundColor: (theme) => alpha(theme.palette.grey[500], 0.08),
            '&:hover': {
              backgroundColor: (theme) => alpha(theme.palette.grey[500], 0.12),
            },
            marginLeft: 2,
            width: { xs: 'auto', sm: '300px' },
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
            placeholder="상품, 주문 검색..."
            sx={{
              color: 'inherit',
              width: '100%',
              '& .MuiInputBase-input': {
                padding: (theme) => theme.spacing(1, 1, 1, 0),
                paddingLeft: (theme) => `calc(1em + ${theme.spacing(4)})`,
                width: '100%',
              },
            }}
          />
        </Box>

        <Box sx={{ flexGrow: 1 }} />

        {/* Right Side Actions */}
        <Stack direction="row" spacing={1} alignItems="center">
          {/* Notifications */}
          <Tooltip title="알림">
            <IconButton color="inherit" onClick={handleNotificationMenuOpen}>
              <Badge badgeContent={11} color="error">
                <NotificationsIcon />
              </Badge>
            </IconButton>
          </Tooltip>

          {/* Profile */}
          <Tooltip title="내 정보">
            <IconButton onClick={handleProfileMenuOpen} sx={{ p: 0.5 }}>
              <Avatar
                sx={{
                  width: 36,
                  height: 36,
                  bgcolor: 'primary.main',
                }}
              >
                S
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
            <Typography variant="subtitle2">테크샵</Typography>
            <Typography variant="caption" color="text.secondary">
              seller@doamarket.com
            </Typography>
          </Box>
          <Divider />
          <MenuItem onClick={handleMenuClose}>
            <ListItemIcon>
              <Store fontSize="small" />
            </ListItemIcon>
            <ListItemText>내 스토어</ListItemText>
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
              minWidth: 340,
              maxWidth: 380,
            },
          }}
        >
          <Box sx={{ px: 2, py: 1.5, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <Typography variant="subtitle2">알림</Typography>
            <Badge badgeContent={11} color="error" />
          </Box>
          <Divider />
          {[
            { title: '새로운 주문이 8건 있습니다', time: '방금 전', type: 'order' },
            { title: '상품 문의가 3건 있습니다', time: '10분 전', type: 'inquiry' },
            { title: '재고 부족: 무선 마우스', time: '1시간 전', type: 'warning' },
            { title: '새로운 리뷰가 등록되었습니다', time: '2시간 전', type: 'review' },
          ].map((notification, index) => (
            <MenuItem key={index} onClick={handleMenuClose}>
              <Stack spacing={0.5} sx={{ flex: 1 }}>
                <Typography variant="body2">{notification.title}</Typography>
                <Typography variant="caption" color="text.secondary">
                  {notification.time}
                </Typography>
              </Stack>
            </MenuItem>
          ))}
          <Divider />
          <MenuItem onClick={handleMenuClose} sx={{ justifyContent: 'center' }}>
            <Typography variant="body2" color="primary" sx={{ fontWeight: 600 }}>
              모든 알림 보기
            </Typography>
          </MenuItem>
        </Menu>
      </Toolbar>
    </AppBar>
  );
}

