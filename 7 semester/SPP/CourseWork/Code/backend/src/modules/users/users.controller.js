/**
 * modules/users/users.controller.js
 */
const usersService = require('./users.service');

class UsersController {
  /** GET /api/users/students — учитель получает своих студентов */
  async getMyStudents(req, res, next) {
    try {
      const students = await usersService.getMyStudents(req.user.id);
      res.json({ students });
    } catch (e) { next(e); }
  }

  /** POST /api/users/students — привязать студента { email } */
  async addStudent(req, res, next) {
    try {
      const { email } = req.body;
      if (!email) return res.status(400).json({ error: 'Email обязателен' });
      const result = await usersService.addStudent(req.user.id, email);
      res.status(201).json(result);
    } catch (e) { next(e); }
  }

  /** DELETE /api/users/students/:studentId */
  async removeStudent(req, res, next) {
    try {
      const result = await usersService.removeStudent(req.user.id, req.params.studentId);
      res.json(result);
    } catch (e) { next(e); }
  }

  /** GET /api/users/dashboard — студент получает свой дашборд */
  async getStudentDashboard(req, res, next) {
    try {
      const data = await usersService.getStudentDashboard(req.user.id);
      res.json(data);
    } catch (e) { next(e); }
  }
}

module.exports = new UsersController();
