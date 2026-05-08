import React, { useEffect } from 'react';
import { Box, CssBaseline, Toolbar, useMediaQuery, useTheme } from '@mui/material';
import Sidebar from './Sidebar';
import Header from './Header';

const drawerWidth = 260;

export default function DashboardLayout({ children }) {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));
  const [open, setOpen] = React.useState(!isMobile);

  // Sync drawer state with screen size changes
  useEffect(() => {
    setOpen(!isMobile);
  }, [isMobile]);

  const handleDrawerToggle = () => {
    setOpen(!open);
  };

  return (
    <Box sx={{ display: 'flex', width: '100vw', minHeight: '100vh' }}>
      <CssBaseline />
      
      <Sidebar 
        open={open} 
        drawerWidth={drawerWidth} 
        handleDrawerToggle={handleDrawerToggle}
        variant={isMobile ? 'temporary' : 'permanent'}
      />

      {/* Main Area */}
      <Box 
        component="main"
        sx={{ 
          flexGrow: 1,
          minWidth: 0,
          minHeight: '100vh',
          display: 'flex', 
          flexDirection: 'column',
          width: isMobile ? '100%' : `calc(100% - ${drawerWidth}px)`,
        }}
      >
        
        {/* AppBar/Header */}
        <Header open={open} handleDrawerToggle={handleDrawerToggle} />
        <Toolbar /> {/* Prevents overlap from fixed Header */}

        {/* Page Content */}
        <Box sx={{ flexGrow: 1, width: '100%', p: 3 }}>
          {children}
        </Box>
        
      </Box>
    </Box>
  );
}
