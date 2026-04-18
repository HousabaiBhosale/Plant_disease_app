import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  TablePagination,
  Chip,
  CircularProgress,
  Alert
} from '@mui/material';
import { dashboardAPI } from '../services/api';

export default function Analytics() {
  const [predictions, setPredictions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  // Pagination
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [total, setTotal] = useState(0);

  useEffect(() => {
    fetchPredictions();
  }, [page, rowsPerPage]);

  const fetchPredictions = async () => {
    setLoading(true);
    try {
      // Backend expects 1-indexed page
      const response = await dashboardAPI.getPredictions(page + 1, rowsPerPage);
      setPredictions(response.data.data);
      setTotal(response.data.total);
      setError(null);
    } catch (err) {
      console.error('Failed to fetch predictions', err);
      setError('Could not load prediction history. Please try again later.');
    } finally {
      setLoading(false);
    }
  };

  const handleChangePage = (event, newPage) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(0);
  };

  const getSeverityColor = (severity) => {
    switch (severity?.toLowerCase()) {
      case 'high': return 'error';
      case 'medium': return 'warning';
      case 'low': return 'info';
      case 'healthy': return 'success';
      default: return 'default';
    }
  };

  return (
    <Box>
      <Box sx={{ textAlign: 'left', mb: 4 }}>
        <Typography variant="h4" sx={{ fontWeight: 800, color: '#1e293b', mb: 1 }}>
          Scan History
        </Typography>
        <Typography variant="body1" sx={{ color: '#64748b' }}>
          Chronological record of all plant disease detections
        </Typography>
      </Box>

      {error && <Alert severity="error" sx={{ mb: 3 }}>{error}</Alert>}

      <Paper sx={{ 
        width: '100%', 
        overflow: 'hidden', 
        borderRadius: 4, 
        boxShadow: '0 4px 20px rgba(0,0,0,0.08)',
        border: '1px solid rgba(0,0,0,0.05)' 
      }}>
        <TableContainer sx={{ 
          maxHeight: 600,
          '&::-webkit-scrollbar': {
            height: '6px',
          },
          '&::-webkit-scrollbar-thumb': {
            backgroundColor: '#cbd5e1',
            borderRadius: '10px',
          }
        }}>
          <Table stickyHeader sx={{ minWidth: 650 }}>
            <TableHead>
              <TableRow>
                <TableCell sx={{ fontWeight: 700, bgcolor: '#f8fafc', color: '#64748b' }}>DATE & TIME</TableCell>
                <TableCell sx={{ fontWeight: 700, bgcolor: '#f8fafc', color: '#64748b' }}>DISEASE NAME</TableCell>
                <TableCell sx={{ fontWeight: 700, bgcolor: '#f8fafc', color: '#64748b' }}>CONFIDENCE</TableCell>
                <TableCell sx={{ fontWeight: 700, bgcolor: '#f8fafc', color: '#64748b' }}>SEVERITY</TableCell>
                <TableCell sx={{ fontWeight: 700, bgcolor: '#f8fafc', color: '#64748b' }}>METHOD</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {loading && predictions.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={5} align="center" sx={{ py: 10 }}>
                    <CircularProgress sx={{ color: '#1e3c72' }} />
                    <Typography variant="body2" sx={{ mt: 2, color: '#64748b' }}>Fetching scan data...</Typography>
                  </TableCell>
                </TableRow>
              ) : predictions.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={5} align="center" sx={{ py: 10 }}>
                    <Box sx={{ opacity: 0.5 }}>
                      <Typography variant="h6" sx={{ color: '#94a3b8', mb: 1 }}>No scans found</Typography>
                      <Typography variant="body2" sx={{ color: '#94a3b8' }}>Scans from your app will appear here automatically.</Typography>
                    </Box>
                  </TableCell>
                </TableRow>
              ) : (
                predictions.map((row) => (
                  <TableRow hover key={row._id} sx={{ '&:last-child td, &:last-child th': { border: 0 } }}>
                    <TableCell sx={{ fontWeight: 500 }}>
                      {new Date(row.created_at).toLocaleString()}
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" sx={{ fontWeight: 600, color: '#1e293b' }}>
                        {row.predicted_disease?.split('___').pop()?.replace(/_/g, ' ') || 'Unknown'}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Box display="flex" alignItems="center" gap={1}>
                        <Typography variant="body2" sx={{ fontWeight: 700, color: '#1e3c72' }}>
                          {(row.confidence * 100).toFixed(1)}%
                        </Typography>
                      </Box>
                    </TableCell>
                    <TableCell>
                      <Chip 
                        label={row.severity?.toUpperCase() || 'UNKNOWN'} 
                        color={getSeverityColor(row.severity)}
                        size="small"
                        sx={{ fontWeight: 700, fontSize: '0.7rem', px: 1 }}
                      />
                    </TableCell>
                    <TableCell>
                      <Chip 
                        label={row.local_inference ? 'Mobile' : 'Cloud'} 
                        variant="outlined"
                        size="small"
                        color={row.local_inference ? 'primary' : 'secondary'}
                        sx={{ fontWeight: 600, borderStyle: 'dashed' }}
                      />
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </TableContainer>
        <TablePagination
          rowsPerPageOptions={[10, 25, 50]}
          component="div"
          count={total}
          rowsPerPage={rowsPerPage}
          page={page}
          onPageChange={handleChangePage}
          onRowsPerPageChange={handleChangeRowsPerPage}
          sx={{ borderTop: '1px solid rgba(0,0,0,0.05)' }}
        />
      </Paper>
    </Box>
  );
}
