import React, { useState, useEffect } from 'react';
import { 
  Box, Typography, Grid, Paper, Table, TableBody, TableCell, 
  TableContainer, TableHead, TableRow, Chip, CircularProgress 
} from '@mui/material';
import { motion } from 'framer-motion';
import { 
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip as RechartsTooltip, 
  ResponsiveContainer, AreaChart, Area 
} from 'recharts';
import TimelineIcon from '@mui/icons-material/Timeline';
import BarChartIcon from '@mui/icons-material/BarChart';

import DashboardFilters from '../components/DashboardFilters';
import DiseaseBarChart from '../components/Charts/DiseaseBarChart';
import { dashboardAPI } from '../services/api';

import { useUI } from '../contexts/ThemeContext';

const MotionBox = motion(Box);
const COLORS = ['#2563EB', '#3b82f6', '#60a5fa', '#93c5fd', '#bfdbfe'];

export default function Analytics() {
  const { t } = useUI();
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState(null);
  const [dailyAnalytics, setDailyAnalytics] = useState([]);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [statsRes, analyticsRes] = await Promise.all([
          dashboardAPI.getStats(30),
          dashboardAPI.getDailyAnalytics(30)
        ]);
        setStats(statsRes.data);
        setDailyAnalytics(analyticsRes.data.daily_stats || []);
      } catch (err) {
        console.error('Failed to fetch analytics', err);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  if (loading) {
    return <Box display="flex" justifyContent="center" alignItems="center" minHeight="70vh"><CircularProgress /></Box>;
  }

  const diseaseData = stats?.top_diseases?.map(d => ({
    name: d.disease.split('___').pop()?.replace(/_/g, ' ') || d.disease,
    count: d.count,
    avg_confidence: parseFloat(d.avg_confidence) || 0
  })) || [];

  const top5 = diseaseData.slice(0, 5);

  return (
    <Box sx={{ width: '100%', pb: 6 }}>
      
      <Box mb={4}>
        <Typography variant="h4" sx={{ fontWeight: 800, color: '#0F172A', mb: 1 }}>
          {t('analytics')}
        </Typography>
        <Typography variant="body2" color="textSecondary" sx={{ mb: 3 }}>
          {t('analyzeCropDisease')}
        </Typography>
        <DashboardFilters />
      </Box>

      <Grid container spacing={3} sx={{ width: '100%', mb: 4 }}>
        <Grid size={{ xs: 12, md: 6 }}>
          <Paper className="glass-card" sx={{ p: 3, borderRadius: '24px', height: 400, width: '100%' }}>
            <Typography variant="h6" sx={{ fontWeight: 800, mb: 1 }}>{t('overallDistribution')}</Typography>
            <Typography variant="caption" color="textSecondary" sx={{ mb: 2, display: 'block' }}>{t('diseasePercentage')}</Typography>
            <Box sx={{ height: 300 }}>
              <DiseaseBarChart data={diseaseData} />
            </Box>
          </Paper>
        </Grid>
        
        <Grid size={{ xs: 12, md: 6 }}>
          <Paper className="glass-card" sx={{ p: 3, borderRadius: '24px', height: 400, width: '100%' }}>
            <Box display="flex" alignItems="center" gap={1} mb={1}>
              <BarChartIcon sx={{ color: '#2563EB' }} />
              <Typography variant="h6" sx={{ fontWeight: 800 }}>{t('top5Diseases')}</Typography>
            </Box>
            <Typography variant="caption" color="textSecondary" sx={{ mb: 2, display: 'block' }}>{t('highestFrequency')}</Typography>
            <Box sx={{ height: 300 }}>
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={top5} layout="vertical" margin={{ top: 5, right: 30, left: 120, bottom: 5 }}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" horizontal={false} />
                  <XAxis type="number" stroke="#94a3b8" />
                  <YAxis type="category" dataKey="name" width={120} stroke="#94a3b8" tick={{ fontSize: 12, fontWeight: 600 }} />
                  <RechartsTooltip cursor={{ fill: '#f8fafc' }} contentStyle={{ borderRadius: '12px', border: '1px solid #e2e8f0', boxShadow: '0 4px 12px rgba(0,0,0,0.05)' }} />
                  <Bar dataKey="count" fill="#2563EB" radius={[0, 4, 4, 0]} barSize={32} />
                </BarChart>
              </ResponsiveContainer>
            </Box>
          </Paper>
        </Grid>
      </Grid>

      <Grid container spacing={3} sx={{ width: '100%', mb: 4 }}>
        <Grid size={{ xs: 12 }}>
          <Paper className="glass-card" sx={{ p: 3, borderRadius: '24px', width: '100%' }}>
            <Box display="flex" alignItems="center" gap={1} mb={3}>
              <TimelineIcon sx={{ color: '#22C55E' }} />
              <Typography variant="h6" sx={{ fontWeight: 800 }}>{t('casesOverTime')}</Typography>
            </Box>
            <Box sx={{ height: 350, width: '100%', position: 'relative' }}>
              {dailyAnalytics.length === 0 || dailyAnalytics.every(d => d.predictions === 0) ? (
                <Box 
                  display="flex" 
                  flexDirection="column" 
                  alignItems="center" 
                  justifyContent="center" 
                  height="100%"
                  sx={{ bgcolor: '#f8fafc', borderRadius: '16px', border: '2px dashed #e2e8f0' }}
                >
                  <TimelineIcon sx={{ fontSize: 48, color: '#cbd5e1', mb: 1 }} />
                  <Typography variant="h6" color="textSecondary" sx={{ fontWeight: 700 }}>{t('noActivity')}</Typography>
                  <Typography variant="body2" color="textSecondary">{t('startScanningPrompt')}</Typography>
                </Box>
              ) : (
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={dailyAnalytics} margin={{ top: 10, right: 30, left: 0, bottom: 0 }}>
                    <defs>
                      <linearGradient id="colorPredictions" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#2563EB" stopOpacity={0.3}/>
                        <stop offset="95%" stopColor="#2563EB" stopOpacity={0}/>
                      </linearGradient>
                    </defs>
                    <XAxis dataKey="date" stroke="#94a3b8" />
                    <YAxis stroke="#94a3b8" />
                    <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" vertical={false} />
                    <RechartsTooltip contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 4px 12px rgba(0,0,0,0.1)' }} />
                    <Area type="monotone" dataKey="predictions" stroke="#2563EB" strokeWidth={3} fillOpacity={1} fill="url(#colorPredictions)" />
                  </AreaChart>
                </ResponsiveContainer>
              )}
            </Box>
          </Paper>
        </Grid>
      </Grid>

      <Grid container spacing={3} sx={{ width: '100%' }}>
        <Grid size={{ xs: 12 }}>
          <Paper className="glass-card" sx={{ p: 3, borderRadius: '24px', width: '100%' }}>
            <Typography variant="h6" sx={{ fontWeight: 800, mb: 3 }}>{t('diseaseBreakdown')}</Typography>
            <TableContainer sx={{ width: '100%' }}>
              <Table size="medium">
                <TableHead>
                  <TableRow>
                    <TableCell sx={{ fontWeight: 700, color: '#64748b', borderBottom: '2px solid #f1f5f9' }}>{t('diseaseName')}</TableCell>
                    <TableCell sx={{ fontWeight: 700, color: '#64748b', borderBottom: '2px solid #f1f5f9' }}>{t('totalDetections')}</TableCell>
                    <TableCell sx={{ fontWeight: 700, color: '#64748b', borderBottom: '2px solid #f1f5f9' }}>{t('avgConfidence')}</TableCell>
                    <TableCell sx={{ fontWeight: 700, color: '#64748b', borderBottom: '2px solid #f1f5f9' }}>{t('trend')}</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {diseaseData.map((row, idx) => (
                    <TableRow key={idx} hover sx={{ '&:last-child td': { border: 0 } }}>
                      <TableCell sx={{ fontWeight: 600, color: '#0F172A' }}>{row.name}</TableCell>
                      <TableCell>{row.count}</TableCell>
                      <TableCell>
                        <Chip 
                          label={`${row.avg_confidence.toFixed(1)}%`} 
                          size="small" 
                          sx={{ bgcolor: '#EFF6FF', color: '#2563EB', fontWeight: 700, borderRadius: 1.5 }} 
                        />
                      </TableCell>
                      <TableCell>
                        <Typography variant="caption" sx={{ color: '#22C55E', fontWeight: 700 }}>{t('stable')}</Typography>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          </Paper>
        </Grid>
      </Grid>
    </Box>
  );
}
