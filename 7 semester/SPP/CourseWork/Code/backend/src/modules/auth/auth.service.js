/**
 * modules/auth/auth.service.js — бизнес-логика авторизации
 * Здесь вся логика: хэширование паролей, генерация токенов
 * Контроллер только делегирует — логики в нём нет
 */

const bcrypt          = require('bcryptjs');
const { prisma }      = require('../../config/database');
const { generateToken } = require('../../config/jwt');
const { AppError }    = require('../../middleware/errorHandler');

const SALT_ROUNDS = 10;

class AuthService {
  /**
   * Регистрация нового пользователя
   * @param {{ email, password, firstName, lastName, role }} dto
   * @returns {{ user, token }}
   */
  async register({ email, password, firstName, lastName, role }) {
    // Проверяем, что email свободен
    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) {
      throw new AppError('Пользователь с таким email уже существует', 409);
    }

    // Валидируем роль
    if (!['TEACHER', 'STUDENT'].includes(role)) {
      throw new AppError('Роль должна быть TEACHER или STUDENT', 400);
    }

    // Хэшируем пароль
    const passwordHash = await bcrypt.hash(password, SALT_ROUNDS);

    // Создаём пользователя
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

    // Генерируем JWT
    const token = generateToken({ id: user.id, email: user.email, role: user.role });

    return { user, token };
  }

  /**
   * Вход в систему
   * @param {{ email, password }} dto
   * @returns {{ user, token }}
   */
  async login({ email, password }) {
    // Ищем пользователя
    const user = await prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      // Намеренно размытое сообщение (безопасность)
      throw new AppError('Неверный email или пароль', 401);
    }

    // Проверяем пароль
    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      throw new AppError('Неверный email или пароль', 401);
    }

    // Генерируем JWT
    const token = generateToken({ id: user.id, email: user.email, role: user.role });

    // Возвращаем без passwordHash
    const { passwordHash: _, ...safeUser } = user;

    return { user: safeUser, token };
  }

  /**
   * Получить текущего пользователя по ID из токена
   * @param {string} userId
   * @returns {object} Данные пользователя (без пароля)
   */
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
