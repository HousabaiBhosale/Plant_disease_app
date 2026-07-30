// Dynamically resolve API URL based on current host so it works live on LAN with Flutter/Mobile apps
const API_BASE_URL = `http://${window.location.hostname}:8000`;
const API_URL = `${API_BASE_URL}/api`;

class ApiService {
  constructor() {
    this.token = localStorage.getItem('token');
  }

  setToken(token) {
    this.token = token;
    if (token) {
      localStorage.setItem('token', token);
    } else {
      localStorage.removeItem('token');
    }
  }

  async fetchApi(endpoint, options = {}) {
    const headers = {
      'Content-Type': 'application/json',
      ...options.headers,
    };

    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }

    // Remove Content-Type for FormData (browser sets it with boundary)
    if (options.body instanceof FormData) {
      delete headers['Content-Type'];
    }

    try {
      const response = await fetch(`${API_URL}${endpoint}`, {
        ...options,
        headers,
      });

      if (!response.ok) {
        let errorData = {};
        try {
          errorData = await response.json();
        } catch (e) { }

        const isAuthError = response.status === 401 || (response.status === 403 && errorData.detail === "Not authenticated");

        if (isAuthError) {
          this.setToken(null);
          if (!window.location.pathname.endsWith('login.php')) {
            window.location.href = 'login.php';
          }
        }

        throw new Error(errorData.detail || 'API request failed');
      }

      return await response.json();
    } catch (error) {
      console.error('API Error:', error);
      throw error;
    }
  }

  // Auth
  async login(email, password) {
    const response = await this.fetchApi('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });
    this.setToken(response.access_token);
    return response;
  }

  async logout() {
    try {
      await this.fetchApi('/auth/logout', { method: 'POST' });
    } catch (e) {
      // Ignore errors on logout
    } finally {
      this.setToken(null);
      window.location.href = 'login.php';
    }
  }

  async updateProfile(name, email) {
    return this.fetchApi(`/auth/update-profile?name=${encodeURIComponent(name)}&email=${encodeURIComponent(email)}`, {
      method: 'POST',
    });
  }

  async changePassword(oldPassword, newPassword) {
    return this.fetchApi(`/auth/change-password?old_password=${encodeURIComponent(oldPassword)}&new_password=${encodeURIComponent(newPassword)}`, {
      method: 'POST',
    });
  }

  // Admin Stats & Overview
  async getStats(days = 30) {
    return this.fetchApi(`/admin/stats?days=${days}`);
  }

  async getAdminStats(days = 30) {
    return this.getStats(days);
  }

  async getDailyAnalytics(days = 30) {
    return this.fetchApi(`/admin/analytics/daily?days=${days}`);
  }

  async getPredictions(page = 1, limit = 50) {
    return this.fetchApi(`/admin/predictions?page=${page}&limit=${limit}`);
  }

  async getFeedback(page = 1, limit = 50) {
    return this.fetchApi(`/admin/feedback?page=${page}&limit=${limit}`);
  }

  async getUsersTracking() {
    return this.fetchApi('/admin/users-tracking');
  }

  async getModelMetrics() {
    return this.fetchApi('/admin/model-metrics');
  }

  async getDatasetInfo() {
    return this.fetchApi('/admin/dataset-info');
  }

  async retrainModel() {
    return this.fetchApi('/admin/retrain-model', {
      method: 'POST',
    });
  }

  async getModelVersions() {
    return this.fetchApi('/admin/model-versions');
  }

  async getSystemHealth() {
    const response = await fetch(`${API_BASE_URL}/health`);
    return await response.json();
  }

  // Datasets (Multi-dataset management)
  async getDatasets() {
    return this.fetchApi('/datasets/');
  }

  async uploadDataset(file, name, description) {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('dataset_name', name);
    formData.append('description', description || '');

    return this.fetchApi('/datasets/upload', {
      method: 'POST',
      body: formData,
    });
  }

  // Models & Training (Multi-dataset training)
  async getModels() {
    return this.fetchApi('/training/models');
  }

  async activateModel(modelId) {
    return this.fetchApi(`/training/models/${modelId}/activate`, {
      method: 'POST',
    });
  }

  async startTraining(datasetIds) {
    return this.fetchApi('/training/train', {
      method: 'POST',
      body: JSON.stringify({ dataset_ids: datasetIds }),
    });
  }
}

const api = new ApiService();
