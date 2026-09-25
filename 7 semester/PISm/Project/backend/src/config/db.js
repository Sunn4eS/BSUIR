'use strict';

const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT || 5432),
  user: process.env.DB_USER || 'bank',
  password: process.env.DB_PASSWORD || 'bankpass',
  database: process.env.DB_NAME || 'bankdb',
});

// Короткий тест подключения при старте (не блокирует запуск)
pool.on('error', (err) => {
  console.error('Неожиданная ошибка пула подключений PostgreSQL', err);
});

module.exports = pool;