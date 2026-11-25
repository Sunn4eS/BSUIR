const { Router }       = require('express');
const c                = require('./tasks.controller');
const enrollmentCtrl   = require('../../controllers/courseEnrollmentController');
const { authenticate } = require('../../middleware/authenticate');
const { requireTeacher, requireStudent } = require('../../middleware/roles');

const router = Router();
router.use(authenticate);

router.get('/templates',                    requireTeacher, c.getTemplates.bind(c));
router.get('/results/course/:courseId',     requireStudent, c.getResults.bind(c));

router.post('/course/:courseId',            requireTeacher, c.createTask.bind(c));
router.put('/:id',                          requireTeacher, c.updateTask.bind(c));
router.delete('/:id',                       requireTeacher, c.deleteTask.bind(c));

router.post('/:taskId/result',              requireStudent, c.submitResult.bind(c));
router.post('/:id/submit',                  requireStudent, enrollmentCtrl.submitTaskResult.bind(enrollmentCtrl));

module.exports = router;
