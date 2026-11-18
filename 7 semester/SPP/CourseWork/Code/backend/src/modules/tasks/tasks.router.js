/**
 * modules/tasks/tasks.router.js
 *
 * POST   /api/tasks/course/:courseId          — учитель: создать задание
 * PUT    /api/tasks/:id                       — учитель: обновить задание
 * DELETE /api/tasks/:id                       — учитель: удалить задание
 * GET    /api/tasks/templates                 — учитель: шаблоны
 * POST   /api/tasks/:taskId/result            — студент: сдать результат (legacy)
 * POST   /api/tasks/:id/submit                — студент: сдать результат (TaskResult)
 * GET    /api/tasks/results/course/:courseId  — студент: свои результаты
 */

const { Router }       = require('express');
const c                = require('./tasks.controller');
const enrollmentCtrl   = require('../../controllers/courseEnrollmentController');
const { authenticate } = require('../../middleware/authenticate');
const { requireTeacher, requireStudent } = require('../../middleware/roles');

const router = Router();
router.use(authenticate);

// Важно: /templates и /results должны быть ДО /:id чтобы не перехватывались
router.get('/templates',                    requireTeacher, c.getTemplates.bind(c));
router.get('/results/course/:courseId',     requireStudent, c.getResults.bind(c));

router.post('/course/:courseId',            requireTeacher, c.createTask.bind(c));
router.put('/:id',                          requireTeacher, c.updateTask.bind(c));
router.delete('/:id',                       requireTeacher, c.deleteTask.bind(c));

// Сдача результата
router.post('/:taskId/result',              requireStudent, c.submitResult.bind(c));
router.post('/:id/submit',                  requireStudent, enrollmentCtrl.submitTaskResult.bind(enrollmentCtrl));

module.exports = router;
