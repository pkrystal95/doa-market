'use client';

import { usePathname, useRouter } from 'next/navigation';
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
} from '@mui/material';
import { navConfig } from './nav-config';

const DRAWER_WIDTH = 280;
const DRAWER_MINI_WIDTH = 88;

interface SidebarProps {
  open: boolean;
  isMini: boolean;
  onToggle: () => void;
}

export function SidebarNew({ open, isMini, onToggle }: SidebarProps) {
  const pathname = usePathname();
  const router = useRouter();


  const handleNavClick = (path: string) => {
    // Navigate to the path
    router.push(path);
    // Close mobile drawer on navigation
    if (open) {
      onToggle();
    }
  };

  const renderNavItems = () => (
    <List sx={{ px: isMini ? 1 : 2 }}>
      {navConfig.map((item) => {
        const isActive = pathname === item.path || pathname.startsWith(`${item.path}/`);
        const Icon = item.icon;

        return (
          <ListItem key={item.title} disablePadding sx={{ mb: 0.5 }}>
            <ListItemButton
              onClick={() => handleNavClick(item.path)}
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
        pt: 8, // Add padding top for header
      }}
    >
      <Box sx={{ flex: 1, overflowY: 'auto', overflowX: 'hidden', py: 2 }}>
        {renderNavItems()}
      </Box>
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
        onClose={onToggle}
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

