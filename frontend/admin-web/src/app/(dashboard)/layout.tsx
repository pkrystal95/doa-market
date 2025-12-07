'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { Box, CssBaseline } from '@mui/material';
import { useAuthStore } from '@/store/auth-store';
import { SidebarNew } from '@/components/layout/sidebar-new';
import { HeaderNew } from '@/components/layout/header-new';

const DRAWER_WIDTH = 280;
const DRAWER_MINI_WIDTH = 88;

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const router = useRouter();
  const { user } = useAuthStore();
  const [mobileOpen, setMobileOpen] = useState(false);
  const [isMini, setIsMini] = useState(false);

  useEffect(() => {
    if (!user) {
      router.push('/login');
    }
  }, [user, router]);

  const handleDrawerToggle = () => {
    setMobileOpen(!mobileOpen);
  };

  const handleMiniToggle = () => {
    setIsMini(!isMini);
  };

  if (!user) {
    return null;
  }

  return (
    <Box sx={{ display: 'flex', minHeight: '100vh' }}>
      <CssBaseline />
      
      {/* Header */}
      <HeaderNew
        onMenuClick={handleDrawerToggle}
        isMini={isMini}
        onToggleMini={handleMiniToggle}
      />

      {/* Sidebar */}
      <SidebarNew
        open={mobileOpen}
        isMini={isMini}
        onToggle={handleDrawerToggle}
      />

      {/* Main Content */}
      <Box
        component="main"
        sx={{
          flexGrow: 1,
          p: { xs: 2, md: 2.5 },
          mt: 8,
          bgcolor: 'background.default',
          minHeight: 'calc(100vh - 64px)',
          width: '100%',
          maxWidth: '100%',
        }}
      >
        {children}
      </Box>
    </Box>
  );
}
