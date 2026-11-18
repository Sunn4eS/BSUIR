# =============================================================
# Frontend Dockerfile — React + Vite
# Multi-stage: development (Vite dev server) / production (nginx)
# =============================================================

# ─── Development образ ────────────────────────────────────
FROM node:20-alpine AS development

WORKDIR /app

# Копируем манифесты пакетов
COPY package.json package-lock.json* ./
RUN npm ci

# Исходники монтируются через bind volume в docker-compose
EXPOSE 5173

# Vite dev server с host 0.0.0.0 (доступен снаружи контейнера)
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]

# ─── Production builder ───────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci
COPY . .

# Сборка production bundle
RUN npm run build

# ─── Production (nginx) ───────────────────────────────────
FROM nginx:alpine AS production

# Копируем собранное приложение
COPY --from=builder /app/dist /usr/share/nginx/html

# Конфиг nginx для SPA (React Router)
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
