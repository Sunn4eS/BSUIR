/**
 * api/axios.js — настроенный Axios instance
 * Автоматически добавляет JWT токен к каждому запросу.
 *
 * Устойчивость к рассинхрону хранилищ: токен живёт в двух местах —
 * в gt_token и в zustand-persist ключе guitar-trainer-auth. Раньше
 * при 401 чистился только gt_token, persist продолжал держать
 * устаревший токен → Dashboard ↔ Login редиректили друг друга по
 * кругу. Теперь getToken() читает оба хранилища, а очистка при 401
 * убирает все ключи сразу.
 */

import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:4000';
const AUTH_STORAGE_KEY = 'guitar-trainer-auth'; // zustand persist

/**
 * Достаёт JWT из localStorage.
 * Приоритет: gt_token; если пусто — пробуем zustand-persist
 * и бэкфиллим gt_token.
 */
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
      // повреждённый JSON в persist — игнорируем
    }
  }

  return token;
}

/** Полная очистка всех хранилищ авторизации (гарантирует отсутствие цикла) */
export function clearAuthStorage() {
  localStorage.removeItem('gt_token');
  localStorage.removeItem('gt_user');
  localStorage.removeItem(AUTH_STORAGE_KEY);
}

const api = axios.create({
  baseURL: `${API_URL}/api`,
  headers: { 'Content-Type': 'application/json' },
});

// ─── Request Interceptor: добавляем Bearer токен ────────────────
api.interceptors.request.use((config) => {
  const token = getToken();
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// ─── Response Interceptor: обрабатываем 401 ────────────────────
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Токен истёк/невалиден — чистим ВСЕ хранилища и разлогиниваем.
      // Иначе persist-ключ с устаревшим токеном снова «возвращает»
      // пользователя на /dashboard и получается цикл редиректов.
      clearAuthStorage();
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default api;
