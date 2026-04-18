import React, { useState, useEffect } from 'react';
import { Grid, Box, Typography, CircularProgress, Alert, Button, Chip, Paper } from '@mui/material';
import { motion } from 'framer-motion';
import { useInView } from 'react-intersection-observer';
import DashboardIcon from '@mui/icons-material/Dashboard';
import SpeedIcon from '@mui/icons-material/Speed';
import DevicesIcon from '@mui/icons-material/Devices';
import PeopleIcon from '@mui/icons-material/People';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import RefreshIcon from '@mui/icons-material/Refresh';
import StatsCard from '../components/Cards/StatsCard';
import ChartCard from '../components/Cards/ChartCard';
import DiseaseBarChart from '../components/Charts/DiseaseBarChart';
import AccuracyTrendChart from '../components/Charts/AccuracyTrendChart';
import PredictionDistributionChart from '../components/Charts/PredictionDistributionChart';
import { dashboardAPI } from '../services/api';

const MotionBox = motion(Box);

export default function Dashboard() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [stats, setStats] = useState(null);
  const [dailyAnalytics, setDailyAnalytics] = useState([]);
  const [ref, inView] = useInView({ triggerOnce: true });

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    setLoading(true);
    try {
      const [statsRes, analyticsRes] = await Promise.all([
        dashboardAPI.getStats(30),
        dashboardAPI.getDailyAnalytics(30),
      ]);
      setStats(statsRes.data);
      setDailyAnalytics(analyticsRes.data.daily_stats || []);
    } catch (err) {
      setError('Failed to load dashboard data');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="60vh">
        <CircularProgress sx={{ color: '#1e3c72' }} />
      </Box>
    );
  }

  const diseaseData = stats?.top_diseases?.map(d => ({
    name: d.disease.split('___').pop()?.replace(/_/g, ' ') || d.disease,
    count: d.count,
    percentage: stats.total_predictions > 0 ? (d.count / stats.total_predictions) * 100 : 0,
  })) || [];

  const hasData = stats?.total_predictions > 0;

  return (
    <Box ref={ref}>
      {/* Header Section */}
      <MotionBox
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        sx={{ mb: 4 }}
      >
        <Box sx={{ textAlign: 'left', mb: 4 }}>
          <Typography variant="h4" sx={{ fontWeight: 800, color: '#1e293b', mb: 1 }}>
            Dashboard Overview
          </Typography>
          <Typography variant="body1" sx={{ color: '#64748b', mb: 3 }}>
            Real-time analytics and insights from your plant disease detection system
          </Typography>
          <Button
            variant="contained"
            startIcon={<RefreshIcon />}
            onClick={fetchDashboardData}
            sx={{ 
              borderRadius: 12, 
              textTransform: 'none',
              px: 4,
              py: 1.2,
              boxShadow: '0 4px 12px rgba(30, 60, 114, 0.2)',
              bgcolor: '#1e3c72',
              '&:hover': { bgcolor: '#1a335d' }
            }}
          >
            Refresh Data
          </Button>
        </Box>
      </MotionBox>

      {/* Stats Cards */}
      <Grid container spacing={3} sx={{ mb: 4 }}>
        <Grid item xs={12} sm={6} md={3}>
          <StatsCard
            title="TOTAL PREDICTIONS"
            value={stats?.total_predictions?.toLocaleString() || 0}
            icon={<DashboardIcon sx={{ fontSize: 32, color: '#3b82f6' }} />}
            color="#3b82f6"
            trend="up"
            trendValue="12"
            subtitle="All time predictions"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatsCard
            title="ACCURACY RATE"
            value={stats?.feedback?.accuracy || '0%'}
            icon={<SpeedIcon sx={{ fontSize: 32, color: '#10b981' }} />}
            color="#10b981"
            trend="up"
            trendValue="5"
            subtitle="Based on user feedback"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatsCard
            title="LOCAL PREDICTIONS"
            value={stats?.local_predictions?.toLocaleString() || 0}
            icon={<DevicesIcon sx={{ fontSize: 32, color: '#f59e0b' }} />}
            color="#f59e0b"
            trend="up"
            trendValue="8"
            subtitle="TFLite on-device"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatsCard
            title="ACTIVE USERS"
            value={stats?.unique_users?.toLocaleString() || 0}
            icon={<PeopleIcon sx={{ fontSize: 32, color: '#8b5cf6' }} />}
            color="#8b5cf6"
            trend="up"
            trendValue="15"
            subtitle="Last 30 days"
          />
        </Grid>
      </Grid>

      {/* Charts Section */}
      <Grid container spacing={3}>
        <Grid item xs={12} md={6}>
          <ChartCard title="Disease Frequency" subtitle="Top 10 most detected diseases" height={450}>
            <DiseaseBarChart data={diseaseData} />
          </ChartCard>
        </Grid>
        
        <Grid item xs={12} md={6}>
          <ChartCard title="Model Accuracy Trend" subtitle="Daily performance tracking" height={450}>
            <AccuracyTrendChart data={dailyAnalytics} />
          </ChartCard>
        </Grid>
        
        <Grid item xs={12} md={6}>
          <ChartCard title="Inference Distribution" subtitle="Local vs Cloud predictions" height={350}>
            <PredictionDistributionChart localCount={stats?.local_predictions || 0} cloudCount={stats?.cloud_predictions || 0} />
          </ChartCard>
        </Grid>
        
        <Grid item xs={12} md={6}>
          <ChartCard title="Performance Summary" subtitle="Key metrics at a glance" height={350}>
            <Paper sx={{ p: 3, background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)', borderRadius: 4 }}>
              <Grid container spacing={2}>
                <Grid item xs={6}>
                  <Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.8)' }}>
                    Avg Confidence
                  </Typography>
                  <Typography variant="h4" sx={{ color: 'white', fontWeight: 700 }}>
                    {stats?.avg_confidence || '0%'}
                  </Typography>
                </Grid>
                <Grid item xs={6}>
                  <Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.8)' }}>
                    Total Feedback
                  </Typography>
                  <Typography variant="h4" sx={{ color: 'white', fontWeight: 700 }}>
                    {stats?.feedback?.total || 0}
                  </Typography>
                </Grid>
                <Grid item xs={6}>
                  <Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.8)' }}>
                    Correct Predictions
                  </Typography>
                  <Typography variant="h4" sx={{ color: 'white', fontWeight: 700 }}>
                    {stats?.feedback?.correct || 0}
                  </Typography>
                </Grid>
                <Grid item xs={6}>
                  <Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.8)' }}>
                    Needs Improvement
                  </Typography>
                  <Typography variant="h4" sx={{ color: 'white', fontWeight: 700 }}>
                    {stats?.feedback?.incorrect || 0}
                  </Typography>
                </Grid>
              </Grid>
            </Paper>
          </ChartCard>
        </Grid>
      </Grid>

      {/* Recent Activity Section */}
      <MotionBox
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.3 }}
        sx={{ mt: 4 }}
      >
        <Typography variant="h5" sx={{ fontWeight: 700, mb: 3, textAlign: 'left', color: '#1e293b' }}>
          Recent Activity & Statistics
        </Typography>
        <Paper sx={{ p: 3, borderRadius: 4 }}>
          {!hasData ? (
            <Box textAlign="center" py={4}>
              <Typography variant="h6" sx={{ color: '#94a3b8', mb: 1 }}>
                No scans yet
              </Typography>
              <Typography variant="body2" sx={{ color: '#94a3b8' }}>
                Scan plants using your Flutter app — results will appear here in real time.
              </Typography>
            </Box>
          ) : (
            <Grid container spacing={2}>
              {diseaseData.slice(0, 5).map((disease, idx) => (
                <Grid item xs={12} key={idx}>
                  <Box display="flex" justifyContent="space-between" alignItems="center">
                    <Box display="flex" alignItems="center" gap={2}>
                      <Chip label={`#${idx + 1}`} size="small" sx={{ bgcolor: '#1e3c72', color: 'white' }} />
                      <Typography>{disease.name}</Typography>
                    </Box>
                    <Box display="flex" alignItems="center" gap={2}>
                      <Typography variant="body2" sx={{ color: '#64748b' }}>
                        {disease.count} detections
                      </Typography>
                      <Box sx={{ width: 100, bgcolor: '#e2e8f0', borderRadius: 2, overflow: 'hidden' }}>
                        <Box
                          sx={{
                            width: `${disease.percentage}%`,
                            bgcolor: '#1e3c72',
                            height: 6,
                            borderRadius: 2,
                          }}
                        />
                      </Box>
                      <Typography variant="caption" sx={{ fontWeight: 600, minWidth: 45 }}>
                        {disease.percentage.toFixed(1)}%
                      </Typography>
                    </Box>
                  </Box>
                </Grid>
              ))}
            </Grid>
          )}
        </Paper>
      </MotionBox>
    </Box>
  );
}
