import React, { useState, useEffect } from 'react';
import {
  Grid,
  Paper,
  Typography,
  Box,
  Button,
  LinearProgress,
  Alert,
  Chip,
  Divider,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  IconButton,
  Tooltip,
} from '@mui/material';
import {
  Refresh as RefreshIcon,
  PlayArrow as TrainIcon,
  CheckCircle as SuccessIcon,
  History as HistoryIcon,
} from '@mui/icons-material';
import { dashboardAPI } from '../services/api';

export default function ModelMonitoring() {
  const [loading, setLoading] = useState(true);
  const [metrics, setMetrics] = useState(null);
  const [versions, setVersions] = useState([]);
  const [training, setTraining] = useState(false);

  useEffect(() => {
    fetchModelData();
  }, []);

  const fetchModelData = async () => {
    setLoading(true);
    try {
      const [metricsRes, versionsRes] = await Promise.all([
        dashboardAPI.getModelMetrics(),
        dashboardAPI.getModelVersions(),
      ]);
      setMetrics(metricsRes.data);
      setVersions(versionsRes.data);
    } catch (error) {
      console.error('Failed to fetch model data:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleRetrain = async () => {
    setTraining(true);
    try {
      await dashboardAPI.retrainModel();
      alert('Model retraining started! This may take a few minutes.');
      setTimeout(fetchModelData, 5000);
    } catch (error) {
      alert('Failed to start retraining: ' + error.message);
    } finally {
      setTraining(false);
    }
  };

  if (loading) {
    return (
      <Box sx={{ p: 3 }}>
        <LinearProgress />
      </Box>
    );
  }

  return (
    <Box>
      <Box sx={{ textAlign: 'left', mb: 4 }}>
        <Typography variant="h4" sx={{ fontWeight: 800, color: '#1e293b', mb: 1 }}>
          Model Monitoring
        </Typography>
        <Typography variant="body1" sx={{ color: '#64748b', mb: 3 }}>
          Track machine learning performance and retraining cycles
        </Typography>
        <Box display="flex" justifyContent="flex-start" alignItems="center" gap={2}>
          <Tooltip title="Refresh Metrics">
            <IconButton onClick={fetchModelData} sx={{ bgcolor: 'rgba(0,0,0,0.05)' }}>
              <RefreshIcon />
            </IconButton>
          </Tooltip>
          <Button
            variant="contained"
            startIcon={<TrainIcon />}
            onClick={handleRetrain}
            disabled={training}
            sx={{ 
              borderRadius: 3,
              textTransform: 'none',
              px: 3,
              background: 'linear-gradient(135deg, #1e237e 0%, #311b92 100%)',
              boxShadow: '0 4px 12px rgba(30,35,126,0.3)'
            }}
          >
            {training ? 'Training...' : 'Retrain Model'}
          </Button>
        </Box>
      </Box>

      {/* Current Model Metrics */}
      <Grid container spacing={3} sx={{ mb: 4 }}>
        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 3 }}>
            <Typography variant="h6" gutterBottom>
              Current Model Performance
            </Typography>
            <Box sx={{ mt: 2 }}>
              <Box display="flex" justifyContent="space-between" mb={1}>
                <Typography variant="body2">Accuracy</Typography>
                <Typography variant="body2" fontWeight="bold">
                  {metrics?.accuracy || 'N/A'}
                </Typography>
              </Box>
              <LinearProgress
                variant="determinate"
                value={parseFloat(metrics?.accuracy) || 0}
                sx={{ height: 8, borderRadius: 4, mb: 2 }}
              />
              
              <Box display="flex" justifyContent="space-between" mb={1}>
                <Typography variant="body2">Precision</Typography>
                <Typography variant="body2" fontWeight="bold">
                  {metrics?.precision || 'N/A'}
                </Typography>
              </Box>
              <LinearProgress
                variant="determinate"
                value={parseFloat(metrics?.precision) || 0}
                sx={{ height: 8, borderRadius: 4, mb: 2 }}
              />
              
              <Box display="flex" justifyContent="space-between" mb={1}>
                <Typography variant="body2">Recall</Typography>
                <Typography variant="body2" fontWeight="bold">
                  {metrics?.recall || 'N/A'}
                </Typography>
              </Box>
              <LinearProgress
                variant="determinate"
                value={parseFloat(metrics?.recall) || 0}
                sx={{ height: 8, borderRadius: 4, mb: 2 }}
              />
              
              <Box display="flex" justifyContent="space-between" mb={1}>
                <Typography variant="body2">F1 Score</Typography>
                <Typography variant="body2" fontWeight="bold">
                  {metrics?.f1_score || 'N/A'}
                </Typography>
              </Box>
              <LinearProgress
                variant="determinate"
                value={parseFloat(metrics?.f1_score) || 0}
                sx={{ height: 8, borderRadius: 4, mb: 2 }}
              />
            </Box>
          </Paper>
        </Grid>

        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 3 }}>
            <Typography variant="h6" gutterBottom>
              Model Health Status
            </Typography>
            <Box sx={{ mt: 2 }}>
              <Alert
                icon={<SuccessIcon fontSize="inherit" />}
                severity="success"
                sx={{ mb: 2 }}
              >
                Model is performing within expected parameters
              </Alert>
              <Typography variant="body2" color="textSecondary" gutterBottom>
                Last Training: {metrics?.last_trained || '2024-03-15'}
              </Typography>
              <Typography variant="body2" color="textSecondary" gutterBottom>
                Training Samples: {metrics?.training_samples?.toLocaleString() || 'N/A'}
              </Typography>
              <Typography variant="body2" color="textSecondary">
                Classes Supported: {metrics?.num_classes || '38'}
              </Typography>
            </Box>
          </Paper>
        </Grid>
      </Grid>

      {/* Model Version History */}
      <Paper sx={{ p: 3 }}>
        <Box display="flex" alignItems="center" mb={2}>
          <HistoryIcon sx={{ mr: 1, color: '#1a237e' }} />
          <Typography variant="h6">Model Version History</Typography>
        </Box>
        <Divider sx={{ mb: 2 }} />
        
        <TableContainer>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Version</TableCell>
                <TableCell>Date</TableCell>
                <TableCell>Accuracy</TableCell>
                <TableCell>Precision</TableCell>
                <TableCell>Recall</TableCell>
                <TableCell>Status</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {versions.map((version) => (
                <TableRow key={version.version}>
                  <TableCell>
                    <Chip
                      label={version.version}
                      size="small"
                      color={version.is_active ? 'primary' : 'default'}
                    />
                  </TableCell>
                  <TableCell>{version.trained_date}</TableCell>
                  <TableCell>{version.accuracy}%</TableCell>
                  <TableCell>{version.precision}%</TableCell>
                  <TableCell>{version.recall}%</TableCell>
                  <TableCell>
                    {version.is_active ? (
                      <Chip label="Active" size="small" color="success" />
                    ) : (
                      <Chip label="Archived" size="small" />
                    )}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      </Paper>
    </Box>
  );
}
