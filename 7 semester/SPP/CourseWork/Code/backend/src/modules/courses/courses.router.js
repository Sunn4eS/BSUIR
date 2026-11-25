const { Router }       = require('express');
const c                = require('./courses.controller');
const enrollmentCtrl   = require('../../controllers/courseEnrollmentController');
const { authenticate } = require('../../middleware/authenticate');
const { requireTeacher, requireStudent, requireAnyRole } = require('../../middleware/roles');

const router = Router();
router.use(authenticate);

router.get('/catalog',           requireAnyRole, enrollmentCtrl.getCatalog.bind(enrollmentCtrl));
router.get('/my-courses',        requireStudent, enrollmentCtrl.getMyCourses.bind(enrollmentCtrl));

router.get('/',                  requireTeacher, c.getMyCourses.bind(c));
router.get('/library',           requireTeacher, c.getLibrary.bind(c));

router.get('/available',          requireStudent, c.getAvailableCourses.bind(c));
router.get('/join-requests/mine', requireStudent, c.getMyJoinRequests.bind(c));

router.get('/join-requests',             requireTeacher, c.getJoinRequests.bind(c));
router.patch('/join-requests/:requestId', requireTeacher, c.reviewJoinRequest.bind(c));

router.post('/',         requireTeacher, (req, res, next) => {
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

router.get('/:id/tasks', requireAnyRole, enrollmentCtrl.getCourseTasks.bind(enrollmentCtrl));

router.get('/:id/enrollments', requireTeacher, enrollmentCtrl.getCourseEnrollments.bind(enrollmentCtrl));
router.patch('/:id/enrollments/:enrollmentId', requireTeacher, enrollmentCtrl.updateEnrollmentStatus.bind(enrollmentCtrl));

router.get('/:id/students',               requireTeacher, c.getCourseStudents.bind(c));
router.post('/:id/students',              requireTeacher, (req, res, next) => {
  return enrollmentCtrl.addStudent(req, res, next);
});
router.delete('/:id/students/:studentId', requireTeacher, enrollmentCtrl.removeStudent.bind(enrollmentCtrl));

router.post('/:id/enroll',                requireStudent, enrollmentCtrl.enroll.bind(enrollmentCtrl));
router.delete('/:id/enroll/:studentId',   requireTeacher, enrollmentCtrl.removeStudent.bind(enrollmentCtrl));

router.post('/:id/join',   requireStudent, c.requestJoin.bind(c));
router.delete('/:id/join', requireStudent, c.cancelJoin.bind(c));

module.exports = router;
