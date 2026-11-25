const bcrypt          = require('bcryptjs');
const { prisma }      = require('../../config/database');
const { generateToken } = require('../../config/jwt');
const { AppError }    = require('../../middleware/errorHandler');

const SALT_ROUNDS = 10;

class AuthService {
  async register({ email, password, firstName, lastName, role }) {
    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) {
      throw new AppError('Пользователь с таким email уже существует', 409);
    }

    if (!['TEACHER', 'STUDENT'].includes(role)) {
      throw new AppError('Роль должна быть TEACHER или STUDENT', 400);
    }

    const passwordHash = await bcrypt.hash(password, SALT_ROUNDS);

    const user = await prisma.user.create({
      data: { email, passwordHash, firstName, lastName, role },
      select: {
        id: true,
        email: true,
        firstName: true,
        lastName: true,
        role: true,
        createdAt: true,
      },
    });

    const token = generateToken({ id: user.id, email: user.email, role: user.role });

    return { user, token };
  }

  async login({ email, password }) {
    const user = await prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      throw new AppError('Неверный email или пароль', 401);
    }

    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      throw new AppError('Неверный email или пароль', 401);
    }

    const token = generateToken({ id: user.id, email: user.email, role: user.role });

    const { passwordHash: _, ...safeUser } = user;

    return { user: safeUser, token };
  }

  async getMe(userId) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        firstName: true,
        lastName: true,
        role: true,
        avatarUrl: true,
        createdAt: true,
      },
    });

    if (!user) {
      throw new AppError('Пользователь не найден', 404);
    }

    return user;
  }
}

module.exports = new AuthService();
