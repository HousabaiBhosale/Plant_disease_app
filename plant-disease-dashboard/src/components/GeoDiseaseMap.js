import React from 'react';
import { Paper, Box, Typography } from '@mui/material';
import { ScatterChart, Scatter, XAxis, YAxis, Tooltip, ResponsiveContainer, ZAxis } from 'recharts';
import PublicIcon from '@mui/icons-material/Public';

// Mock Geo Data (Lat/Lng mapped to arbitrary X/Y for a scatter plot to simulate a map)
const geoData = [
  { x: 20, y: 50, z: 200, name: 'North Region', disease: 'Late Blight', fill: '#EF4444' },
  { x: 30, y: 70, z: 100, name: 'East Region', disease: 'Early Blight', fill: '#F59E0B' },
  { x: 70, y: 30, z: 300, name: 'South Region', disease: 'Leaf Mold', fill: '#2563EB' },
  { x: 50, y: 40, z: 150, name: 'Central Region', disease: 'Healthy', fill: '#22C55E' },
  { x: 80, y: 60, z: 250, name: 'West Region', disease: 'Powdery Mildew', fill: '#8B5CF6' },
];

const CustomTooltip = ({ active, payload }) => {
  if (active && payload && payload.length) {
    const data = payload[0].payload;
    return (
      <Box sx={{ bgcolor: 'rgba(15, 23, 42, 0.9)', p: 1.5, borderRadius: 2, color: 'white', border: `2px solid ${data.fill}` }}>
        <Typography variant="subtitle2" fontWeight="bold">{data.name}</Typography>
        <Typography variant="body2">{data.disease}</Typography>
        <Typography variant="caption" sx={{ color: '#94A3B8' }}>Detections: {data.z}</Typography>
      </Box>
    );
  }
  return null;
};

export default function GeoDiseaseMap() {
  return (
    <Paper className="glass-card" sx={{ p: 3, borderRadius: 4, height: '100%', position: 'relative', overflow: 'hidden' }}>
      {/* Background SVG to look like a map grid */}
      <Box sx={{ position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, opacity: 0.05, backgroundSize: '20px 20px', backgroundImage: 'linear-gradient(to right, #0F172A 1px, transparent 1px), linear-gradient(to bottom, #0F172A 1px, transparent 1px)' }} />
      
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={2} position="relative" zIndex={2}>
        <Box display="flex" alignItems="center" gap={1.5}>
          <PublicIcon sx={{ color: '#2563EB' }} />
          <Typography variant="h6" sx={{ fontWeight: 800, color: '#0F172A' }}>Geo Disease Outbreaks</Typography>
        </Box>
        <Typography variant="caption" sx={{ bgcolor: '#EFF6FF', color: '#2563EB', px: 1.5, py: 0.5, borderRadius: 2, fontWeight: 700 }}>
          LIVE
        </Typography>
      </Box>
      
      <Box sx={{ width: '100%', height: 300, position: 'relative', zIndex: 2 }}>
        <ResponsiveContainer width="100%" height="100%">
          <ScatterChart margin={{ top: 20, right: 20, bottom: 20, left: 20 }}>
            <XAxis type="number" dataKey="x" hide domain={[0, 100]} />
            <YAxis type="number" dataKey="y" hide domain={[0, 100]} />
            <ZAxis type="number" dataKey="z" range={[100, 1000]} />
            <Tooltip content={<CustomTooltip />} cursor={{ strokeDasharray: '3 3' }} />
            <Scatter name="Regions" data={geoData} fill="#8884d8" animationDuration={1500} />
          </ScatterChart>
        </ResponsiveContainer>
      </Box>
    </Paper>
  );
}
