/**
 * config/database.js — Prisma Client (singleton)
 * Экспортирует единственный экземпляр PrismaClient
 * для всего приложения (избегает лишних соединений)
 */

const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient({
  log: process.env.NODE_ENV === 'development'
    ? ['query', 'info', 'warn', 'error']
    : ['error'],
});

module.exports = { prisma };
