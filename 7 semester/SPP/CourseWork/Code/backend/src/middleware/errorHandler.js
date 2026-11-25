class AppError extends Error {
  constructor(message, statusCode = 500) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;
  }
}

function errorHandler(err, _req, res, _next) {
  if (!err.isOperational) {
    console.error('💥 Неожиданная ошибка:', err);
  }

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

  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json({ error: 'Недействительный токен' });
  }
  if (err.name === 'TokenExpiredError') {
    return res.status(401).json({ error: 'Срок действия токена истёк' });
  }

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
