import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    host: '0.0.0.0',   // Необходимо для Docker
    port: 5173,
    // Docker Desktop на Windows не всегда пробрасывает inotify-события
    // из bind mount, поэтому включаем polling для стабильного HMR.
    watch: {
      usePolling: true,
      interval: 300,
    },
    // Проксируем API запросы на backend (только в dev режиме)
    proxy: {
      '/api': {
        target: 'http://localhost:4000',
        changeOrigin: true,
      },
      '/socket.io': {
        target: 'http://localhost:4000',
        ws: true,
        changeOrigin: true,
      },
    },
  },
});
