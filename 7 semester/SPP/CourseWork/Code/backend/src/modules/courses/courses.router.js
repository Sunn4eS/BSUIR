/**
 * modules/courses/courses.router.js
 *
 * Учитель:
 *   GET    /api/courses                                  — мои курсы
 *   GET    /api/courses/library                          — библиотека Live-урока
 *   POST   /api/courses                                  — создать курс (isPublished)
 *   GET    /api/courses/:id/enrollments                  — заявки на курс
 *   PATCH  /api/courses/:id/enrollments/:enrollmentId    — одобрить/отклонить заявку
 *   GET    /api/courses/:id/students                     — студенты курса + кандидаты
 *   POST   /api/courses/:id/students                     — добавить студента по email/id
 *   DELETE /api/courses/:id/students/:studentId          — исключить студента из курса
 *
 * Ученик:
 *   GET    /api/courses/catalog                          — каталог опубликованных курсов со статусом заявки
 *   POST   /api/courses/:id/enroll                       — отправить заявку на вступление (PENDING)
 *   GET    /api/courses/my-courses                       — мои одобренные курсы (APPROVED)
 *   GET    /api/courses/:id/tasks                        — задания курса (только если APPROVED или автор)
 *
 * Legacy:
 *   GET    /api/courses/available                        — опубликованные курсы
 *   GET    /api/courses/join-requests/mine               — мои заявки
 *   POST   /api/courses/:id/join                         — отправить заявку
 *   DELETE /api/courses/:id/join                         — отменить заявку
 *   GET    /api/courses/join-requests                    — заявки на мои курсы
 *   PATCH  /api/courses/join-requests/:requestId         — одобрить/отклонить заявку
 *
 * Общее:
 *   GET    /api/courses/:id                              — получить курс
 *   PUT    /api/courses/:id                              — обновить курс
 *   DELETE /api/courses/:id                              — удалить курс
 */

const { Router }       = require('express');
const c                = require('./courses.controller');
const enrollmentCtrl   = require('../../controllers/courseEnrollmentController');
const { authenticate } = require('../../middleware/authenticate');
const { requireTeacher, requireStudent, requireAnyRole } = require('../../middleware/roles');

const router = Router();
router.use(authenticate);

// ── Статические маршруты (ДО /:id) ───────────────────────────
router.get('/catalog',           requireAnyRole, enrollmentCtrl.getCatalog.bind(enrollmentCtrl));
router.get('/my-courses',        requireStudent, enrollmentCtrl.getMyCourses.bind(enrollmentCtrl));

router.get('/',                  requireTeacher, c.getMyCourses.bind(c));
router.get('/library',           requireTeacher, c.getLibrary.bind(c));

// Ученик (Legacy)
router.get('/available',          requireStudent, c.getAvailableCourses.bind(c));
router.get('/join-requests/mine', requireStudent, c.getMyJoinRequests.bind(c));

// Учитель: заявки (Legacy)
router.get('/join-requests',             requireTeacher, c.getJoinRequests.bind(c));
router.patch('/join-requests/:requestId', requireTeacher, c.reviewJoinRequest.bind(c));

// ── CRUD курса ───────────────────────────────────────────────
router.post('/',         requireTeacher, (req, res, next) => {
  // Если передан isPublished, используем enrollmentCtrl.createCourse
  if (req.body && req.body.isPublished !== undefined) {
    return enrollmentCtrl.createCourse(req, res, next);
  }
  return c.createCourse(req, res, next);
});

router.get('/:id',       requireAnyRole,  c.getCourse.bind(c));
router.put('/:id',       requireTeacher,  c.updateCourse.bind(c));
router.delete('/:id',    requireTeacher, c.deleteCourse.bind(c));

router.patch('/:id/publish',   requireTeacher, c.publishCourse.bind(c));
router.patch('/:id/unpublish', requireTeacher, c.unpublishCourse.bind(c));

// ── Задания курса для прохождения ────────────────────────────
router.get('/:id/tasks', requireAnyRole, enrollmentCtrl.getCourseTasks.bind(enrollmentCtrl));

// ── Заявки (Enrollments) курса (Учитель) ──────────────────────
router.get('/:id/enrollments', requireTeacher, enrollmentCtrl.getCourseEnrollments.bind(enrollmentCtrl));
router.patch('/:id/enrollments/:enrollmentId', requireTeacher, enrollmentCtrl.updateEnrollmentStatus.bind(enrollmentCtrl));

// ── Студенты курса (Учитель) ─────────────────────────────────
router.get('/:id/students',               requireTeacher, c.getCourseStudents.bind(c));
router.post('/:id/students',              requireTeacher, (req, res, next) => {
  // Прямое добавление по email/id
  return enrollmentCtrl.addStudent(req, res, next);
});
router.delete('/:id/students/:studentId', requireTeacher, enrollmentCtrl.removeStudent.bind(enrollmentCtrl));

// ── Запись/заявки ученика (Enrollment) ────────────────────────
router.post('/:id/enroll',                requireStudent, enrollmentCtrl.enroll.bind(enrollmentCtrl));
router.delete('/:id/enroll/:studentId',   requireTeacher, enrollmentCtrl.removeStudent.bind(enrollmentCtrl));

// Legacy заявки
router.post('/:id/join',   requireStudent, c.requestJoin.bind(c));
router.delete('/:id/join', requireStudent, c.cancelJoin.bind(c));

module.exports = router;
