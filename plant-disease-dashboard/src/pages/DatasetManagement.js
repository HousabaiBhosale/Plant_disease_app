import React, { useState, useEffect } from 'react';
import {
  Grid,
  Paper,
  Typography,
  Box,
  Button,
  LinearProgress,
  Alert,
  Card,
  CardContent,
  List,
  ListItem,
  ListItemText,
  ListItemIcon,
  Divider,
  Chip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  IconButton,
} from '@mui/material'; // Removed unused TextField
import {
  CloudUpload as UploadIcon,
  Database as DatabaseIcon,
  Update as UpdateIcon,
  CheckCircle as SuccessIcon,
  Warning as WarningIcon,
  Info as InfoIcon,
  Delete as DeleteIcon,
} from '@mui/icons-material';
import { dashboardAPI } from '../services/api';

export default function DatasetManagement() {
  const [datasetInfo, setDatasetInfo] = useState(null);
  const [loading, setLoading] = useState(true);
  const [uploadDialogOpen, setUploadDialogOpen] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [selectedFile, setSelectedFile] = useState(null);
  const [uploadStatus, setUploadStatus] = useState(null);

  useEffect(() => {
    fetchDatasetInfo();
  }, []);

  const fetchDatasetInfo = async () => {
    setLoading(true);
    try {
      const response = await dashboardAPI.getDatasetInfo();
      setDatasetInfo(response.data);
    } catch (error) {
      console.error('Failed to fetch dataset info:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleFileSelect = (event) => {
    setSelectedFile(event.target.files[0]);
  };

  const handleUpload = async () => {
    if (!selectedFile) return;
    
    setUploading(true);
    const formData = new FormData();
    formData.append('dataset', selectedFile);
    
    try {
      const response = await dashboardAPI.updateDataset(formData);
      setUploadStatus({ success: true, message: response.data?.message || 'Upload successful' });
      fetchDatasetInfo();
      setTimeout(() => setUploadDialogOpen(false), 2000);
    } catch (error) {
       console.error('Failed to upload dataset:', error);
       setUploadStatus({ success: false, message: 'Upload failed' });
    } finally {
      setUploading(false);
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
          Dataset Management
        </Typography>
        <Typography variant="body1" sx={{ color: '#64748b', mb: 3 }}>
          Upload and manage training data for model improvements
        </Typography>
        <Button
            variant="contained"
            startIcon={<UploadIcon />}
            onClick={() => setUploadDialogOpen(true)}
            sx={{ 
              borderRadius: 3, 
              textTransform: 'none',
              px: 4,
              py: 1,
              background: 'linear-gradient(135deg, #1e237e 0%, #311b92 100%)',
              boxShadow: '0 4px 12px rgba(30,35,126,0.3)'
            }}
        >
          Upload New Details
        </Button>
      </Box>
      <Grid container spacing={3}>
        <Grid item xs={12} sm={6} md={3}>
          <Card elevation={3}>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>Total Images</Typography>
              <Typography variant="h4">{datasetInfo?.total_images?.toLocaleString() || '-'}</Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card elevation={3}>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>Total Classes</Typography>
              <Typography variant="h4">{datasetInfo?.classes || '-'}</Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card elevation={3}>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>Plant Species</Typography>
              <Typography variant="h4">{datasetInfo?.plants || '-'}</Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card elevation={3}>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>Dataset Size (MB)</Typography>
              <Typography variant="h4">{datasetInfo?.size_mb || '-'}</Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
      
      {/* Upload Dialog */}
      <Dialog open={uploadDialogOpen} onClose={() => !uploading && setUploadDialogOpen(false)}>
        <DialogTitle>Upload Dataset Update</DialogTitle>
        <DialogContent>
          <Box sx={{ py: 2 }}>
            <input
              accept=".zip,.csv,.json"
              style={{ display: 'none' }}
              id="dataset-upload-file"
              type="file"
              onChange={handleFileSelect}
            />
            <label htmlFor="dataset-upload-file">
              <Button variant="outlined" component="span" startIcon={<UploadIcon />} fullWidth>
                Choose File
              </Button>
            </label>
            {selectedFile && (
              <Typography variant="body2" sx={{ mt: 2, textAlign: 'center' }}>
                Selected: {selectedFile.name}
              </Typography>
            )}
            {uploading && <LinearProgress sx={{ mt: 2 }} />}
            {uploadStatus && (
              <Alert severity={uploadStatus.success ? "success" : "error"} sx={{ mt: 2 }}>
                {uploadStatus.message}
              </Alert>
            )}
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setUploadDialogOpen(false)} disabled={uploading}>Cancel</Button>
          <Button onClick={handleUpload} disabled={!selectedFile || uploading} variant="contained">
            Upload
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}
