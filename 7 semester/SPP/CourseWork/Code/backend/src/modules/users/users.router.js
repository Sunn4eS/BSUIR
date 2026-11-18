/**
 * modules/users/users.router.js
 *
 * GET    /api/users/students         — учитель: список студентов
 * POST   /api/users/students         — учитель: добавить студента
 * DELETE /api/users/students/:id     — учитель: удалить студента
 * GET    /api/users/dashboard        — студент: свой дашборд
 */

const { Router }         = require('express');
const usersController    = require('./users.controller');
const { authenticate }   = require('../../middleware/authenticate');
const { requireTeacher, requireStudent } = require('../../middleware/roles');

const router = Router();

// Все маршруты защищены
router.use(authenticate);

// Учитель
router.get('/students',        requireTeacher, usersController.getMyStudents.bind(usersController));
router.post('/students',       requireTeacher, usersController.addStudent.bind(usersController));
router.delete('/students/:studentId', requireTeacher, usersController.removeStudent.bind(usersController));

// Студент
router.get('/dashboard',       requireStudent, usersController.getStudentDashboard.bind(usersController));

module.exports = router;
