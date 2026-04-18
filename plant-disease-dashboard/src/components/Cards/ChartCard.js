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
      sx={{ height: '100%' }}
    >
      <CardHeader
        title={
          <Typography variant="h6" sx={{ fontWeight: 700, color: '#0f172a' }}>
            {title}
          </Typography>
        }
        subheader={
          <Typography variant="caption" sx={{ color: '#64748b' }}>
            {subtitle}
          </Typography>
        }
        action={
          <IconButton onClick={handleClick}>
            <MoreVertIcon />
          </IconButton>
        }
      />
      <CardContent>
        <Box sx={{ height, width: '100%' }}>
          {children}
        </Box>
      </CardContent>
      <Menu anchorEl={anchorEl} open={Boolean(anchorEl)} onClose={handleClose}>
        <MenuItem onClick={handleClose}>Last 7 days</MenuItem>
        <MenuItem onClick={handleClose}>Last 14 days</MenuItem>
        <MenuItem onClick={handleClose}>Last 30 days</MenuItem>
        <MenuItem onClick={handleClose}>Export Data</MenuItem>
      </Menu>
    </MotionCard>
  );
}
