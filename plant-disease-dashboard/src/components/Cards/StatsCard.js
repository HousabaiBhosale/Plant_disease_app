import React from 'react';
import { Card, CardContent, Typography, Box } from '@mui/material';
import { motion } from 'framer-motion';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import TrendingDownIcon from '@mui/icons-material/TrendingDown';
import { LineChart, Line, ResponsiveContainer, YAxis } from 'recharts';

const MotionCard = motion(Card);

export default function StatsCard({ title, value, icon, color, trend, trendValue, subtitle, chartData = [] }) {
  const isPositive = trend === 'up';
  
  // Mock some chart data if none provided to demonstrate sparklines
  const data = chartData.length > 0 ? chartData : [
    { value: 10 }, { value: 15 }, { value: 12 }, { value: 25 }, { value: 20 }, { value: 30 }
  ];

  return (
    <MotionCard
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      whileHover={{ y: -4, boxShadow: '0 12px 24px rgba(0,0,0,0.1)' }}
      transition={{ duration: 0.3 }}
      className="glass-card"
      sx={{
        height: '100%',
        borderRadius: '24px', 
        position: 'relative',
        overflow: 'hidden',
        border: '1px solid rgba(255, 255, 255, 0.6) !important',
      }}
    >
      <CardContent sx={{ p: 3 }}>
        <Box display="flex" justifyContent="space-between" alignItems="flex-start" mb={2}>
          <Box
            sx={{
              background: `linear-gradient(135deg, ${color}20 0%, ${color}10 100%)`,
              borderRadius: 3,
              padding: 1.5,
              display: 'flex',
              boxShadow: `0 8px 16px ${color}15`
            }}
          >
            {icon}
          </Box>
          <Box 
            display="flex" 
            flexDirection="column"
            alignItems="flex-end"
            gap={0.5} 
          >
            {trend && (
              <Box 
                display="flex" 
                alignItems="center" 
                gap={0.5} 
                sx={{ 
                  bgcolor: isPositive ? '#ecfdf5' : '#fef2f2', 
                  px: 1.5, 
                  py: 0.5, 
                  borderRadius: 2,
                  border: `1px solid ${isPositive ? '#22C55E20' : '#EF444420'}`
                }}
              >
                {isPositive ? (
                  <TrendingUpIcon sx={{ fontSize: 16, color: '#22C55E' }} />
                ) : (
                  <TrendingDownIcon sx={{ fontSize: 16, color: '#EF4444' }} />
                )}
                <Typography
                  variant="caption"
                  sx={{
                    color: isPositive ? '#22C55E' : '#EF4444',
                    fontWeight: 700,
                  }}
                >
                  {isPositive ? '+' : '-'}{trendValue}%
                </Typography>
              </Box>
            )}
            {trend && (
              <Typography variant="caption" sx={{ color: '#64748b', fontSize: '0.7rem' }}>
                from last week
              </Typography>
            )}
          </Box>
        </Box>

        <Box display="flex" justifyContent="space-between" alignItems="flex-end">
          <Box>
            <Typography variant="caption" sx={{ color: '#64748b', fontWeight: 600, letterSpacing: 1, textTransform: 'uppercase' }}>
              {title}
            </Typography>
            <Typography variant="h3" sx={{ fontWeight: 800, mt: 0.5, color: '#0F172A' }}>
              {value}
            </Typography>
            {subtitle && (
              <Typography variant="caption" sx={{ color: '#94a3b8', mt: 1, display: 'block' }}>
                {subtitle}
              </Typography>
            )}
          </Box>
          
          <Box sx={{ width: 90, height: 50, mb: 1 }}>
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={data}>
                <YAxis domain={['dataMin - 5', 'dataMax + 5']} hide />
                <Line 
                  type="monotone" 
                  dataKey="value" 
                  stroke={isPositive ? '#22C55E' : '#EF4444'} 
                  strokeWidth={3} 
                  dot={false}
                  isAnimationActive={true}
                />
              </LineChart>
            </ResponsiveContainer>
          </Box>
        </Box>
      </CardContent>
    </MotionCard>
  );
}
