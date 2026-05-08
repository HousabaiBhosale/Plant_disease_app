import React, { useState } from 'react';
import { 
  Box, Typography, Grid, Paper, Switch, Slider, 
  Select, MenuItem, TextField, Button, Divider, FormControlLabel
} from '@mui/material';
import { motion } from 'framer-motion';
import SaveIcon from '@mui/icons-material/Save';
import NotificationsActiveIcon from '@mui/icons-material/NotificationsActive';
import TuneIcon from '@mui/icons-material/Tune';
import PersonIcon from '@mui/icons-material/Person';
import DnsIcon from '@mui/icons-material/Dns';

import { useUI } from '../contexts/ThemeContext';
import { dashboardAPI } from '../services/api';

import { useAuth } from '../contexts/AuthContext';

const MotionBox = motion(Box);

export default function Settings() {
  const { mode, toggleTheme, language, changeLanguage, t } = useUI();
  const { user, updateUser } = useAuth();
  const [threshold, setThreshold] = useState(70);
  const [modelType, setModelType] = useState('v1.1');
  const [saving, setSaving] = useState(false);
  
  const [adminProfile, setAdminProfile] = useState({
    name: user?.name || 'System Administrator',
    email: user?.email || 'admin@plantdiseaseapp.com',
    phone: user?.phone || '+1 (555) 019-2831'
  });

  const handleSaveAll = async () => {
    setSaving(true);
    try {
      await dashboardAPI.updateProfile(adminProfile.name, adminProfile.email);
      // Update global auth state
      updateUser({ ...user, ...adminProfile });
      alert('Settings saved successfully!');
    } catch (err) {
      alert(err.response?.data?.detail || 'Failed to save profile');
    } finally {
      setSaving(false);
    }
  };
  
  return (
    <Box sx={{ width: '100%', pb: 6 }}>
      
      <Box display="flex" justifyContent="space-between" alignItems="flex-end" mb={4}>
        <Box>
          <Typography variant="h4" sx={{ fontWeight: 800, mb: 1 }}>
            {t('adminControl')}
          </Typography>
          <Typography variant="body2" color="textSecondary">
            {t('manageSystem')}
          </Typography>
        </Box>
        <Button 
          variant="contained" 
          startIcon={<SaveIcon />} 
          disabled={saving}
          onClick={handleSaveAll}
          sx={{ bgcolor: '#2563EB', fontWeight: 700, borderRadius: 2 }}
        >
          {saving ? t('saving') : t('saveChanges')}
        </Button>
      </Box>

      <Grid container spacing={4}>
        
        {/* Model Settings */}
        <Grid size={{ xs: 12, md: 6 }}>
          <Paper className="glass-card" sx={{ p: 4, borderRadius: '24px', height: '100%' }}>
            <Box display="flex" alignItems="center" gap={1.5} mb={3}>
              <TuneIcon sx={{ color: '#2563EB' }} />
              <Typography variant="h6" sx={{ fontWeight: 800 }}>{t('modelSettings')}</Typography>
            </Box>
            
            <Box mb={4}>
              <Box display="flex" justifyContent="space-between" mb={1}>
                <Typography variant="body2" fontWeight="600">{t('confidenceThreshold')}</Typography>
                <Typography variant="body2" fontWeight="800" color="#2563EB">{threshold}%</Typography>
              </Box>
              <Typography variant="caption" color="textSecondary" sx={{ mb: 2, display: 'block' }}>
                Predictions below this confidence score will be flagged for review.
              </Typography>
              <Slider 
                value={threshold} 
                onChange={(_, newValue) => setThreshold(newValue)} 
                sx={{ color: '#2563EB', '& .MuiSlider-thumb': { boxShadow: '0 4px 12px rgba(37,99,235,0.4)' } }} 
              />
            </Box>

            <Box>
              <Typography variant="body2" fontWeight="600" mb={1}>{t('activeModel')}</Typography>
              <Select 
                fullWidth 
                size="small" 
                value={modelType} 
                onChange={(e) => setModelType(e.target.value)}
                sx={{ borderRadius: 2 }}
              >
                <MenuItem value="v1.1">EfficientNet v1.1 (Production)</MenuItem>
                <MenuItem value="v1.0">MobileNet v1.0 (Legacy)</MenuItem>
                <MenuItem value="v1.2-beta">EfficientNetV2 v1.2 (Beta testing)</MenuItem>
              </Select>
            </Box>
          </Paper>
        </Grid>

        {/* Notification Settings */}
        <Grid size={{ xs: 12, md: 6 }}>
          <Paper className="glass-card" sx={{ p: 4, borderRadius: '24px', height: '100%' }}>
            <Box display="flex" alignItems="center" gap={1.5} mb={3}>
              <NotificationsActiveIcon sx={{ color: '#F59E0B' }} />
              <Typography variant="h6" sx={{ fontWeight: 800 }}>{t('notifications')}</Typography>
            </Box>

            <Box display="flex" flexDirection="column" gap={2}>
              <Box display="flex" justifyContent="space-between" alignItems="center">
                <Box>
                  <Typography variant="body2" fontWeight="600">{t('modelDrift')}</Typography>
                  <Typography variant="caption" color="textSecondary">Notify when accuracy drops below 85%</Typography>
                </Box>
                <Switch defaultChecked color="warning" />
              </Box>
              <Divider sx={{ borderStyle: 'dashed' }} />
              
              <Box display="flex" justifyContent="space-between" alignItems="center">
                <Box>
                  <Typography variant="body2" fontWeight="600">{t('outbreakAlerts')}</Typography>
                  <Typography variant="caption" color="textSecondary">Notify when sudden spikes occur in a specific region</Typography>
                </Box>
                <Switch defaultChecked color="warning" />
              </Box>
              <Divider sx={{ borderStyle: 'dashed' }} />

              <Box display="flex" justifyContent="space-between" alignItems="center">
                <Box>
                  <Typography variant="body2" fontWeight="600">{t('weeklyReport')}</Typography>
                  <Typography variant="caption" color="textSecondary">Receive automated PDF reports every Monday</Typography>
                </Box>
                <Switch color="warning" />
              </Box>
            </Box>
          </Paper>
        </Grid>

        {/* Admin Profile */}
        <Grid size={{ xs: 12, md: 6 }}>
          <Paper className="glass-card" sx={{ p: 4, borderRadius: '24px', height: '100%' }}>
            <Box display="flex" alignItems="center" gap={1.5} mb={3}>
              <PersonIcon sx={{ color: '#10B981' }} />
              <Typography variant="h6" sx={{ fontWeight: 800 }}>{t('adminProfile')}</Typography>
            </Box>

            <Box display="flex" flexDirection="column" gap={3}>
              <TextField 
                label={t('fullName')} 
                value={adminProfile.name} 
                onChange={(e) => setAdminProfile({...adminProfile, name: e.target.value})}
                size="small" 
                InputProps={{ sx: { borderRadius: 2 } }} 
              />
              <TextField 
                label={t('email')} 
                value={adminProfile.email} 
                onChange={(e) => setAdminProfile({...adminProfile, email: e.target.value})}
                size="small" 
                InputProps={{ sx: { borderRadius: 2 } }} 
              />
              <TextField 
                label={t('phone')} 
                value={adminProfile.phone} 
                onChange={(e) => setAdminProfile({...adminProfile, phone: e.target.value})}
                size="small" 
                InputProps={{ sx: { borderRadius: 2 } }} 
              />
            </Box>
          </Paper>
        </Grid>

        {/* UI Preferences (Appearance) */}
        <Grid size={{ xs: 12, md: 6 }}>
          <Paper className="glass-card" sx={{ p: 4, borderRadius: '24px', height: '100%' }}>
            <Box display="flex" alignItems="center" gap={1.5} mb={3}>
              <Box sx={{ p: 1, borderRadius: '10px', bgcolor: mode === 'light' ? '#FEE2E2' : '#7F1D1D', display: 'flex' }}>
                <Typography variant="h6" sx={{ fontSize: '1.2rem' }}>🎨</Typography>
              </Box>
              <Typography variant="h6" sx={{ fontWeight: 800 }}>{t('appearance')}</Typography>
            </Box>

            <Box display="flex" flexDirection="column" gap={3}>
              <Box display="flex" justifyContent="space-between" alignItems="center">
                <Box>
                  <Typography variant="body2" fontWeight="600">{t('darkMode')} 🌙</Typography>
                  <Typography variant="caption" color="textSecondary">Toggle between light and dark themes</Typography>
                </Box>
                <Switch checked={mode === 'dark'} onChange={toggleTheme} color="primary" />
              </Box>
              
              <Divider sx={{ borderStyle: 'dashed' }} />

              <Box>
                <Typography variant="body2" fontWeight="600" mb={1}>{t('language')}</Typography>
                <Select 
                  fullWidth 
                  size="small" 
                  value={language} 
                  onChange={(e) => changeLanguage(e.target.value)}
                  sx={{ borderRadius: 2 }}
                >
                  <MenuItem value="en">English (US)</MenuItem>
                  <MenuItem value="hi">हिन्दी (Hindi)</MenuItem>
                  <MenuItem value="mr">मराठी (Marathi)</MenuItem>
                  <MenuItem value="kn">ಕನ್ನಡ (Kannada)</MenuItem>
                  <MenuItem value="te">తెలుగు (Telugu)</MenuItem>
                  <MenuItem value="ta">தமிழ் (Tamil)</MenuItem>
                  <MenuItem value="es">Español</MenuItem>
                </Select>
              </Box>

              <Box>
                <Typography variant="body2" fontWeight="600" mb={1}>{t('timezone')}</Typography>
                <Select fullWidth size="small" defaultValue="IST" sx={{ borderRadius: 2 }}>
                  <MenuItem value="IST">India Standard Time (UTC+5:30)</MenuItem>
                  <MenuItem value="UTC">Coordinated Universal Time (UTC+0)</MenuItem>
                  <MenuItem value="EST">Eastern Standard Time (UTC-5)</MenuItem>
                </Select>
              </Box>
            </Box>
          </Paper>
        </Grid>

      </Grid>
    </Box>
  );
}
