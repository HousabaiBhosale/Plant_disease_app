import React from 'react';
import {
  AppBar, Toolbar, IconButton, Badge, Avatar, Menu, MenuItem,
  Box, Typography, TextField, InputAdornment, Divider, ListItemIcon,
} from '@mui/material';
import MenuIcon from '@mui/icons-material/Menu';
import NotificationsIcon from '@mui/icons-material/Notifications';
import SearchIcon from '@mui/icons-material/Search';
import PersonIcon from '@mui/icons-material/Person';
import SettingsIcon from '@mui/icons-material/Settings';
import LogoutIcon from '@mui/icons-material/Logout';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';

export default function Header({ open, handleDrawerToggle }) {
  const [anchorEl, setAnchorEl] = React.useState(null);
  const [notifAnchor, setNotifAnchor] = React.useState(null);
  const navigate = useNavigate();
  const { user, logout } = useAuth();

  const handleMenu = (event) => setAnchorEl(event.currentTarget);
  const handleClose = () => setAnchorEl(null);
  const handleNotifOpen = (event) => setNotifAnchor(event.currentTarget);
  const handleNotifClose = () => setNotifAnchor(null);

  const handleProfile = () => {
    handleClose();
    navigate('/settings');
  };

  const handleAccountSettings = () => {
    handleClose();
    navigate('/settings');
  };

  const handleLogout = async () => {
    handleClose();
    await logout();
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
    <AppBar
      position="fixed"
      sx={{
        zIndex: (theme) => theme.zIndex.drawer + 1,
        background: 'rgba(255,255,255,0.95)',
        backdropFilter: 'blur(10px)',
        boxShadow: '0 1px 20px rgba(0,0,0,0.05)',
        borderBottom: '1px solid rgba(0,0,0,0.05)',
      }}
    >
      <Toolbar>
        <IconButton
          onClick={handleDrawerToggle}
          edge="start"
          sx={{ mr: 2, color: '#1e293b' }}
        >
          <MenuIcon />
        </IconButton>

        <Typography variant="h6" sx={{ flexGrow: 1, color: '#0f172a', fontWeight: 600 }}>
          Welcome back,{' '}
          <span style={{ color: '#1e3c72', fontWeight: 700 }}>
            {user?.name?.split(' ')[0] || 'Admin'}
          </span>
        </Typography>

        <TextField
          placeholder="Search..."
          size="small"
          sx={{
            width: 300,
            mr: 2,
            '& .MuiOutlinedInput-root': {
              borderRadius: 12,
              background: '#f8fafc',
            },
          }}
          InputProps={{
            startAdornment: (
              <InputAdornment position="start">
                <SearchIcon sx={{ color: '#94a3b8' }} />
              </InputAdornment>
            ),
          }}
        />

        <IconButton onClick={handleNotifOpen} sx={{ mr: 2 }}>
          <Badge badgeContent={3} color="error">
            <NotificationsIcon sx={{ color: '#475569' }} />
          </Badge>
        </IconButton>

        <IconButton onClick={handleMenu} id="header-avatar-btn">
          <Avatar sx={{ bgcolor: '#1e3c72', fontWeight: 700 }}>
            {getInitials(user?.name)}
          </Avatar>
        </IconButton>

        {/* User dropdown menu */}
        <Menu
          anchorEl={anchorEl}
          open={Boolean(anchorEl)}
          onClose={handleClose}
          PaperProps={{
            sx: {
              mt: 1,
              minWidth: 200,
              borderRadius: 3,
              boxShadow: '0 10px 40px rgba(0,0,0,0.12)',
              border: '1px solid rgba(0,0,0,0.05)',
            },
          }}
          transformOrigin={{ horizontal: 'right', vertical: 'top' }}
          anchorOrigin={{ horizontal: 'right', vertical: 'bottom' }}
        >
          {/* User info header */}
          <Box sx={{ px: 2, py: 1.5 }}>
            <Typography variant="subtitle2" sx={{ fontWeight: 700 }}>
              {user?.name || 'Admin User'}
            </Typography>
            <Typography variant="caption" sx={{ color: '#64748b' }}>
              {user?.email || 'admin@plantai.com'}
            </Typography>
          </Box>
          <Divider sx={{ my: 0.5 }} />

          <MenuItem onClick={handleProfile} id="menu-profile-btn">
            <ListItemIcon>
              <PersonIcon fontSize="small" sx={{ color: '#3b82f6' }} />
            </ListItemIcon>
            Profile
          </MenuItem>

          <MenuItem onClick={handleAccountSettings} id="menu-settings-btn">
            <ListItemIcon>
              <SettingsIcon fontSize="small" sx={{ color: '#8b5cf6' }} />
            </ListItemIcon>
            Account Settings
          </MenuItem>

          <Divider sx={{ my: 0.5 }} />

          <MenuItem onClick={handleLogout} id="menu-logout-btn" sx={{ color: '#ef4444' }}>
            <ListItemIcon>
              <LogoutIcon fontSize="small" sx={{ color: '#ef4444' }} />
            </ListItemIcon>
            Logout
          </MenuItem>
        </Menu>

        {/* Notifications dropdown */}
        <Menu anchorEl={notifAnchor} open={Boolean(notifAnchor)} onClose={handleNotifClose}>
          <MenuItem onClick={handleNotifClose}>📊 New prediction added</MenuItem>
          <MenuItem onClick={handleNotifClose}>🎯 Model accuracy improved</MenuItem>
          <MenuItem onClick={handleNotifClose}>📁 Dataset updated</MenuItem>
        </Menu>
      </Toolbar>
    </AppBar>
  );
}
