import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import api, { clearAuthStorage, getToken } from '../api/axios';

const useAuthStore = create(
  persist(
    (set, get) => ({
      user:  null,
      token: null,
      isLoading: false,

      isCheckingAuth: true,

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
          set({ user: null, token: null, isCheckingAuth: false });
        }
      },

      logout: () => {
        clearAuthStorage();
        set({ user: null, token: null, isCheckingAuth: false });
      },

      fetchMe: async () => {
        try {
          const { data } = await api.get('/auth/me');
          set({ user: data.user });
        } catch {
          get().logout();
        }
      },

      isAuthenticated: () => !!get().token && !!get().user,
      isTeacher:       () => get().user?.role === 'TEACHER',
      isStudent:       () => get().user?.role === 'STUDENT',
    }),
    {
      name: 'guitar-trainer-auth',
      partialize: (state) => ({
        token: state.token,
        user:  state.user,
      }),
      onRehydrateStorage: () => (state) => {
        if (state?.token) {
          localStorage.setItem('gt_token', state.token);
        }
      },
    }
  )
);

export default useAuthStore;
