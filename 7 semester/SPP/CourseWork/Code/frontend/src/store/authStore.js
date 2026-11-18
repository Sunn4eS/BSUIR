/**
 * store/authStore.js — глобальное состояние авторизации (Zustand)
 * Хранит текущего пользователя и JWT токен
 *
 * isCheckingAuth: при старте приложения проверяем токен через
 * GET /api/auth/me — до завершения проверки маршруты не делают
 * редиректов (иначе Dashboard ↔ Login зацикливались).
 */

import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import api, { clearAuthStorage, getToken } from '../api/axios';

const useAuthStore = create(
  persist(
    (set, get) => ({
      user:  null,
      token: null,
      isLoading: false,

      // Идёт проверка сохранённого токена на сервере
      isCheckingAuth: true,

      // ── Логин ───────────────────────────────────────────────
      login: async (email, password) => {
        set({ isLoading: true });
        try {
          const { data } = await api.post('/auth/login', { email, password });
          localStorage.setItem('gt_token', data.token);
          set({ user: data.user, token: data.token, isLoading: false, isCheckingAuth: false });
          return { success: true };
        } catch (err) {
          set({ isLoading: false });
          const message = err.response?.data?.error || 'Ошибка входа';
          return { success: false, error: message };
        }
      },

      // ── Регистрация ──────────────────────────────────────────
      register: async (formData) => {
        set({ isLoading: true });
        try {
          const { data } = await api.post('/auth/register', formData);
          localStorage.setItem('gt_token', data.token);
          set({ user: data.user, token: data.token, isLoading: false, isCheckingAuth: false });
          return { success: true };
        } catch (err) {
          set({ isLoading: false });
          const message = err.response?.data?.error || 'Ошибка регистрации';
          return { success: false, error: message };
        }
      },

      // ── Проверка сохранённого токена (вызывается при старте) ──
      checkAuth: async () => {
        const token = get().token || getToken();

        if (!token) {
          set({ isCheckingAuth: false, user: null, token: null });
          return;
        }

        try {
          const { data } = await api.get('/auth/me');
          set({ user: data.user, token, isCheckingAuth: false });
        } catch {
          // 401 уже очистил хранилища в axios-интерцепторе —
          // просто обнуляем состояние
          set({ user: null, token: null, isCheckingAuth: false });
        }
      },

      // ── Выход ───────────────────────────────────────────────
      logout: () => {
        // Чистим и gt_token, и zustand-persist ключ, иначе
        // устаревший токен в persist снова «воскресит» сессию
        clearAuthStorage();
        set({ user: null, token: null, isCheckingAuth: false });
      },

      // ── Обновить данные пользователя из API ─────────────────
      fetchMe: async () => {
        try {
          const { data } = await api.get('/auth/me');
          set({ user: data.user });
        } catch {
          get().logout();
        }
      },

      // ── Геттеры ─────────────────────────────────────────────
      isAuthenticated: () => !!get().token && !!get().user,
      isTeacher:       () => get().user?.role === 'TEACHER',
      isStudent:       () => get().user?.role === 'STUDENT',
    }),
    {
      name: 'guitar-trainer-auth',   // Ключ в localStorage
      partialize: (state) => ({      // Сохраняем только эти поля
        token: state.token,
        user:  state.user,
      }),
      // После регидрации бэкфиллим gt_token — им пользуются
      // axios-интерцептор и Socket.io подключение
      onRehydrateStorage: () => (state) => {
        if (state?.token) {
          localStorage.setItem('gt_token', state.token);
        }
      },
    }
  )
);

export default useAuthStore;
