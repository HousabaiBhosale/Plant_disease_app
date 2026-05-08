import React from 'react';
import { Card, CardContent, CardHeader, Typography, Box, IconButton, Menu, MenuItem } from '@mui/material';
import MoreVertIcon from '@mui/icons-material/MoreVert';
import { motion } from 'framer-motion';

const MotionCard = motion(Card);

export default function ChartCard({ title, subtitle, children, height = 400 }) {
  const [anchorEl, setAnchorEl] = React.useState(null);
  
  const handleClick = (event) => setAnchorEl(event.currentTarget);
  const handleClose = () => setAnchorEl(null);
  
  return (
    <MotionCard
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ duration: 0.4 }}
      className="glass-card"
      sx={{ 
        height: '100%', 
        borderRadius: 4,
        border: '1px solid rgba(255, 255, 255, 0.4) !important',
      }}
    >
      <CardHeader
        title={
          <Typography variant="h6" sx={{ fontWeight: 800, color: '#1e293b' }}>
            {title}
          </Typography>
        }
        subheader={
          <Typography variant="caption" sx={{ color: '#64748b', fontWeight: 500 }}>
            {subtitle}
          </Typography>
        }
        action={
          <IconButton onClick={handleClick} sx={{ color: '#64748b' }}>
            <MoreVertIcon />
          </IconButton>
        }
        sx={{ borderBottom: '1px solid rgba(0,0,0,0.05)', pb: 2 }}
      />
      <CardContent sx={{ pt: 3 }}>
        <Box sx={{ height, width: '100%' }}>
          {children}
        </Box>
      </CardContent>
      <Menu anchorEl={anchorEl} open={Boolean(anchorEl)} onClose={handleClose} PaperProps={{ sx: { borderRadius: 3, boxShadow: '0 8px 32px rgba(0,0,0,0.1)' } }}>
        <MenuItem onClick={handleClose}>Last 7 days</MenuItem>
        <MenuItem onClick={handleClose}>Last 30 days</MenuItem>
        <MenuItem onClick={handleClose}>Export Report</MenuItem>
      </Menu>
    </MotionCard>
  );
}
