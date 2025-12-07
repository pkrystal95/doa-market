'use client';

import { useState } from 'react';
import { Box, CssBaseline } from '@mui/material';
import { Sidebar } from '@/components/layout/sidebar';
import { Header } from '@/components/layout/header';

const DRAWER_WIDTH = 280;
const DRAWER_MINI_WIDTH = 88;

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const [mobileOpen, setMobileOpen] = useState(false);
  const [isMini, setIsMini] = useState(false);

  const handleDrawerToggle = () => {
    setMobileOpen(!mobileOpen);
  };

  const handleMiniToggle = () => {
    setIsMini(!isMini);
  };

  return (
    <Box sx={{ display: 'flex', minHeight: '100vh' }}>
      <CssBaseline />
      
      {/* Header */}
      <Header
        onMenuClick={handleDrawerToggle}
        isMini={isMini}
        onToggleMini={handleMiniToggle}
      />

      {/* Sidebar */}
      <Sidebar
        open={mobileOpen}
        isMini={isMini}
        onToggle={handleDrawerToggle}
      />

      {/* Main Content */}
      <Box
        component="main"
        sx={{
          flexGrow: 1,
          p: 3,
          mt: 8,
          ml: { md: isMini ? `${DRAWER_MINI_WIDTH}px` : `${DRAWER_WIDTH}px` },
          width: { md: isMini ? `calc(100% - ${DRAWER_MINI_WIDTH}px)` : `calc(100% - ${DRAWER_WIDTH}px)` },
          transition: (theme) =>
            theme.transitions.create(['margin', 'width'], {
              easing: theme.transitions.easing.sharp,
              duration: theme.transitions.duration.enteringScreen,
            }),
          bgcolor: 'background.default',
          minHeight: 'calc(100vh - 64px)',
        }}
      >
        {children}
      </Box>
    </Box>
  );
}

