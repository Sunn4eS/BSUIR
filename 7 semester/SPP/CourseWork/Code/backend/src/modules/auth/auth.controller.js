const authService = require('./auth.service');

class AuthController {
  async register(req, res, next) {
    try {
      const { email, password, firstName, lastName, role } = req.body;

      if (!email || !password || !firstName || !lastName || !role) {
        return res.status(400).json({
          error: 'Все поля обязательны: email, password, firstName, lastName, role',
        });
      }

      if (password.length < 6) {
        return res.status(400).json({
          error: 'Пароль должен содержать минимум 6 символов',
        });
      }

      const result = await authService.register({ email, password, firstName, lastName, role });

      res.status(201).json({
        message: 'Регистрация прошла успешно',
        ...result,
      });
    } catch (error) {
      next(error);
    }
  }

  async login(req, res, next) {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        return res.status(400).json({ error: 'Email и пароль обязательны' });
      }

      const result = await authService.login({ email, password });

      res.json({
        message: 'Вход выполнен успешно',
        ...result,
      });
    } catch (error) {
      next(error);
    }
  }

  async getMe(req, res, next) {
    try {
      const user = await authService.getMe(req.user.id);
      res.json({ user });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new AuthController();
