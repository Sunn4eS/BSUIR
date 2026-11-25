const { Router }         = require('express');
const usersController    = require('./users.controller');
const { authenticate }   = require('../../middleware/authenticate');
const { requireTeacher, requireStudent } = require('../../middleware/roles');

const router = Router();

router.use(authenticate);

router.get('/students',        requireTeacher, usersController.getMyStudents.bind(usersController));
router.post('/students',       requireTeacher, usersController.addStudent.bind(usersController));
router.delete('/students/:studentId', requireTeacher, usersController.removeStudent.bind(usersController));

router.get('/dashboard',       requireStudent, usersController.getStudentDashboard.bind(usersController));

module.exports = router;
