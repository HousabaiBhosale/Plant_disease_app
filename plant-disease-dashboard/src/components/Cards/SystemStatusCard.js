import React, { useState, useEffect } from 'react';
import { Paper, Box, Typography, Divider, CircularProgress } from '@mui/material';
import StorageIcon from '@mui/icons-material/Storage';
import ApiIcon from '@mui/icons-material/Api';
import MemoryIcon from '@mui/icons-material/Memory';
import { dashboardAPI } from '../../services/api';

import { useUI } from '../../contexts/ThemeContext';

const StatusRow = ({ icon, label, status, color }) => (
  <Box display="flex" justifyContent="space-between" alignItems="center" py={1.5}>
    <Box display="flex" alignItems="center" gap={1.5}>
      {icon}
      <Typography variant="body2" sx={{ fontWeight: 600, color: '#334155' }}>{label}</Typography>
    </Box>
    <Box display="flex" alignItems="center" gap={1}>
      <Box sx={{ width: 8, height: 8, borderRadius: '50%', bgcolor: color, boxShadow: `0 0 8px ${color}80` }} />
      <Typography variant="caption" sx={{ fontWeight: 700, color }}>{status}</Typography>
    </Box>
  </Box>
);

export default function SystemStatusCard() {
  const { t } = useUI();
  const [health, setHealth] = useState(null);
  const [loading, setLoading] = useState(true);

  const fetchHealth = async () => {
    try {
      const res = await dashboardAPI.getSystemHealth();
      setHealth(res.data);
    } catch (err) {
      setHealth({ status: 'error', database: 'error', model: 'error' });
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchHealth();
    const interval = setInterval(fetchHealth, 5000); // Update every 5s
    return () => clearInterval(interval);
  }, []);

  if (loading && !health) {
    return (
      <Paper className="glass-card" sx={{ p: 3, borderRadius: 4, height: '100%', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
        <CircularProgress size={24} />
      </Paper>
    );
  }

  const isHealthy = health?.status === 'healthy';
  const dbStatus = health?.database === 'connected' ? t('good') : t('disconnected');
  const modelStatus = health?.model === 'loaded' ? t('active') : t('offline');

  return (
    <Paper className="glass-card" sx={{ p: 3, borderRadius: 4, height: '100%', border: '1px solid rgba(255,255,255,0.6)' }}>
      <Typography variant="h6" sx={{ fontWeight: 800, mb: 2, color: '#0F172A' }}>
        {t('systemStatus')}
      </Typography>
      
      <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
        <StatusRow 
          icon={<MemoryIcon sx={{ color: '#2563EB' }} />} 
          label={t('inferenceEngine')} 
          status={modelStatus} 
          color={health?.model === 'loaded' ? "#22C55E" : "#EF4444"} 
        />
        <Divider sx={{ borderStyle: 'dashed' }} />
        <StatusRow 
          icon={<ApiIcon sx={{ color: '#8B5CF6' }} />} 
          label={t('apiGateway')} 
          status={isHealthy ? t('online') : t('connectionError')} 
          color={isHealthy ? "#22C55E" : "#EF4444"} 
        />
        <Divider sx={{ borderStyle: 'dashed' }} />
        <StatusRow 
          icon={<StorageIcon sx={{ color: '#0F172A' }} />} 
          label={t('primaryDatabase')} 
          status={dbStatus} 
          color={health?.database === 'connected' ? "#22C55E" : "#EF4444"} 
        />
      </Box>

      <Box mt={3} p={2} sx={{ bgcolor: isHealthy ? '#F0FDF4' : '#FEF2F2', borderRadius: 3, border: '1px solid', borderColor: isHealthy ? '#BBF7D0' : '#FECACA' }}>
        <Typography variant="caption" sx={{ color: isHealthy ? '#166534' : '#EF4444', fontWeight: 800, textTransform: 'uppercase' }}>
          {isHealthy ? t('systemPulse') : t('recentAlerts')}
        </Typography>
        <Typography variant="body2" sx={{ color: isHealthy ? '#14532D' : '#991B1B', mt: 0.5, fontWeight: 500 }}>
          {isHealthy 
            ? t('allSystemsHealthy') 
            : t('connectionIssues')}
        </Typography>
      </Box>
    </Paper>
  );
}
