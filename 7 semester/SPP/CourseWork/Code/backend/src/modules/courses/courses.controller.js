/**
 * modules/courses/courses.controller.js
 * Контроллер только принимает/валидирует HTTP-слой,
 * вся бизнес-логика — в courses.service.js
 */
const coursesService = require('./courses.service');
const { AppError }    = require('../../middleware/errorHandler');

/** Поля, которые учитель может передать при создании курса */
const CREATABLE_FIELDS = ['title', 'description', 'status'];

function pickFields(body = {}, fields) {
  const picked = {};
  for (const field of fields) {
    if (body[field] !== undefined) picked[field] = body[field];
  }
  return picked;
}

class CoursesController {
  async getMyCourses(req, res, next) {
    try {
      const courses = await coursesService.getTeacherCourses(req.user.id);
      res.json({ courses });
    } catch (e) { next(e); }
  }

  async getCourse(req, res, next) {
    try {
      const course = await coursesService.getCourseById(
        req.params.id, req.user.id, req.user.role
      );
      res.json({ course });
    } catch (e) { next(e); }
  }

  /**
   * POST /api/courses — создать курс
   * Body: { title, description?, status?: 'draft' | 'published' }
   * Курс всегда привязывается к авторизованному учителю (req.user.id)
   */
  async createCourse(req, res, next) {
    try {
      if (!req.user?.id) {
        throw new AppError('Требуется авторизация', 401);
      }

      const dto = pickFields(req.body, CREATABLE_FIELDS);
      const course = await coursesService.createCourse(req.user.id, dto);
      res.status(201).json({ course });
    } catch (e) { next(e); }
  }

  async updateCourse(req, res, next) {
    try {
      const course = await coursesService.updateCourse(
        req.params.id, req.user.id, req.body
      );
      res.json({ course });
    } catch (e) { next(e); }
  }

  async getLibrary(req, res, next) {
    try {
      const courses = await coursesService.getTeacherLibrary(req.user.id);
      res.json({ courses });
    } catch (e) { next(e); }
  }

  async publishCourse(req, res, next) {
    try {
      const course = await coursesService.publishCourse(req.params.id, req.user.id);
      res.json({ course });
    } catch (e) { next(e); }
  }

  async unpublishCourse(req, res, next) {
    try {
      const course = await coursesService.unpublishCourse(req.params.id, req.user.id);
      res.json({ course });
    } catch (e) { next(e); }
  }

  async deleteCourse(req, res, next) {
    try {
      const result = await coursesService.deleteCourse(req.params.id, req.user.id);
      res.json(result);
    } catch (e) { next(e); }
  }

  async enrollStudent(req, res, next) {
    try {
      const { studentId } = req.body;
      if (!studentId) return res.status(400).json({ error: 'studentId обязателен' });
      const enrollment = await coursesService.enrollStudent(
        req.params.id, studentId, req.user.id
      );
      res.status(201).json({ enrollment });
    } catch (e) { next(e); }
  }

  async unenrollStudent(req, res, next) {
    try {
      const result = await coursesService.unenrollStudent(
        req.params.id, req.params.studentId, req.user.id
      );
      res.json(result);
    } catch (e) { next(e); }
  }

  // ── Ученик: доступные курсы и заявки ───────────────────────

  async getAvailableCourses(req, res, next) {
    try {
      const courses = await coursesService.getAvailableCourses(req.user.id);
      res.json({ courses });
    } catch (e) { next(e); }
  }

  async requestJoin(req, res, next) {
    try {
      const request = await coursesService.requestJoin(
        req.params.id, req.user.id, req.body?.message
      );
      res.status(201).json({ request });
    } catch (e) { next(e); }
  }

  async cancelJoin(req, res, next) {
    try {
      const result = await coursesService.cancelJoin(req.params.id, req.user.id);
      res.json(result);
    } catch (e) { next(e); }
  }

  async getMyJoinRequests(req, res, next) {
    try {
      const requests = await coursesService.getMyJoinRequests(req.user.id);
      res.json({ requests });
    } catch (e) { next(e); }
  }

  // ── Учитель: заявки и студенты курса ───────────────────────

  async getJoinRequests(req, res, next) {
    try {
      const requests = await coursesService.getTeacherJoinRequests(
        req.user.id, req.query.status
      );
      res.json({ requests });
    } catch (e) { next(e); }
  }

  async reviewJoinRequest(req, res, next) {
    try {
      const { decision } = req.body || {};
      const result = await coursesService.reviewJoinRequest(
        req.params.requestId, req.user.id, decision
      );
      res.json(result);
    } catch (e) { next(e); }
  }

  async getCourseStudents(req, res, next) {
    try {
      const result = await coursesService.getCourseStudents(req.params.id, req.user.id);
      res.json(result);
    } catch (e) { next(e); }
  }

  async addCourseStudent(req, res, next) {
    try {
      const result = await coursesService.addStudentToCourse(
        req.params.id, req.user.id, req.body || {}
      );
      res.status(201).json(result);
    } catch (e) { next(e); }
  }
}

module.exports = new CoursesController();
