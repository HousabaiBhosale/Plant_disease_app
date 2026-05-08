import React, { useState, useEffect } from 'react';
import { 
  Box, Typography, Grid, Paper, Button, Divider, Table, 
  TableBody, TableCell, TableContainer, TableHead, TableRow, Chip 
} from '@mui/material';
import { motion } from 'framer-motion';
import { 
  LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip as RechartsTooltip, 
  ResponsiveContainer 
} from 'recharts';
import TimelineIcon from '@mui/icons-material/Timeline';
import PlayArrowIcon from '@mui/icons-material/PlayArrow';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';

import StatsCard from '../components/Cards/StatsCard';
import { dashboardAPI } from '../services/api';

import { useUI } from '../contexts/ThemeContext';

const MotionBox = motion(Box);

export default function ModelMonitoring() {
  const { t } = useUI();
  const [loading, setLoading] = useState(false);
  const [metrics, setMetrics] = useState(null);

  useEffect(() => {
    dashboardAPI.getModelMetrics().then(res => setMetrics(res.data)).catch(console.error);
  }, []);

  const handleRetrain = async () => {
    setLoading(true);
    try {
      await dashboardAPI.retrainModel();
      setTimeout(() => {
        alert('Model retraining completed successfully!');
        setLoading(false);
      }, 2000);
    } catch (err) {
      alert('Failed to trigger retraining');
      setLoading(false);
    }
  };

  const modelVersions = [
    { version: 'v1.1 (Current)', date: 'Mar 25, 2024', acc: '92.5%', status: 'Active' },
    { version: 'v1.0', date: 'Jan 10, 2024', acc: '88.0%', status: 'Deprecated' },
    { version: 'v0.9-beta', date: 'Dec 05, 2023', acc: '81.2%', status: 'Archived' },
  ];

  return (
    <Box sx={{ width: '100%', pb: 6 }}>
      
      <Box display="flex" justifyContent="space-between" alignItems="flex-end" mb={4}>
        <Box>
          <Typography variant="h4" sx={{ fontWeight: 800, color: '#0F172A', mb: 1 }}>
            {t('monitoring')}
          </Typography>
          <Typography variant="body2" color="textSecondary">
            {t('monitorPerformance')}
          </Typography>
        </Box>
        <Box display="flex" gap={2} alignItems="center">
          <Paper sx={{ px: 2, py: 1, display: 'flex', alignItems: 'center', gap: 1, borderRadius: 2, bgcolor: '#ECFDF5', border: '1px solid #A7F3D0', boxShadow: 'none' }}>
            <CheckCircleIcon sx={{ color: '#059669', fontSize: 20 }} />
            <Typography variant="body2" sx={{ color: '#065F46', fontWeight: 700 }}>{t('modelHealth')}: {t('good')}</Typography>
          </Paper>
          <Button
            variant="contained"
            startIcon={<PlayArrowIcon />}
            onClick={handleRetrain}
            disabled={loading}
            sx={{ borderRadius: 2, bgcolor: '#2563EB', fontWeight: 700, px: 3, py: 1 }}
          >
            {loading ? t('retraining') : t('retrainModel')}
          </Button>
        </Box>
      </Box>

      {/* Metrics Cards */}
      <Grid container spacing={3} sx={{ width: '100%', mb: 4 }}>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatsCard title={t('accuracy')} value={`${metrics?.accuracy || 0}%`} color="#22C55E" trend="up" trendValue="1.2" />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatsCard title={t('precision')} value={`${metrics?.precision || 0}%`} color="#2563EB" trend="up" trendValue="0.8" />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatsCard title={t('recall')} value={`${metrics?.recall || 0}%`} color="#8B5CF6" trend="up" trendValue="2.1" />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatsCard title={t('f1Score')} value={`${metrics?.f1_score || 0}%`} color="#F59E0B" trend="down" trendValue="0.3" />
        </Grid>
      </Grid>

      {/* Accuracy Trend Graph */}
      <Grid container spacing={3} sx={{ width: '100%', mb: 4 }}>
        <Grid size={{ xs: 12 }}>
          <Paper className="glass-card" sx={{ p: 3, borderRadius: '24px', width: '100%' }}>
            <Typography variant="h6" sx={{ fontWeight: 800, mb: 1 }}>{t('accuracyTrend')}</Typography>
            <Typography variant="caption" color="textSecondary" sx={{ mb: 3, display: 'block' }}>{t('performanceOverEpochs')}</Typography>
            <Box sx={{ height: 400, width: '100%', position: 'relative' }}>
              {!metrics?.history || metrics.history.length === 0 ? (
                <Box 
                  display="flex" 
                  flexDirection="column" 
                  alignItems="center" 
                  justifyContent="center" 
                  height="100%"
                  sx={{ bgcolor: '#f8fafc', borderRadius: '16px', border: '2px dashed #e2e8f0' }}
                >
                  <TimelineIcon sx={{ fontSize: 48, color: '#cbd5e1', mb: 1 }} />
                  <Typography variant="h6" color="textSecondary" sx={{ fontWeight: 700 }}>{t('noHistory')}</Typography>
                  <Typography variant="body2" color="textSecondary">{t('dataPopulated')}</Typography>
                </Box>
              ) : (
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={metrics?.history || []} margin={{ top: 10, right: 30, left: 0, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" vertical={false} />
                    <XAxis dataKey="epoch" stroke="#94a3b8" label={{ value: 'Epochs', position: 'insideBottomRight', offset: -5 }} />
                    <YAxis stroke="#94a3b8" domain={[0, 100]} />
                    <RechartsTooltip contentStyle={{ borderRadius: '12px', border: '1px solid #e2e8f0' }} />
                    <Line type="monotone" dataKey="accuracy" stroke="#22C55E" strokeWidth={3} dot={{ r: 4 }} activeDot={{ r: 6 }} name={t('accuracy') + " %"} />
                    <Line type="monotone" dataKey="loss" stroke="#EF4444" strokeWidth={3} dot={false} name="Loss" yAxisId={0} />
                  </LineChart>
                </ResponsiveContainer>
              )}
            </Box>
          </Paper>
        </Grid>
      </Grid>

      {/* Version History Table */}
      <Grid container spacing={3} sx={{ width: '100%' }}>
        <Grid size={{ xs: 12 }}>
          <Paper className="glass-card" sx={{ p: 3, borderRadius: '24px', width: '100%' }}>
            <Typography variant="h6" sx={{ fontWeight: 800, mb: 3 }}>{t('versionHistory')}</Typography>
            <TableContainer sx={{ width: '100%' }}>
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell sx={{ fontWeight: 700, color: '#64748b' }}>{t('version')}</TableCell>
                    <TableCell sx={{ fontWeight: 700, color: '#64748b' }}>{t('deployedDate')}</TableCell>
                    <TableCell sx={{ fontWeight: 700, color: '#64748b' }}>{t('accuracy')}</TableCell>
                    <TableCell sx={{ fontWeight: 700, color: '#64748b' }}>{t('status')}</TableCell>
                    <TableCell sx={{ fontWeight: 700, color: '#64748b' }} align="right">{t('action')}</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {modelVersions.map((row, idx) => (
                    <TableRow key={idx}>
                      <TableCell sx={{ fontWeight: 700, color: '#0F172A' }}>{row.version}</TableCell>
                      <TableCell>{row.date}</TableCell>
                      <TableCell>
                        <Typography sx={{ fontWeight: 700, color: row.acc.startsWith('9') ? '#22C55E' : '#2563EB' }}>{row.acc}</Typography>
                      </TableCell>
                      <TableCell>
                        <Chip 
                          label={row.status} 
                          size="small" 
                          sx={{ 
                            fontWeight: 700, 
                            borderRadius: 1.5,
                            bgcolor: row.status === 'Active' ? '#ECFDF5' : '#F1F5F9',
                            color: row.status === 'Active' ? '#059669' : '#64748B'
                          }} 
                        />
                      </TableCell>
                      <TableCell align="right">
                        <Button size="small" variant="text" disabled={row.status === 'Active'}>{t('rollback')}</Button>
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
