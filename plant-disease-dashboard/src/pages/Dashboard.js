import React, { useState, useEffect } from 'react';
import { 
  Grid, Box, Typography, Button, 
  Divider, LinearProgress, Skeleton
} from '@mui/material';
import { motion } from 'framer-motion';
import { useInView } from 'react-intersection-observer';
import DashboardIcon from '@mui/icons-material/Dashboard';
import SpeedIcon from '@mui/icons-material/Speed';
import DevicesIcon from '@mui/icons-material/Devices';
import PeopleIcon from '@mui/icons-material/People';
import PsychologyIcon from '@mui/icons-material/Psychology';
import TrainIcon from '@mui/icons-material/PlayArrow';
import DownloadIcon from '@mui/icons-material/Download';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';

import StatsCard from '../components/Cards/StatsCard';
import ChartCard from '../components/Cards/ChartCard';
import DiseaseBarChart from '../components/Charts/DiseaseBarChart';
import RecentScansTable from '../components/Tables/RecentScansTable';
import DashboardFilters from '../components/DashboardFilters';
import SystemStatusCard from '../components/Cards/SystemStatusCard';
import { dashboardAPI } from '../services/api';

import { useUI } from '../contexts/ThemeContext';

const MotionBox = motion(Box);
const MotionGrid = motion(Grid);

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { staggerChildren: 0.1 }
  }
};

const itemVariants = {
  hidden: { y: 20, opacity: 0 },
  visible: { y: 0, opacity: 1 }
};

