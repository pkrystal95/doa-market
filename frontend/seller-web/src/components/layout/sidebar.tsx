'use client';

import { usePathname } from 'next/navigation';
import Link from 'next/link';
import {
  Box,
  Drawer,
  List,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Typography,
  Badge,
  alpha,
  Avatar,
  Divider,
  Stack,
  Chip,
  Button,
} from '@mui/material';
import { navConfig } from './nav-config';

const DRAWER_WIDTH = 280;
const DRAWER_MINI_WIDTH = 88;

interface SidebarProps {
  open: boolean;
  isMini: boolean;
  onToggle: () => void;
}

export function Sidebar({ open, isMini }: SidebarProps) {
  const pathname = usePathname();

  const renderLogo = () => (
    <Box
      sx={{
        px: isMini ? 2 : 3,
        py: 3,
        display: 'flex',
        alignItems: 'center',
        justifyContent: isMini ? 'center' : 'flex-start',
      }}
    >
      {isMini ? (
        <Avatar
          sx={{
            width: 40,
            height: 40,
            bgcolor: 'primary.main',
            fontWeight: 700,
          }}
        >
          S
        </Avatar>
      ) : (
        <Stack direction="row" spacing={1.5} alignItems="center">
          <Avatar
            sx={{
              width: 40,
              height: 40,
              bgcolor: 'primary.main',
              fontWeight: 700,
            }}
          >
            S
          </Avatar>
          <Box>
            <Typography variant="h6" sx={{ fontWeight: 700, lineHeight: 1.2 }}>
              Seller Center
            </Typography>
            <Typography variant="caption" color="text.secondary">
              판매자 관리
            </Typography>
          </Box>
        </Stack>
      )}
    </Box>
  );

  const renderNavItems = () => (
    <List sx={{ px: isMini ? 1 : 2 }}>
      {navConfig.map((item) => {
        const isActive = pathname === item.path || pathname.startsWith(`${item.path}/`);
        const Icon = item.icon;

        return (
          <ListItem key={item.title} disablePadding sx={{ mb: 0.5 }}>
            <ListItemButton
              component={Link}
              href={item.path}
              sx={{
                minHeight: 48,
                borderRadius: 1.5,
                color: isActive ? 'primary.main' : 'text.secondary',
                bgcolor: isActive ? (theme) => alpha(theme.palette.primary.main, 0.08) : 'transparent',
                '&:hover': {
                  bgcolor: isActive
                    ? (theme) => alpha(theme.palette.primary.main, 0.16)
                    : (theme) => alpha(theme.palette.grey[500], 0.08),
                },
                justifyContent: isMini ? 'center' : 'flex-start',
                px: isMini ? 0 : 2,
              }}
            >
              <ListItemIcon
                sx={{
                  minWidth: isMini ? 'auto' : 40,
                  color: 'inherit',
                  justifyContent: 'center',
                }}
              >
                {item.badge ? (
                  <Badge badgeContent={item.badge} color="error">
                    <Icon />
                  </Badge>
                ) : (
                  <Icon />
                )}
              </ListItemIcon>

              {!isMini && (
                <ListItemText
                  primary={item.title}
                  primaryTypographyProps={{
                    fontSize: 14,
                    fontWeight: isActive ? 600 : 400,
                  }}
                />
              )}

              {!isMini && item.badge && (
                <Chip
                  label={item.badge}
                  size="small"
                  color="error"
                  sx={{ height: 20, fontSize: 11, fontWeight: 600 }}
                />
              )}
            </ListItemButton>
          </ListItem>
        );
      })}
    </List>
  );

  const drawer = (
    <Box
      sx={{
        height: '100%',
        display: 'flex',
        flexDirection: 'column',
        bgcolor: 'background.paper',
      }}
    >
      {renderLogo()}
      <Divider />
      <Box sx={{ flex: 1, overflowY: 'auto', overflowX: 'hidden', py: 2 }}>
        {renderNavItems()}
      </Box>
      
      {!isMini && (
        <>
          <Divider />
          <Box sx={{ p: 2 }}>
            <Box
              sx={{
                p: 2,
                borderRadius: 2,
                background: 'linear-gradient(135deg, #FFE4CC 0%, #FFB366 100%)',
              }}
            >
              <Typography variant="subtitle2" sx={{ mb: 0.5, color: 'primary.darker' }}>
                판매자 가이드
              </Typography>
              <Typography variant="caption" sx={{ color: 'primary.dark', display: 'block', mb: 1 }}>
                성공적인 판매를 위한 팁
              </Typography>
              <Button
                size="small"
                variant="contained"
                fullWidth
                sx={{ textTransform: 'none', fontWeight: 600 }}
              >
                가이드 보기
              </Button>
            </Box>
          </Box>
        </>
      )}
    </Box>
  );

  return (
    <>
      {/* Desktop Drawer */}
      <Drawer
        variant="permanent"
        sx={{
          display: { xs: 'none', md: 'block' },
          width: isMini ? DRAWER_MINI_WIDTH : DRAWER_WIDTH,
          flexShrink: 0,
          '& .MuiDrawer-paper': {
            width: isMini ? DRAWER_MINI_WIDTH : DRAWER_WIDTH,
            boxSizing: 'border-box',
            borderRight: (theme) => `1px solid ${theme.palette.divider}`,
            transition: (theme) =>
              theme.transitions.create('width', {
                easing: theme.transitions.easing.sharp,
                duration: theme.transitions.duration.enteringScreen,
              }),
          },
        }}
      >
        {drawer}
      </Drawer>

      {/* Mobile Drawer */}
      <Drawer
        variant="temporary"
        open={open}
        sx={{
          display: { xs: 'block', md: 'none' },
          '& .MuiDrawer-paper': {
            width: DRAWER_WIDTH,
            boxSizing: 'border-box',
          },
        }}
      >
        {drawer}
      </Drawer>
    </>
  );
}
