const { AppError } = require('./errorHandler');

function normalizeRole(role) {
  if (!role || typeof role !== 'string') return '';
  return role.trim().toUpperCase();
}

function requireTeacher(req, _res, next) {
  const role = normalizeRole(req.user?.role);
  if (role !== 'TEACHER') {
    return next(new AppError('Разрешено только для учителя', 403));
  }
  next();
}

function requireStudent(req, _res, next) {
  const role = normalizeRole(req.user?.role);
  if (role !== 'STUDENT') {
    return next(new AppError('Доступ разрешён только для студентов', 403));
  }
  next();
}

function requireAnyRole(req, _res, next) {
  if (!req.user) {
    return next(new AppError('Аутентификация обязательна', 401));
  }
  next();
}

module.exports = { requireTeacher, requireStudent, requireAnyRole };
