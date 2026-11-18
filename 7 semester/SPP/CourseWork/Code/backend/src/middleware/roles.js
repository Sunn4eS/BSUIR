/**
 * middleware/roles.js — ролевые guard-ы
 * Используются ПОСЛЕ middleware authenticate
 * Пример использования:
 *   router.post('/course', authenticate, requireTeacher, createCourse)
 */

const { AppError } = require('./errorHandler');

/**
 * Нормализует роль для сравнения (без учёта регистра)
 */
function normalizeRole(role) {
  if (!role || typeof role !== 'string') return '';
  return role.trim().toUpperCase();
}

/**
 * Разрешает доступ только пользователям с ролью TEACHER
 */
function requireTeacher(req, _res, next) {
  const role = normalizeRole(req.user?.role);
  if (role !== 'TEACHER') {
    return next(new AppError('Разрешено только для учителя', 403));
  }
  next();
}

/**
 * Разрешает доступ только пользователям с ролью STUDENT
 */
function requireStudent(req, _res, next) {
  const role = normalizeRole(req.user?.role);
  if (role !== 'STUDENT') {
    return next(new AppError('Доступ разрешён только для студентов', 403));
  }
  next();
}

/**
 * Разрешает доступ любому аутентифицированному пользователю
 * (использовать вместе с authenticate, не вместо)
 */
function requireAnyRole(req, _res, next) {
  if (!req.user) {
    return next(new AppError('Аутентификация обязательна', 401));
  }
  next();
}

module.exports = { requireTeacher, requireStudent, requireAnyRole };
