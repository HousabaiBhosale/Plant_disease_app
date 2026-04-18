import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { Toaster } from 'react-hot-toast';
import { Box, CircularProgress } from '@mui/material';
import { theme } from './styles/theme';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import DashboardLayout from './components/Layout/DashboardLayout';
import Dashboard from './pages/Dashboard';
import Analytics from './pages/Analytics';
import ModelMonitoring from './pages/ModelMonitoring';
import DatasetManagement from './pages/DatasetManagement';
import Feedback from './pages/Feedback';
import Settings from './pages/Settings';
import Login from './pages/Login';

function AppContent() {
  const { isAuthenticated, loading } = useAuth();

  // Show loading spinner while checking for saved session
  if (loading) {
    return (
      <Box
        display="flex"
        justifyContent="center"
        alignItems="center"
        minHeight="100vh"
        sx={{
          background: 'linear-gradient(135deg, #0f172a 0%, #1e3a5f 40%, #0f4c75 70%, #1b262c 100%)',
        }}
      >
        <CircularProgress sx={{ color: '#10b981' }} />
      </Box>
    );
  }

  // Not logged in → show login page
  if (!isAuthenticated) {
    return <Login />;
  }

  // Logged in → show dashboard
  return (
    <DashboardLayout>
      <Routes>
        <Route path="/" element={<Dashboard />} />
        <Route path="/analytics" element={<Analytics />} />
        <Route path="/model-monitoring" element={<ModelMonitoring />} />
        <Route path="/dataset" element={<DatasetManagement />} />
        <Route path="/feedback" element={<Feedback />} />
        <Route path="/settings" element={<Settings />} />
      </Routes>
    </DashboardLayout>
  );
}

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Toaster position="top-right" />
      <Router>
        <AuthProvider>
          <AppContent />
        </AuthProvider>
      </Router>
    </ThemeProvider>
  );
}

export default App;