export default function Dashboard() {
  const { t } = useUI();
  const [loading, setLoading] = useState(true);
  const [retraining, setRetraining] = useState(false);
  const [stats, setStats] = useState(null);
  const [dailyAnalytics, setDailyAnalytics] = useState([]);
  const [modelMetrics, setModelMetrics] = useState(null);
  const [recentPredictions, setRecentPredictions] = useState([]);
  const [ref, inView] = useInView({ triggerOnce: true });

  const fetchDashboardData = async () => {
    try {
      const [statsRes, analyticsRes, modelRes, predictionsRes] = await Promise.all([
        dashboardAPI.getStats(30),
        dashboardAPI.getDailyAnalytics(30),
        dashboardAPI.getModelMetrics(),
        dashboardAPI.getPredictions(1, 10),
      ]);
      
      setStats(statsRes.data);
      setDailyAnalytics(analyticsRes.data.daily_stats || []);
      setModelMetrics(modelRes.data);
      setRecentPredictions(predictionsRes.data.data || []);
    } catch (err) {
      console.error('Dashboard error:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDashboardData();
    // Real-Time Feel: Refresh every 5 seconds
    const interval = setInterval(() => {
      fetchDashboardData();
    }, 5000);
    return () => clearInterval(interval);
  }, []);

  const handleRetrain = async () => {
    setRetraining(true);
    try {
      await dashboardAPI.retrainModel();
      setTimeout(() => {
        alert('Model retraining triggered successfully!');
        setRetraining(false);
      }, 1500);
    } catch (err) {
      alert('Failed to trigger retraining');
      setRetraining(false);
    }
  };

  const diseaseData = stats?.top_diseases?.map(d => ({
    name: d.disease.split('___').pop()?.replace(/_/g, ' ') || d.disease,
    count: d.count,
    percentage: stats.total_predictions > 0 ? (d.count / stats.total_predictions) * 100 : 0,
  })) || [];

  const sparklineData = dailyAnalytics.map(d => ({ value: d.predictions }));
  const accuracyData = dailyAnalytics.map(d => ({ value: d.accuracy }));

  if (loading) {
    return (
      <Box display="flex" flexDirection="column" gap={3} p={3}>
        <Box display="flex" justifyContent="space-between"><Skeleton variant="rectangular" width={300} height={60} /><Skeleton variant="rectangular" width={200} height={40} /></Box>
        <Grid container spacing={3} sx={{ width: '100%' }}>
          {[1, 2, 3, 4, 5].map(i => <Grid size={{ xs: 12, sm: 6, md: 3 }} key={i}><Skeleton variant="rectangular" height={150} sx={{ borderRadius: '24px' }} /></Grid>)}
        </Grid>
        <Grid container spacing={3} sx={{ width: '100%' }}>
          <Grid size={{ xs: 12, md: 8 }}><Skeleton variant="rectangular" height={400} sx={{ borderRadius: '24px' }} /></Grid>
          <Grid size={{ xs: 12, md: 4 }}><Skeleton variant="rectangular" height={400} sx={{ borderRadius: '24px' }} /></Grid>
        </Grid>
      </Box>
    );
  }

  // Calculate drift mock
  const accuracyDrop = -2.3;

  return (
    <MotionBox ref={ref} variants={containerVariants} initial="hidden" animate={inView ? "visible" : "hidden"} sx={{ pb: 6, width: '100%' }}>
      
      {/* Header & Status Section */}
      <MotionBox variants={itemVariants} sx={{ mb: 4, display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 2 }}>
        <Box>
          <Typography variant="h4" className="mesh-gradient-text" sx={{ fontWeight: 800, mb: 0.5, color: '#0F172A' }}>
            {t('systemCommand')}
          </Typography>
          <Box display="flex" alignItems="center" gap={1.5} sx={{ color: '#64748b' }}>
            <Typography variant="body2" sx={{ fontWeight: 600 }}>{t('realTimeOverview')}</Typography>
            <Divider orientation="vertical" flexItem sx={{ height: 16, alignSelf: 'center' }} />
            <Box display="flex" alignItems="center" gap={0.5}>
              <Box sx={{ width: 8, height: 8, borderRadius: '50%', bgcolor: '#22C55E', boxShadow: '0 0 8px #22C55E' }} />
              <Typography variant="caption" sx={{ fontWeight: 700, color: '#22C55E', letterSpacing: 0.5 }}>{t('systemActive')}</Typography>
            </Box>
          </Box>
        </Box>
        
        <Box display="flex" gap={2}>
          <Button variant="outlined" startIcon={<DownloadIcon />} sx={{ borderRadius: 2, color: '#0F172A', borderColor: '#cbd5e1', fontWeight: 600 }}>
            {t('exportReport')}
          </Button>
          <motion.div whileHover={{ scale: 1.02 }} whileTap={{ scale: 0.98 }}>
            <Button
              variant="contained"
              startIcon={<TrainIcon />}
              onClick={handleRetrain}
              disabled={retraining}
              sx={{ 
                borderRadius: 2, 
                bgcolor: '#2563EB',
                fontWeight: 700,
                boxShadow: '0 4px 12px rgba(37, 99, 235, 0.2)',
                '&:hover': { bgcolor: '#1d4ed8' }
              }}
            >
              {retraining ? t('retraining') : t('retrainModel')}
            </Button>
          </motion.div>
        </Box>
      </MotionBox>

      {/* Filters (Pro Feature) */}
      <MotionBox variants={itemVariants} sx={{ mb: 4 }}>
        <DashboardFilters />
      </MotionBox>

      {/* Core Stats Cards */}
      <MotionGrid container spacing={3} variants={itemVariants} sx={{ mb: 4 }}>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatsCard
            title={t('totalScans')}
            value={stats?.total_predictions?.toLocaleString() || 0}
            icon={<DashboardIcon sx={{ fontSize: 24, color: '#2563EB' }} />}
            color="#2563EB"
            trend="up"
            trendValue="12.5"
            chartData={sparklineData}
          />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatsCard
            title={t('accuracy')}
            value={stats?.feedback?.accuracy || '0.0%'}
            icon={<SpeedIcon sx={{ fontSize: 24, color: '#22C55E' }} />}
            color="#22C55E"
            trend={parseFloat(stats?.feedback?.accuracy) > 90 ? "up" : "down"}
            trendValue={stats?.feedback?.status || "Live"}
            chartData={accuracyData}
          />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatsCard
            title={t('confidence')}
            value={stats?.avg_confidence || '0.0%'}
            icon={<PsychologyIcon sx={{ fontSize: 24, color: '#F59E0B' }} />}
            color="#F59E0B"
            trend="up"
            trendValue="Stable"
          />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatsCard
            title={t('edgeInference')}
            value={stats?.local_predictions?.toLocaleString() || 0}
            icon={<DevicesIcon sx={{ fontSize: 24, color: '#8B5CF6' }} />}
            color="#8B5CF6"
            trend="down"
            trendValue="1.1"
          />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatsCard
            title={t('users')}
            value={stats?.unique_users?.toLocaleString() || 0}
            icon={<PeopleIcon sx={{ fontSize: 24, color: '#8B5CF6' }} />}
            color="#8b5cf6"
            trend="up"
            trendValue="5.8"
          />
        </Grid>
      </MotionGrid>

      {/* Analytics & Model Intelligence */}
      <Grid container spacing={3} sx={{ width: '100%', mb: 4 }}>
        <Grid size={{ xs: 12, md: 7 }}>
          <ChartCard title={t('diseaseDistribution')} subtitle={t('prevalenceCrops')} height={400}>
            <DiseaseBarChart data={diseaseData} />
          </ChartCard>
        </Grid>
        
        <Grid size={{ xs: 12, md: 5 }}>
          <Box className="glass-card" sx={{ p: 3, height: '100%', borderRadius: '24px', bgcolor: '#ffffff', display: 'flex', flexDirection: 'column' }}>
            <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
              <Box display="flex" alignItems="center" gap={1.5}>
                <PsychologyIcon sx={{ color: '#2563EB' }} />
                <Typography variant="h6" sx={{ fontWeight: 800, color: '#0F172A' }}>{t('modelIntelligence')}</Typography>
              </Box>
              <Typography variant="caption" sx={{ color: '#EF4444', bgcolor: '#FEF2F2', px: 1, py: 0.5, borderRadius: 1, fontWeight: 700 }}>
                {t('accuracyDrop')}: {accuracyDrop}% ⚠️
              </Typography>
            </Box>
            
            <Box sx={{ flexGrow: 1, display: 'flex', flexDirection: 'column', gap: 3 }}>
              <Box>
                <Box display="flex" justifyContent="space-between" mb={1}>
                  <Typography variant="body2" color="textSecondary" fontWeight="600">{t('coreAccuracy')}</Typography>
                  <Typography variant="body2" fontWeight="800">{modelMetrics?.accuracy || '0.0%'}</Typography>
                </Box>
                <LinearProgress variant="determinate" value={parseFloat(modelMetrics?.accuracy) || 0} sx={{ height: 8, borderRadius: '24px', bgcolor: '#e2e8f0', '& .MuiLinearProgress-bar': { bgcolor: '#2563EB' } }} />
              </Box>
              
              <Box>
                <Box display="flex" justifyContent="space-between" mb={1}>
                  <Typography variant="body2" color="textSecondary" fontWeight="600">{t('confidence')}</Typography>
                  <Typography variant="body2" fontWeight="800">{stats?.avg_confidence || '0.0%'}</Typography>
                </Box>
                <LinearProgress variant="determinate" value={parseFloat(stats?.avg_confidence) || 0} sx={{ height: 8, borderRadius: '24px', bgcolor: '#e2e8f0', '& .MuiLinearProgress-bar': { bgcolor: '#22C55E' } }} />
              </Box>

              {/* Version Comparison Table */}
              <Box sx={{ mt: 'auto', p: 2, bgcolor: 'action.hover', borderRadius: 3, border: '1px solid', borderColor: 'divider' }}>
                <Typography variant="caption" sx={{ color: 'text.secondary', fontWeight: 700, mb: 1, display: 'block' }}>{t('versionHistory')}</Typography>
                <Box display="flex" justifyContent="space-between" alignItems="center" mb={1}>
                  <Typography variant="body2" fontWeight="600" color="text.disabled">v1.0 (Legacy)</Typography>
                  <Typography variant="body2" fontWeight="600" color="text.disabled">88.0%</Typography>
                </Box>
                <Box display="flex" justifyContent="space-between" alignItems="center">
                  <Typography variant="body2" fontWeight="800">v1.1 ({t('active')})</Typography>
                  <Box display="flex" alignItems="center" gap={0.5}>
                    <Typography variant="body2" fontWeight="800" color="#22C55E">{modelMetrics?.accuracy || '0.0'}%</Typography>
                    <TrendingUpIcon sx={{ fontSize: 16, color: '#22C55E' }} />
                  </Box>
                </Box>
              </Box>
            </Box>
          </Box>
        </Grid>
      </Grid>

      {/* Recent Scans & System Status */}
      <Grid container spacing={3} sx={{ width: '100%' }}>
        <Grid size={{ xs: 12, md: 8 }}>
          <RecentScansTable predictions={recentPredictions} />
        </Grid>

        <Grid size={{ xs: 12, md: 4 }}>
          <SystemStatusCard />
        </Grid>
      </Grid>
    </MotionBox>
  );
}
