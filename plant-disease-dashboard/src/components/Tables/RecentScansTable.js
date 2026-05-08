import React, { useState } from 'react';
import { 
  Paper, TableContainer, Table, TableHead, TableRow, TableCell, 
  TableBody, Typography, Chip, Box, Button, TextField, InputAdornment 
} from '@mui/material';
import HistoryIcon from '@mui/icons-material/History';
import SearchIcon from '@mui/icons-material/Search';

import { useUI } from '../../contexts/ThemeContext';

export default function RecentScansTable({ predictions }) {
  const { t } = useUI();
  const [search, setSearch] = useState('');

  const filtered = predictions.filter(p => {
    const term = search.toLowerCase();
    const disease = (p.predicted_disease || '').toLowerCase();
    return disease.includes(term);
  });

  return (
    <Paper className="glass-card" sx={{ p: 3, borderRadius: 4, height: '100%' }}>
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3} flexWrap="wrap" gap={2}>
        <Box display="flex" alignItems="center" gap={1.5}>
          <HistoryIcon sx={{ color: '#2563EB' }} />
          <Typography variant="h6" sx={{ fontWeight: 700 }}>{t('recentScanActivity')}</Typography>
        </Box>
        <Box display="flex" gap={2} alignItems="center">
          <TextField
            size="small"
            placeholder={t('searchCrop')}
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            InputProps={{
              startAdornment: <InputAdornment position="start"><SearchIcon fontSize="small" /></InputAdornment>,
              sx: { borderRadius: 3, bgcolor: '#f8fafc', '& fieldset': { border: 'none' } }
            }}
          />
          <Button variant="text" size="small" sx={{ textTransform: 'none', fontWeight: 600 }}>{t('viewAll')}</Button>
        </Box>
      </Box>
      
      <TableContainer sx={{ maxHeight: 400 }}>
        <Table stickyHeader size="small">
          <TableHead>
            <TableRow>
              <TableCell sx={{ fontWeight: 700, color: '#64748b', bgcolor: 'transparent', borderBottom: '2px solid #f1f5f9' }}>{t('cropDisease')}</TableCell>
              <TableCell sx={{ fontWeight: 700, color: '#64748b', bgcolor: 'transparent', borderBottom: '2px solid #f1f5f9' }}>{t('confidence')}</TableCell>
              <TableCell sx={{ fontWeight: 700, color: '#64748b', bgcolor: 'transparent', borderBottom: '2px solid #f1f5f9' }}>{t('severity')}</TableCell>
              <TableCell sx={{ fontWeight: 700, color: '#64748b', bgcolor: 'transparent', borderBottom: '2px solid #f1f5f9' }}>{t('status')}</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {filtered.length === 0 ? (
              <TableRow>
                <TableCell colSpan={4} align="center" sx={{ py: 4, color: '#64748b' }}>{t('noScansFound')}</TableCell>
              </TableRow>
            ) : filtered.map((row, idx) => {
              const isHealthy = row.predicted_disease?.toLowerCase().includes('healthy');
              const severityLabel = isHealthy ? t('low') : (row.confidence > 0.9 ? t('high') : t('medium'));
              const severityColor = (row.confidence > 0.9 && !isHealthy) ? 'error' : (row.confidence > 0.7 && !isHealthy) ? 'warning' : 'success';
              
              return (
                <TableRow key={idx} hover sx={{ '&:last-child td': { border: 0 } }}>
                  <TableCell sx={{ py: 2 }}>
                    <Typography variant="body2" sx={{ fontWeight: 600, color: '#0F172A' }}>
                      {row.predicted_disease?.split('___').pop()?.replace(/_/g, ' ') || t('healthy')}
                    </Typography>
                    <Typography variant="caption" color="textSecondary">
                      {new Date(row.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Typography variant="body2" sx={{ fontWeight: 700, color: '#2563EB' }}>
                      {(row.confidence * 100).toFixed(1)}%
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Chip 
                      label={severityLabel} 
                      color={severityColor} 
                      size="small" 
                      sx={{ fontWeight: 700, borderRadius: 1.5, fontSize: '0.7rem', height: 24 }} 
                    />
                  </TableCell>
                  <TableCell>
                    <Box display="flex" alignItems="center" gap={1}>
                      <Box sx={{ width: 8, height: 8, borderRadius: '50%', bgcolor: '#22C55E' }} />
                      <Typography variant="caption" fontWeight="600">{t('logged')}</Typography>
                    </Box>
                  </TableCell>
                </TableRow>
              );
            })}
          </TableBody>
        </Table>
      </TableContainer>
    </Paper>
  );
}
