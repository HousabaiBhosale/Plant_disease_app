import React from 'react';
import { PieChart, Pie, Cell, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { Box, Typography } from '@mui/material';

const COLORS = ['#1e3c72', '#3b82f6', '#10b981', '#f59e0b', '#8b5cf6', '#ec4899', '#06b6d4', '#f43f5e', '#6366f1', '#14b8a6'];

const CustomTooltip = ({ active, payload }) => {
  if (active && payload && payload.length) {
    return (
      <Box sx={{ bgcolor: 'rgba(255, 255, 255, 0.95)', p: 2, borderRadius: 3, boxShadow: '0 8px 32px rgba(0,0,0,0.1)', border: '1px solid #e2e8f0' }}>
        <Typography variant="body2" sx={{ fontWeight: 800, color: payload[0].color, mb: 0.5 }}>{payload[0].name}</Typography>
        <Typography variant="caption" sx={{ fontWeight: 600, color: '#475569' }}>Detections: {payload[0].value}</Typography>
      </Box>
    );
  }
  return null;
};

export default function DiseaseBarChart({ data }) {
  if (!data || data.length === 0) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" height="100%">
        <Typography color="textSecondary">No data available</Typography>
      </Box>
    );
  }

  return (
    <ResponsiveContainer width="100%" height="100%">
      <PieChart>
        <Pie
          data={data}
          cx="50%"
          cy="45%"
          innerRadius={70}
          outerRadius={100}
          paddingAngle={5}
          dataKey="count"
          nameKey="name"
          stroke="none"
          animationDuration={1500}
          label
        >
          {data.map((entry, index) => (
            <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
          ))}
        </Pie>
        <Tooltip content={<CustomTooltip />} />
        <Legend 
          verticalAlign="bottom" 
          height={36}
          iconType="circle"
          wrapperStyle={{ fontWeight: 600, fontSize: '13px', paddingTop: '20px' }}
        />
      </PieChart>
    </ResponsiveContainer>
  );
}
