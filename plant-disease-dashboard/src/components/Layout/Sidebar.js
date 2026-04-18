import React from 'react';
import {
  Drawer, List, ListItem, ListItemButton, ListItemIcon, ListItemText,
  Box, Typography, Divider, Avatar, Stack,
} from '@mui/material';
import { useNavigate, useLocation } from 'react-router-dom';
import { motion } from 'framer-motion';
import DashboardIcon from '@mui/icons-material/Dashboard';
import AnalyticsIcon from '@mui/icons-material/Analytics';
import ModelTrainingIcon from '@mui/icons-material/ModelTraining';
import DatasetIcon from '@mui/icons-material/Dataset';
import FeedbackIcon from '@mui/icons-material/Feedback';
import SettingsIcon from '@mui/icons-material/Settings';
import AgricultureIcon from '@mui/icons-material/Agriculture';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import { useAuth } from '../../contexts/AuthContext';

const menuItems = [
  { text: 'Dashboard', icon: <DashboardIcon />, path: '/', color: '#3b82f6' },
  { text: 'Scan History', icon: <AnalyticsIcon />, path: '/analytics', color: '#10b981' },
  { text: 'Model Monitoring', icon: <ModelTrainingIcon />, path: '/model-monitoring', color: '#f59e0b' },
  { text: 'Dataset Management', icon: <DatasetIcon />, path: '/dataset', color: '#8b5cf6' },
  { text: 'Feedback', icon: <FeedbackIcon />, path: '/feedback', color: '#ef4444' },
  { text: 'Settings', icon: <SettingsIcon />, path: '/settings', color: '#64748b' },
];

export default function Sidebar({ open, drawerWidth, handleDrawerToggle, variant }) {
  const navigate = useNavigate();
  const location = useLocation();
  const { user } = useAuth();
  const isMobile = variant === 'temporary';

  const handleItemClick = (path) => {
    navigate(path);
    if (isMobile) {
      handleDrawerToggle();
    }
  };

  // Get initials from user name
  const getInitials = (name) => {
    if (!name) return 'A';
    const parts = name.split(' ');
    return parts.length > 1
      ? (parts[0][0] + parts[1][0]).toUpperCase()
      : parts[0][0].toUpperCase();
  };

  return (
    <Drawer
      variant={variant}
      open={open}
      onClose={handleDrawerToggle}
      sx={{
        width: drawerWidth,
        flexShrink: 0,
        [`& .MuiDrawer-paper`]: {
          width: drawerWidth,
          boxSizing: 'border-box',
          background: 'linear-gradient(180deg, #0f172a 0%, #1e293b 100%)',
          borderRight: 'none',
          boxShadow: '4px 0 20px rgba(0,0,0,0.1)',
        },
      }}
    >
      <Box sx={{ p: 3, display: 'flex', alignItems: 'center', gap: 1.5 }}>
        <AgricultureIcon sx={{ fontSize: 32, color: '#10b981' }} />
        <Typography variant="h6" sx={{ fontWeight: 800, color: 'white', letterSpacing: -0.5 }}>
          Plant<span style={{ color: '#10b981' }}>AI</span>
        </Typography>
      </Box>

      <Divider sx={{ backgroundColor: 'rgba(255,255,255,0.1)', my: 2 }} />

      <List sx={{ px: 2 }}>
        {menuItems.map((item, index) => (
          <motion.div
            key={item.text}
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: index * 0.05 }}
          >
            <ListItem disablePadding sx={{ mb: 1 }}>
              <ListItemButton
                onClick={() => handleItemClick(item.path)}
                selected={location.pathname === item.path}
                sx={{
                  borderRadius: 3,
                  py: 1.5,
                  '&.Mui-selected': {
                    background: `linear-gradient(90deg, ${item.color}20 0%, transparent 100%)`,
                    borderLeft: `3px solid ${item.color}`,
                  },
                  '&:hover': {
                    background: 'rgba(255,255,255,0.05)',
                  },
                }}
              >
                <ListItemIcon
                  sx={{
                    color: location.pathname === item.path ? item.color : 'rgba(255,255,255,0.6)',
                    minWidth: 40,
                  }}
                >
                  {item.icon}
                </ListItemIcon>
                <ListItemText
                  primary={item.text}
                  sx={{
                    '& .MuiTypography-root': {
                      color: location.pathname === item.path ? 'white' : 'rgba(255,255,255,0.7)',
                      fontWeight: location.pathname === item.path ? 600 : 400,
                    },
                  }}
                />
              </ListItemButton>
            </ListItem>
          </motion.div>
        ))}
      </List>

      <Box sx={{ flexGrow: 1 }} />

      <Box sx={{ p: 3, mt: 'auto' }}>
        <Stack spacing={2}>
          <Box
            sx={{
              background: 'rgba(255,255,255,0.05)',
              borderRadius: 3,
              p: 2,
              textAlign: 'center',
            }}
          >
            <Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.5)' }}>
              Model Accuracy
            </Typography>
            <Typography variant="h5" sx={{ color: '#10b981', fontWeight: 700 }}>
              87.3%
            </Typography>
            <TrendingUpIcon sx={{ fontSize: 16, color: '#10b981', ml: 1 }} />
          </Box>

          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <Avatar sx={{ width: 40, height: 40, bgcolor: '#10b981', fontWeight: 700 }}>
              {getInitials(user?.name)}
            </Avatar>
            <Box sx={{ overflow: 'hidden' }}>
              <Typography
                variant="body2"
                sx={{ color: 'white', fontWeight: 500 }}
                noWrap
              >
                {user?.name || 'Admin User'}
              </Typography>
              <Typography
                variant="caption"
                sx={{ color: 'rgba(255,255,255,0.5)' }}
                noWrap
              >
                {user?.email || 'admin@plantai.com'}
              </Typography>
            </Box>
          </Box>
        </Stack>
      </Box>
    </Drawer>
  );
}
