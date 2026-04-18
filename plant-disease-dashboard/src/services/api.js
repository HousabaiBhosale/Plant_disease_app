import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://127.0.0.1:8000';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add token to requests if exists
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('admin_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Handle 401 responses — auto-logout on expired token
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Only clear if we had a token (avoid clearing during login attempt)
      const hadToken = localStorage.getItem('admin_token');
      if (hadToken) {
        localStorage.removeItem('admin_token');
        localStorage.removeItem('admin_user');
        window.location.href = '/';
      }
    }
    return Promise.reject(error);
  }
);

// Dashboard API calls
export const dashboardAPI = {
  // --- Auth ---
  login: (email, password) =>
    api.post('/api/auth/login', { email, password }),

  logout: () => api.post('/api/auth/logout'),

  getMe: () => api.get('/api/auth/me'),

  changePassword: (old_password, new_password) =>
    api.post(`/api/auth/change-password?old_password=${encodeURIComponent(old_password)}&new_password=${encodeURIComponent(new_password)}`),

  // --- Dashboard stats ---
  getStats: (days = 30) => api.get(`/api/admin/stats?days=${days}`),

  // Get daily analytics
  getDailyAnalytics: (days = 30) => api.get(`/api/admin/analytics/daily?days=${days}`),

  // Get predictions list
  getPredictions: (page = 1, limit = 50) =>
    api.get(`/api/admin/predictions?page=${page}&limit=${limit}`),

  // Get feedback list
  getFeedback: (page = 1, limit = 50) =>
    api.get(`/api/admin/feedback?page=${page}&limit=${limit}`),

  // Get model performance metrics
  getModelMetrics: () => api.get('/api/admin/model-metrics'),

  // Get dataset information
  getDatasetInfo: () => api.get('/api/admin/dataset-info'),

  // Update dataset
  updateDataset: (formData) =>
    api.post('/api/admin/update-dataset', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    }),

  // Trigger model retraining
  retrainModel: () => api.post('/api/admin/retrain-model'),

  // Get model versions
  getModelVersions: () => api.get('/api/admin/model-versions'),
};

export default api;
