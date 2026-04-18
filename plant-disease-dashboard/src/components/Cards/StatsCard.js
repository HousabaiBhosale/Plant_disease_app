import React from 'react';
import { Card, CardContent, Typography, Box, IconButton, LinearProgress } from '@mui/material';
import { motion } from 'framer-motion';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import TrendingDownIcon from '@mui/icons-material/TrendingDown';

const MotionCard = motion(Card);

export default function StatsCard({ title, value, icon, color, trend, trendValue, subtitle }) {
  const isPositive = trend === 'up';
  
  return (
    <MotionCard
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
      sx={{
        height: '100%',
        background: `linear-gradient(135deg, ${color}10 0%, ${color}05 100%)`,
        borderLeft: `4px solid ${color}`,
        position: 'relative',
        overflow: 'hidden',
      }}
    >
      <CardContent>
        <Box display="flex" justifyContent="space-between" alignItems="flex-start">
          <Box>
            <Typography variant="caption" sx={{ color: '#64748b', fontWeight: 500, letterSpacing: 1 }}>
              {title}
            </Typography>
            <Typography variant="h3" sx={{ fontWeight: 800, mt: 1, mb: 0.5, color: '#0f172a' }}>
              {value}
            </Typography>
            {subtitle && (
              <Typography variant="caption" sx={{ color: '#64748b' }}>
                {subtitle}
              </Typography>
            )}
            {trend && (
              <Box display="flex" alignItems="center" gap={0.5} mt={1}>
                {isPositive ? (
                  <TrendingUpIcon sx={{ fontSize: 16, color: '#10b981' }} />
                ) : (
                  <TrendingDownIcon sx={{ fontSize: 16, color: '#ef4444' }} />
                )}
                <Typography
                  variant="caption"
                  sx={{
                    color: isPositive ? '#10b981' : '#ef4444',
                    fontWeight: 600,
                  }}
                >
                  {trendValue}% from last week
                </Typography>
              </Box>
            )}
          </Box>
          <Box
            sx={{
              background: `linear-gradient(135deg, ${color}20 0%, ${color}10 100%)`,
              borderRadius: '50%',
              padding: 1.5,
              display: 'flex',
            }}
          >
            {icon}
          </Box>
        </Box>
      </CardContent>
    </MotionCard>
  );
}
