import React, { useState } from 'react';
import {
  Box,
  Typography,
  Paper,
  Grid,
  TextField,
  Switch,
  FormControlLabel,
  Button,
  Divider,
  Alert
} from '@mui/material';
import { Save as SaveIcon } from '@mui/icons-material';

export default function Settings() {
  const [settings, setSettings] = useState({
    confidenceThreshold: 75,
    enableCloudInference: true,
    emailAlerts: true,
    adminEmail: 'admin@plantguard.com',
  });
  const [saved, setSaved] = useState(false);

  const handleChange = (field) => (event) => {
    const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
    setSettings(prev => ({ ...prev, [field]: value }));
    setSaved(false);
  };

  const handleSave = () => {
    // Mock save logic
    setTimeout(() => {
      setSaved(true);
      setTimeout(() => setSaved(false), 3000);
    }, 500);
  };

  return (
    <Box>
      <Box sx={{ textAlign: 'left', mb: 4 }}>
        <Typography variant="h4" sx={{ fontWeight: 800, color: '#1e293b', mb: 1 }}>
          Global Settings
        </Typography>
        <Typography variant="body1" sx={{ color: '#64748b' }}>
          Configure system preferences and notification alerts
        </Typography>
      </Box>

      {saved && (
        <Alert severity="success" sx={{ mb: 3 }}>
          Settings successfully saved!
        </Alert>
      )}

      <Paper sx={{ p: 4, borderRadius: 2, boxShadow: 3 }}>
        <Typography variant="h6" gutterBottom color="primary">
          Inference Preferences
        </Typography>
        <Grid container spacing={3} sx={{ mb: 4 }}>
          <Grid item xs={12} sm={6}>
            <TextField
              label="Confidence Threshold (%)"
              type="number"
              fullWidth
              value={settings.confidenceThreshold}
              onChange={handleChange('confidenceThreshold')}
              helperText="Predictions below this will be flagged as 'Unknown'"
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <FormControlLabel
              control={
                <Switch 
                  checked={settings.enableCloudInference} 
                  onChange={handleChange('enableCloudInference')} 
                  color="primary"
                />
              }
              label="Enable Cloud Inference Fallback"
            />
            <Typography variant="caption" display="block" color="textSecondary">
              Use heavy server models when on-device TF-Lite fails.
            </Typography>
          </Grid>
        </Grid>

        <Divider sx={{ my: 3 }} />

        <Typography variant="h6" gutterBottom color="primary">
          Notifications
        </Typography>
        <Grid container spacing={3} sx={{ mb: 4 }}>
           <Grid item xs={12}>
            <FormControlLabel
              control={
                <Switch 
                  checked={settings.emailAlerts} 
                  onChange={handleChange('emailAlerts')} 
                  color="primary"
                />
              }
              label="Receive System Alerts"
            />
          </Grid>
          <Grid item xs={12} sm={8}>
            <TextField
              label="Admin Notification Email"
              type="email"
              fullWidth
              value={settings.adminEmail}
              onChange={handleChange('adminEmail')}
              disabled={!settings.emailAlerts}
            />
          </Grid>
        </Grid>

        <Box display="flex" justifyContent="flex-end" mt={4}>
          <Button
            variant="contained"
            color="primary"
            startIcon={<SaveIcon />}
            onClick={handleSave}
            size="large"
          >
            Save Configuration
          </Button>
        </Box>
      </Paper>
    </Box>
  );
}
