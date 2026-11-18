# =============================================================
# Backend Dockerfile — Node.js + Express + Prisma
# Multi-stage: development (hot-reload) / production (оптимизация)
# =============================================================

# ─── Базовый образ ────────────────────────────────────────
FROM node:20-alpine AS base
WORKDIR /app

# Устанавливаем системные зависимости для Prisma (openssl)
RUN apk add --no-cache openssl

# Копируем манифесты пакетов
COPY package.json package-lock.json* ./

# ─── Development образ ────────────────────────────────────
FROM base AS development

# Устанавливаем ВСЕ зависимости (включая devDependencies)
RUN npm ci

# Копируем Prisma схему и генерируем клиент
COPY prisma ./prisma
RUN npx prisma generate

# Исходники монтируются через volume в docker-compose
# Поэтому COPY . . здесь не нужен — используем bind mount

EXPOSE 4000

# nodemon для горячей перезагрузки
CMD ["npm", "run", "dev"]

# ─── Production builder ───────────────────────────────────
FROM base AS builder

RUN npm ci --only=production
COPY prisma ./prisma
RUN npx prisma generate
COPY . .

# Компилируем TypeScript (если используешь TS)
# RUN npm run build

# ─── Production образ ─────────────────────────────────────
FROM node:20-alpine AS production

WORKDIR /app

RUN apk add --no-cache openssl

# Копируем только production артефакты
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/src ./src
COPY --from=builder /app/package.json ./

EXPOSE 4000

CMD ["node", "src/server.js"]
