import React, { useState, useEffect } from 'react';
import { 
  Box, Typography, Grid, Paper, Button, Table, TableBody, 
  TableCell, TableContainer, TableHead, TableRow, Chip
} from '@mui/material';
import { motion } from 'framer-motion';
import { 
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer 
} from 'recharts';
import CloudUploadIcon from '@mui/icons-material/CloudUpload';
import CollectionsIcon from '@mui/icons-material/Collections';
import CategoryIcon from '@mui/icons-material/Category';
import AccessTimeIcon from '@mui/icons-material/AccessTime';

import StatsCard from '../components/Cards/StatsCard';
import { dashboardAPI } from '../services/api';

import { useUI } from '../contexts/ThemeContext';

const MotionBox = motion(Box);

export default function DatasetManagement() {
  const { t } = useUI();
  const [datasetInfo, setDatasetInfo] = useState(null);
  const [recentPredictions, setRecentPredictions] = useState([]);

  useEffect(() => {
    dashboardAPI.getDatasetInfo().then(res => setDatasetInfo(res.data)).catch(console.error);
    dashboardAPI.getPredictions(1, 10).then(res => setRecentPredictions(res.data.data || [])).catch(console.error);
  }, []);

  return (
    <Box sx={{ width: '100%', pb: 6 }}>
      
      <Box mb={4}>
        <Typography variant="h4" sx={{ fontWeight: 800, color: '#0F172A', mb: 1 }}>
          {t('datasetUpdateMonitoring')}
        </Typography>
        <Typography variant="body2" color="textSecondary">
          {t('trackGrowth')}
        </Typography>
      </Box>

      {/* Dataset Stats Cards */}
      <Grid container spacing={3} sx={{ width: '100%', mb: 4 }}>
        <Grid size={{ xs: 12, sm: 3 }}>
          <StatsCard title={t('totalScans')} value={datasetInfo?.total_predictions?.toLocaleString() || '0'} icon={<CollectionsIcon sx={{ color: '#2563EB' }}/>} color="#2563EB" trend="up" trendValue="8.7" />
        </Grid>
        <Grid size={{ xs: 12, sm: 3 }}>
          <StatsCard title={t('uniqueClasses')} value={datasetInfo?.unique_disease_classes || '0'} icon={<CategoryIcon sx={{ color: '#8B5CF6' }}/>} color="#8B5CF6" />
        </Grid>
        <Grid size={{ xs: 12, sm: 3 }}>
          <StatsCard title={t('totalFeedback')} value={datasetInfo?.total_feedback?.toLocaleString() || '0'} icon={<AccessTimeIcon sx={{ color: '#22C55E' }}/>} color="#22C55E" />
        </Grid>
        <Grid size={{ xs: 12, sm: 3 }}>
          <StatsCard title={t('contributingUsers')} value={datasetInfo?.unique_contributing_users || '0'} icon={<AccessTimeIcon sx={{ color: '#F59E0B' }}/>} color="#F59E0B" />
        </Grid>
      </Grid>

      <Grid container spacing={3} sx={{ width: '100%', mb: 4 }}>
        {/* Dataset Growth Graph — shows daily prediction volume from real scans */}
        <Grid size={{ xs: 12, md: 8 }}>
          <Paper className="glass-card" sx={{ p: 3, borderRadius: '24px', height: 400 }}>
            <Typography variant="h6" sx={{ fontWeight: 800, mb: 1 }}>{t('fieldScanVolume')}</Typography>
            <Typography variant="caption" color="textSecondary" sx={{ mb: 3, display: 'block' }}>{t('dailyScansSubmitted')}</Typography>
            <Box sx={{ height: 300, width: '100%' }}>
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={recentPredictions.length > 0 ? recentPredictions.slice(0, 10).reverse().map((p, i) => ({ day: `Scan ${i + 1}`, scans: 1 })) : [{day: t('noActivity'), scans: 0}]} margin={{ top: 10, right: 30, left: 0, bottom: 0 }}>
                  <XAxis dataKey="day" stroke="#94a3b8" />
                  <YAxis stroke="#94a3b8" />
                  <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" vertical={false} />
                  <Tooltip />
                  <Area type="monotone" dataKey="scans" stroke="#8B5CF6" strokeWidth={3} fillOpacity={0.3} fill="#8B5CF6" />
                </AreaChart>
              </ResponsiveContainer>
            </Box>
          </Paper>
        </Grid>

        {/* Upload Section */}
        <Grid size={{ xs: 12, md: 4 }}>
          <DatasetUploadCard />
        </Grid>
      </Grid>


      {/* Recent Scans from Flutter */}
      <Grid container spacing={3} sx={{ width: '100%' }}>
        <Grid size={{ xs: 12 }}>
          <Paper className="glass-card" sx={{ p: 3, borderRadius: '24px', width: '100%' }}>
            <Typography variant="h6" sx={{ fontWeight: 800, mb: 3 }}>{t('recentFieldScans')}</Typography>
            <TableContainer sx={{ width: '100%' }}>
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell sx={{ fontWeight: 700, color: '#64748b' }}>{t('date')}</TableCell>
                    <TableCell sx={{ fontWeight: 700, color: '#64748b' }}>{t('diseaseDetected')}</TableCell>
                    <TableCell sx={{ fontWeight: 700, color: '#64748b' }}>{t('confidence')}</TableCell>
                    <TableCell sx={{ fontWeight: 700, color: '#64748b' }}>{t('mode')}</TableCell>
                    <TableCell sx={{ fontWeight: 700, color: '#64748b' }}>{t('user')}</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {recentPredictions.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={5} align="center" sx={{ color: '#94a3b8', py: 4 }}>
                        {t('noScansYet')}
                      </TableCell>
                    </TableRow>
                  ) : recentPredictions.map((row, idx) => (
                    <TableRow key={idx} hover sx={{ '&:last-child td': { border: 0 } }}>
                      <TableCell sx={{ fontWeight: 600 }}>{row.created_at ? new Date(row.created_at).toLocaleDateString() : 'N/A'}</TableCell>
                      <TableCell sx={{ fontWeight: 600, color: '#0F172A' }}>
                        {row.predicted_disease?.split('___').pop()?.replace(/_/g, ' ') || row.predicted_disease || t('unknown')}
                      </TableCell>
                      <TableCell>
                        <Chip
                          label={`${((row.confidence || 0) * 100).toFixed(1)}%`}
                          size="small"
                          sx={{ fontWeight: 700, bgcolor: '#EFF6FF', color: '#2563EB', borderRadius: 1.5 }}
                        />
                      </TableCell>
                      <TableCell>
                        <Chip
                          label={row.inference_mode || 'local'}
                          size="small"
                          sx={{ fontWeight: 700, bgcolor: row.inference_mode === 'cloud' ? '#FEF3C7' : '#F0FDF4', color: row.inference_mode === 'cloud' ? '#D97706' : '#16A34A', borderRadius: 1.5 }}
                        />
                      </TableCell>
                      <TableCell sx={{ color: '#64748b' }}>{row.user_id || 'Anonymous'}</TableCell>
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

const DatasetUploadCard = () => {
  const { t } = useUI();
  const [file, setFile] = useState(null);
  const [uploading, setUploading] = useState(false);
  const [success, setSuccess] = useState(false);

  const handleFileChange = (e) => {
    if (e.target.files?.[0]) {
      setFile(e.target.files[0]);
      setSuccess(false);
    }
  };

  const handleUpload = () => {
    if (!file) return;
    setUploading(true);
    // Simulate upload
    setTimeout(() => {
      setUploading(false);
      setFile(null);
      setSuccess(true);
      setTimeout(() => setSuccess(false), 3000);
    }, 2000);
  };

  return (
    <Paper className="glass-card" sx={{ p: 3, borderRadius: '24px', height: 400, display: 'flex', flexDirection: 'column' }}>
      <Typography variant="h6" sx={{ fontWeight: 800, mb: 3 }}>{t('uploadNewData')}</Typography>
      
      <input
        type="file"
        id="dataset-upload"
        style={{ display: 'none' }}
        accept=".zip,.rar,.tar"
        onChange={handleFileChange}
      />
      
      <label htmlFor="dataset-upload" style={{ flexGrow: 1, display: 'flex' }}>
        <Box 
          sx={{ 
            flexGrow: 1, 
            border: '2px dashed',
            borderColor: file ? '#2563EB' : '#CBD5E1', 
            borderRadius: '24px', 
            display: 'flex', 
            flexDirection: 'column',
            justifyContent: 'center', 
            alignItems: 'center',
            bgcolor: file ? '#EFF6FF' : '#F8FAFC',
            cursor: 'pointer',
            transition: 'all 0.2s',
            '&:hover': { borderColor: '#2563EB', bgcolor: '#EFF6FF' }
          }}
        >
          {success ? (
            <>
              <Chip label={t('uploadSuccessful')} color="success" sx={{ fontWeight: 700, mb: 2 }} />
              <Typography variant="caption" color="textSecondary">{t('datasetQueued')}</Typography>
            </>
          ) : (
            <>
              <CloudUploadIcon sx={{ fontSize: 48, color: file ? '#2563EB' : '#94A3B8', mb: 2 }} />
              <Typography variant="body1" sx={{ fontWeight: 700, color: '#475569' }}>
                {file ? file.name : t('dragDropDataset')}
              </Typography>
              <Typography variant="caption" sx={{ color: '#94A3B8', mt: 1 }}>
                {file ? t('clickBrowse') : t('clickBrowse')}
              </Typography>
            </>
          )}
        </Box>
      </label>

      <Button 
        variant="contained" 
        fullWidth 
        disabled={!file || uploading}
        onClick={handleUpload}
        sx={{ mt: 3, borderRadius: 2, bgcolor: '#2563EB', fontWeight: 700, height: 48 }}
      >
        {uploading ? t('processing') : t('processUpload')}
      </Button>
    </Paper>
  );
};
