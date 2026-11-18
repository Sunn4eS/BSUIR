/**
 * config/jwt.js — конфигурация JWT
 * Утилиты для генерации и верификации токенов
 */

const jwt = require('jsonwebtoken');

const JWT_SECRET  = process.env.JWT_SECRET  || 'dev_secret_change_in_prod';
const JWT_EXPIRES = process.env.JWT_EXPIRES_IN || '7d';

/**
 * Генерирует JWT токен для пользователя
 * @param {{ id: string, email: string, role: string }} payload
 * @returns {string} Подписанный JWT токен
 */
function generateToken(payload) {
  const role = String(payload.role ?? '').trim().toUpperCase();

  // role обязательна: без неё ролевые middleware отдадут 403
  if (!['TEACHER', 'STUDENT'].includes(role)) {
    throw new Error('JWT payload должен содержать корректную роль (TEACHER/STUDENT)');
  }

  return jwt.sign(
    { ...payload, role },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES }
  );
}

/**
 * Верифицирует JWT токен
 * @param {string} token
 * @returns {{ id: string, email: string, role: string }} Декодированный payload
 * @throws {jwt.JsonWebTokenError | jwt.TokenExpiredError}
 */
function verifyToken(token) {
  return jwt.verify(token, JWT_SECRET);
}

module.exports = { generateToken, verifyToken };
