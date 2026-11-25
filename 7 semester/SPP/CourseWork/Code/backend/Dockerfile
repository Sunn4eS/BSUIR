FROM node:20-alpine AS base
WORKDIR /app

RUN apk add --no-cache openssl

COPY package.json package-lock.json* ./

FROM base AS development

RUN npm ci

COPY prisma ./prisma
RUN npx prisma generate

EXPOSE 4000

CMD ["npm", "run", "dev"]

FROM base AS builder

RUN npm ci --only=production
COPY prisma ./prisma
RUN npx prisma generate
COPY . .

FROM node:20-alpine AS production

WORKDIR /app

RUN apk add --no-cache openssl

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/src ./src
COPY --from=builder /app/package.json ./

EXPOSE 4000

CMD ["node", "src/server.js"]
