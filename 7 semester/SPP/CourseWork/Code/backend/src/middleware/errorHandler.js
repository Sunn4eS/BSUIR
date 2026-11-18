/**
 * middleware/errorHandler.js — глобальный обработчик ошибок
 * Перехватывает все ошибки Express и возвращает унифицированный JSON
 */

/**
 * Кастомный класс ошибки с HTTP статус-кодом
 */
class AppError extends Error {
  /**
   * @param {string} message
   * @param {number} statusCode
   */
  constructor(message, statusCode = 500) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true; // Ожидаемая ошибка (не баг)
  }
}

/**
 * Express error handler middleware (4 аргумента обязательны)
 */
function errorHandler(err, _req, res, _next) {
  // Логируем только неожиданные ошибки
  if (!err.isOperational) {
    console.error('💥 Неожиданная ошибка:', err);
  }

  // Prisma ошибки
  if (err.code === 'P2002') {
    return res.status(409).json({
      error: 'Запись с такими данными уже существует',
    });
  }
  if (err.code === 'P2025') {
    return res.status(404).json({
      error: 'Запись не найдена',
    });
  }

  // JWT ошибки
  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json({ error: 'Недействительный токен' });
  }
  if (err.name === 'TokenExpiredError') {
    return res.status(401).json({ error: 'Срок действия токена истёк' });
  }

  // Ошибки валидации
  if (err.name === 'ValidationError') {
    return res.status(400).json({ error: err.message });
  }

  const statusCode = err.statusCode || 500;
  const message    = err.isOperational
    ? err.message
    : 'Внутренняя ошибка сервера';

  res.status(statusCode).json({ error: message });
}

module.exports = { errorHandler, AppError };
