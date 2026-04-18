import React from 'react';
import { Card, CardContent, Typography, Box, LinearProgress } from '@mui/material';

export default function MetricCard({ title, value, maxValue, unit, color }) {
  const percentage = (value / maxValue) * 100;

  return (
    <Card>
      <CardContent>
        <Typography color="textSecondary" gutterBottom variant="caption">
          {title}
        </Typography>
        <Typography variant="h5" component="div" sx={{ fontWeight: 'bold' }}>
          {value} {unit}
        </Typography>
        <Box sx={{ mt: 2 }}>
          <LinearProgress
            variant="determinate"
            value={percentage}
            sx={{
              height: 8,
              borderRadius: 4,
              backgroundColor: `${color}20`,
              '& .MuiLinearProgress-bar': {
                backgroundColor: color,
                borderRadius: 4,
              },
            }}
          />
        </Box>
        <Typography variant="caption" color="textSecondary" sx={{ mt: 1, display: 'block' }}>
          Target: {maxValue} {unit}
        </Typography>
      </CardContent>
    </Card>
  );
}
