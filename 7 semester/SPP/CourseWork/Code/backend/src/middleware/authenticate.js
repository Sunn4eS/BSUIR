/**
 * middleware/authenticate.js — JWT аутентификация
 * Извлекает и верифицирует Bearer токен из заголовка Authorization
 * Прикрепляет декодированного пользователя к req.user
 */

const { verifyToken } = require('../config/jwt');
const { AppError }    = require('./errorHandler');
const { prisma }      = require('../config/database');

/**
 * Middleware: проверяет JWT токен в заголовке Authorization
 * После успеха: req.user = { id, email, role }
 */
async function authenticate(req, _res, next) {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new AppError('Токен авторизации не предоставлен', 401);
    }

    const token = authHeader.split(' ')[1];
    const decoded = verifyToken(token); // Бросает ошибку если токен неверный

    // Проверяем, что пользователь всё ещё существует в БД
    const user = await prisma.user.findUnique({
      where: { id: decoded.id },
      select: { id: true, email: true, role: true, firstName: true, lastName: true },
    });

    if (!user) {
      throw new AppError('Пользователь не найден', 401);
    }

    // Нормализуем роль: ролевые middleware и сервисы сравнивают
    // её с 'TEACHER'/'STUDENT', поэтому приводим к верхнему регистру.
    req.user = { ...user, role: String(user.role ?? '').toUpperCase() };
    next();
  } catch (error) {
    next(error);
  }
}

module.exports = { authenticate };
