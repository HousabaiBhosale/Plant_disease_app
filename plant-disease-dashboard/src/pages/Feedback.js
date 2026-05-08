import React, { useState, useEffect } from 'react';
import { 
  Box, Typography, Grid, Paper, Table, TableBody, TableCell, 
  TableContainer, TableHead, TableRow, Chip, IconButton, Button
} from '@mui/material';
import { motion } from 'framer-motion';
import { PieChart, Pie, Cell, Tooltip, ResponsiveContainer, Legend } from 'recharts';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import StarIcon from '@mui/icons-material/Star';
import BugReportIcon from '@mui/icons-material/BugReport';

import { dashboardAPI } from '../services/api';

import { useUI } from '../contexts/ThemeContext';

const MotionBox = motion(Box);

export default function Feedback() {
  const { t } = useUI();
  const [feedbacks, setFeedbacks] = useState([]);

  useEffect(() => {
    dashboardAPI.getFeedback(1, 50).then(res => setFeedbacks(res.data.data || [])).catch(console.error);
  }, []);

  // Compute sentiment from real feedback
  const correctCount = feedbacks.filter(f => f.was_correct).length;
  const incorrectCount = feedbacks.filter(f => !f.was_correct).length;
  const analyticsData = [
    { name: t('correct'), value: correctCount },
    { name: t('wrong'), value: incorrectCount },
  ];
  const COLORS = ['#22C55E', '#EF4444'];

  return (
    <Box sx={{ width: '100%', pb: 6 }}>
      
      <Box mb={4}>
        <Typography variant="h4" sx={{ fontWeight: 800, color: '#0F172A', mb: 1 }}>
          {t('userFeedbackSystem')}
        </Typography>
        <Typography variant="body2" color="textSecondary">
          {t('monitorInsights')}
        </Typography>
      </Box>

      <Grid container spacing={3} sx={{ width: '100%', mb: 4 }}>
        <Grid size={{ xs: 12, md: 4 }}>
          <Paper className="glass-card" sx={{ p: 3, borderRadius: '24px', height: 350 }}>
            <Typography variant="h6" sx={{ fontWeight: 800, mb: 1 }}>{t('sentimentAnalytics')}</Typography>
            <Typography variant="caption" color="textSecondary" sx={{ mb: 2, display: 'block' }}>{t('correctVsIncorrect')}</Typography>
            <Box sx={{ height: 250 }}>
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie data={analyticsData} cx="50%" cy="45%" innerRadius={60} outerRadius={90} paddingAngle={5} dataKey="value" stroke="none">
                    {analyticsData.map((entry, index) => <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />)}
                  </Pie>
                  <Tooltip contentStyle={{ borderRadius: 8, border: 'none', boxShadow: '0 4px 12px rgba(0,0,0,0.1)' }} />
                  <Legend verticalAlign="bottom" height={36} iconType="circle" />
                </PieChart>
              </ResponsiveContainer>
            </Box>
          </Paper>
        </Grid>
        
        <Grid size={{ xs: 12, md: 8 }}>
          <Paper className="glass-card" sx={{ p: 3, borderRadius: '24px', height: 350, display: 'flex', flexDirection: 'column' }}>
            <Typography variant="h6" sx={{ fontWeight: 800, mb: 3 }}>{t('feedbackSummary')}</Typography>
            <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
              <Box sx={{ p: 2, bgcolor: '#F0FDF4', border: '1px solid #BBF7D0', borderRadius: 3, flex: 1, minWidth: 150 }}>
                <Typography variant="h4" sx={{ color: '#16A34A', fontWeight: 800 }}>{correctCount}</Typography>
                <Typography variant="caption" sx={{ color: '#15803D', fontWeight: 600 }}>{t('correctPredictions')}</Typography>
              </Box>
              <Box sx={{ p: 2, bgcolor: '#FEF2F2', border: '1px solid #FECACA', borderRadius: 3, flex: 1, minWidth: 150 }}>
                <Typography variant="h4" sx={{ color: '#EF4444', fontWeight: 800 }}>{incorrectCount}</Typography>
                <Typography variant="caption" sx={{ color: '#991B1B', fontWeight: 600 }}>{t('wrongPredictions')}</Typography>
              </Box>
              <Box sx={{ p: 2, bgcolor: '#EFF6FF', border: '1px solid #BFDBFE', borderRadius: 3, flex: 1, minWidth: 150 }}>
                <Typography variant="h4" sx={{ color: '#2563EB', fontWeight: 800 }}>{feedbacks.length}</Typography>
                <Typography variant="caption" sx={{ color: '#1D4ED8', fontWeight: 600 }}>{t('totalFeedback')}</Typography>
              </Box>
            </Box>
            <Box sx={{ mt: 'auto', p: 2, bgcolor: '#F8FAFC', borderRadius: 3, display: 'flex', alignItems: 'center', gap: 2 }}>
              <BugReportIcon sx={{ color: '#64748B' }} />
              <Typography variant="body2" sx={{ color: '#475569', fontWeight: 500 }}>{t('dataUpdatesLive')}</Typography>
            </Box>
          </Paper>
        </Grid>
      </Grid>

      <Grid container spacing={3} sx={{ width: '100%' }}>
        <Grid size={{ xs: 12 }}>
          <Paper className="glass-card" sx={{ p: 3, borderRadius: '24px', width: '100%' }}>
            <Typography variant="h6" sx={{ fontWeight: 800, mb: 3 }}>{t('userFeedbackList')}</Typography>
            <TableContainer sx={{ width: '100%' }}>
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell sx={{ fontWeight: 700, color: '#64748b' }}>{t('date')}</TableCell>
                    <TableCell sx={{ fontWeight: 700, color: '#64748b' }}>{t('prediction')}</TableCell>
                    <TableCell sx={{ fontWeight: 700, color: '#64748b' }}>{t('wasCorrect')}</TableCell>
                    <TableCell sx={{ fontWeight: 700, color: '#64748b' }}>{t('actualDisease')}</TableCell>
                    <TableCell sx={{ fontWeight: 700, color: '#64748b', width: '30%' }}>{t('comment')}</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {feedbacks.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={5} align="center" sx={{ color: '#94a3b8', py: 4 }}>
                        {t('noFeedbackYet')}
                      </TableCell>
                    </TableRow>
                  ) : feedbacks.map((row, idx) => (
                    <TableRow key={idx} hover sx={{ '&:last-child td': { border: 0 } }}>
                      <TableCell sx={{ fontWeight: 600, color: '#475569' }}>
                        {row.created_at ? new Date(row.created_at).toLocaleDateString() : 'N/A'}
                      </TableCell>
                      <TableCell sx={{ fontWeight: 600, color: '#0F172A' }}>
                        {row.prediction_id || 'N/A'}
                      </TableCell>
                      <TableCell>
                        <Chip
                          icon={row.was_correct ? <CheckCircleIcon /> : <BugReportIcon />}
                          label={row.was_correct ? t('correct') : t('wrong')}
                          size="small"
                          sx={{
                            fontWeight: 700,
                            bgcolor: row.was_correct ? '#F0FDF4' : '#FEF2F2',
                            color: row.was_correct ? '#16A34A' : '#EF4444',
                          }}
                        />
                      </TableCell>
                      <TableCell sx={{ color: '#475569' }}>
                        {row.actual_disease ? row.actual_disease.replace(/_/g, ' ') : '—'}
                      </TableCell>
                      <TableCell>
                        <Typography variant="body2" sx={{ color: '#64748b' }}>
                          {row.comments || '—'}
                        </Typography>
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
