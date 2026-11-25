import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:4000';
const AUTH_STORAGE_KEY = 'guitar-trainer-auth';

export function getToken() {
  let token = localStorage.getItem('gt_token');

  if (!token) {
    try {
      const raw = localStorage.getItem(AUTH_STORAGE_KEY);
      if (raw) {
        const parsed = JSON.parse(raw);
        token = parsed?.state?.token || null;
        if (token) {
          localStorage.setItem('gt_token', token);
        }
      }
    } catch {
    }
  }

  return token;
}

export function clearAuthStorage() {
  localStorage.removeItem('gt_token');
  localStorage.removeItem('gt_user');
  localStorage.removeItem(AUTH_STORAGE_KEY);
}

const api = axios.create({
  baseURL: `${API_URL}/api`,
  headers: { 'Content-Type': 'application/json' },
});

api.interceptors.request.use((config) => {
  const token = getToken();
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      clearAuthStorage();
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default api;
