const { verifyToken } = require('../config/jwt');
const { AppError }    = require('./errorHandler');
const { prisma }      = require('../config/database');

async function authenticate(req, _res, next) {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new AppError('Токен авторизации не предоставлен', 401);
    }

    const token = authHeader.split(' ')[1];
    const decoded = verifyToken(token);

    const user = await prisma.user.findUnique({
      where: { id: decoded.id },
      select: { id: true, email: true, role: true, firstName: true, lastName: true },
    });

    if (!user) {
      throw new AppError('Пользователь не найден', 401);
    }

    req.user = { ...user, role: String(user.role ?? '').toUpperCase() };
    next();
  } catch (error) {
    next(error);
  }
}

module.exports = { authenticate };
