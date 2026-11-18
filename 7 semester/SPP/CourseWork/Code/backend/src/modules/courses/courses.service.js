/**
 * modules/courses/courses.service.js — CRUD курсов и публикация
 */

const { prisma } = require('../../config/database');
const { AppError } = require('../../middleware/errorHandler');

/** Поля курса, которые учитель может менять */
const EDITABLE_FIELDS = ['title', 'description'];

function pickEditable(data = {}) {
  return EDITABLE_FIELDS.reduce((acc, field) => {
    if (data[field] !== undefined) acc[field] = data[field];
    return acc;
  }, {});
}

class CoursesService {
  /** Получить все курсы учителя (включая черновики) */
  async getTeacherCourses(teacherId) {
    return prisma.course.findMany({
      where: { teacherId },
      include: {
        tasks: { orderBy: { orderIndex: 'asc' } },
        _count: { select: { tasks: true, studentCourses: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  /** Библиотека опубликованных курсов и заданий для Live-урока */
  async getTeacherLibrary(teacherId) {
    return prisma.course.findMany({
      where: { teacherId, status: 'PUBLISHED' },
      include: {
        tasks: { orderBy: { orderIndex: 'asc' } },
      },
      orderBy: { publishedAt: 'desc' },
    });
  }

  /** Получить курс по ID (проверяем ownership) */
  async getCourseById(courseId, userId, role) {
    const course = await prisma.course.findUnique({
      where: { id: courseId },
      include: {
        tasks: { orderBy: { orderIndex: 'asc' } },
        teacher: { select: { firstName: true, lastName: true, email: true } },
        studentCourses: {
          include: {
            student: { select: { id: true, firstName: true, lastName: true, email: true } },
          },
        },
      },
    });

    if (!course) throw new AppError('Курс не найден', 404);

    if (role === 'TEACHER' && course.teacherId !== userId) {
      throw new AppError('Нет доступа к этому курсу', 403);
    }

    if (role === 'STUDENT') {
      if (course.status !== 'PUBLISHED') {
        throw new AppError('Курс ещё не опубликован', 403);
      }

      const enrollment = await prisma.studentCourse.findFirst({
        where: { courseId, studentId: userId },
      });
      if (!enrollment) throw new AppError('Вы не записаны на этот курс', 403);
    }

    return course;
  }

  /**
   * Создать новый курс.
   *
   * @param {string} teacherId — ID авторизованного учителя (req.user.id)
   * @param {{ title, description?, status?: 'draft'|'published' }} data
   */
  async createCourse(teacherId, data = {}) {
    const { title, description, status } = data;

    if (!teacherId) {
      throw new AppError('Требуется авторизация учителя', 401);
    }

    if (!title || !String(title).trim()) {
      throw new AppError('Название курса обязательно', 400);
    }

    // Статус публикации: 'draft' | 'published' (без учёта регистра), по умолчанию draft
    let courseStatus = 'DRAFT';
    if (status !== undefined) {
      const normalized = String(status).trim().toUpperCase();
      if (!['DRAFT', 'PUBLISHED'].includes(normalized)) {
        throw new AppError("status должен быть 'draft' или 'published'", 400);
      }
      courseStatus = normalized;
    }

    return prisma.course.create({
      data: {
        title: String(title).trim(),
        description: description ?? null,
        teacherId,
        status: courseStatus,
        ...(courseStatus === 'PUBLISHED' ? { publishedAt: new Date() } : {}),
      },
    });
  }

  /** Обновить курс (только разрешённые поля) */
  async updateCourse(courseId, teacherId, data) {
    await this.assertOwnership(courseId, teacherId);

    const payload = pickEditable(data);
    if (payload.title !== undefined && !String(payload.title).trim()) {
      throw new AppError('Название курса не может быть пустым', 400);
    }

    return prisma.course.update({
      where: { id: courseId },
      data: payload,
    });
  }

  /** Опубликовать курс: draft → published */
  async publishCourse(courseId, teacherId) {
    await this.assertOwnership(courseId, teacherId);

    const tasksCount = await prisma.task.count({ where: { courseId } });
    if (tasksCount === 0) {
      throw new AppError('Нельзя опубликовать курс без заданий', 400);
    }

    const invalidTasks = await this.findInvalidTasks(courseId);
    if (invalidTasks.length > 0) {
      throw new AppError(
        `Задания с ошибками: ${invalidTasks.map((t) => `«${t.title}»`).join(', ')}`,
        400
      );
    }

    return prisma.course.update({
      where: { id: courseId },
      data: { status: 'PUBLISHED', publishedAt: new Date() },
    });
  }

  /** Снять курс с публикации */
  async unpublishCourse(courseId, teacherId) {
    await this.assertOwnership(courseId, teacherId);

    return prisma.course.update({
      where: { id: courseId },
      data: { status: 'DRAFT', publishedAt: null },
    });
  }

  /** Удалить курс */
  async deleteCourse(courseId, teacherId) {
    await this.assertOwnership(courseId, teacherId);

    await prisma.course.delete({ where: { id: courseId } });
    return { message: 'Курс удалён' };
  }

  /** Записать студента на курс */
  async enrollStudent(courseId, studentId, teacherId) {
    const course = await this.assertOwnership(courseId, teacherId);

    if (course.status !== 'PUBLISHED') {
      throw new AppError('Сначала опубликуйте курс', 400);
    }

    const relation = await prisma.teacherStudent.findFirst({
      where: { teacherId, studentId },
    });
    if (!relation) throw new AppError('Этот студент не привязан к вам', 400);

    const existing = await prisma.studentCourse.findFirst({
      where: { studentId, courseId },
    });
    if (existing) return existing;

    return prisma.studentCourse.create({
      data: { studentId, courseId },
    });
  }

  /** Отписать студента от курса */
  async unenrollStudent(courseId, studentId, teacherId) {
    await this.assertOwnership(courseId, teacherId);

    const enrollment = await prisma.studentCourse.findFirst({
      where: { courseId, studentId },
    });
    if (!enrollment) throw new AppError('Студент не записан на курс', 404);

    await prisma.studentCourse.delete({ where: { id: enrollment.id } });
    return { message: 'Студент отписан от курса' };
  }

  // ───────────────────────────────────────────────────────────
  // Ученик: доступные курсы и заявки на вступление
  // ───────────────────────────────────────────────────────────

  /**
   * Опубликованные курсы для ученика.
   * Для каждого курса отдаём статус записи и статус заявки,
   * но НЕ раскрываем задания до зачисления.
   */
  async getAvailableCourses(studentId) {
    const courses = await prisma.course.findMany({
      where: { status: 'PUBLISHED' },
      include: {
        teacher: { select: { id: true, firstName: true, lastName: true, email: true } },
        _count: { select: { tasks: true, studentCourses: true } },
        studentCourses: {
          where: { studentId },
          select: { id: true, progress: true, enrolledAt: true, completedAt: true },
        },
        joinRequests: {
          where: { studentId },
          select: { id: true, status: true, message: true, createdAt: true, reviewedAt: true },
        },
      },
      orderBy: { publishedAt: 'desc' },
    });

    return courses.map(({ studentCourses, joinRequests, ...course }) => ({
      ...course,
      isEnrolled: studentCourses.length > 0,
      enrollment: studentCourses[0] || null,
      joinRequest: joinRequests[0] || null,
    }));
  }

  /** Ученик отправляет заявку на вступление в курс */
  async requestJoin(courseId, studentId, message) {
    const course = await prisma.course.findUnique({ where: { id: courseId } });
    if (!course) throw new AppError('Курс не найден', 404);
    if (course.status !== 'PUBLISHED') {
      throw new AppError('Курс ещё не опубликован', 400);
    }

    const enrollment = await prisma.studentCourse.findFirst({
      where: { courseId, studentId },
    });
    if (enrollment) throw new AppError('Вы уже записаны на этот курс', 400);

    const text = message != null && String(message).trim()
      ? String(message).trim().slice(0, 500)
      : null;

    const existing = await prisma.courseJoinRequest.findUnique({
      where: { courseId_studentId: { courseId, studentId } },
    });

    if (existing) {
      if (existing.status === 'PENDING') {
        throw new AppError('Заявка уже отправлена и ожидает рассмотрения', 400);
      }
      // Повторная заявка после отказа
      return prisma.courseJoinRequest.update({
        where: { id: existing.id },
        data: { status: 'PENDING', message: text, reviewedAt: null },
      });
    }

    return prisma.courseJoinRequest.create({
      data: { courseId, studentId, message: text },
    });
  }

  /** Ученик отменяет свою ожидающую заявку */
  async cancelJoin(courseId, studentId) {
    const request = await prisma.courseJoinRequest.findUnique({
      where: { courseId_studentId: { courseId, studentId } },
    });
    if (!request) throw new AppError('Заявка не найдена', 404);
    if (request.status !== 'PENDING') {
      throw new AppError('Можно отменить только заявку в ожидании', 400);
    }

    await prisma.courseJoinRequest.delete({ where: { id: request.id } });
    return { message: 'Заявка отменена' };
  }

  /** Ученик: все мои заявки */
  async getMyJoinRequests(studentId) {
    return prisma.courseJoinRequest.findMany({
      where: { studentId },
      include: {
        course: {
          select: {
            id: true,
            title: true,
            status: true,
            teacher: { select: { firstName: true, lastName: true } },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  // ───────────────────────────────────────────────────────────
  // Учитель: заявки и студенты курса
  // ───────────────────────────────────────────────────────────

  /** Учитель: заявки на его курсы (по умолчанию все) */
  async getTeacherJoinRequests(teacherId, status) {
    const where = { course: { teacherId } };

    if (status) {
      const normalized = String(status).trim().toUpperCase();
      if (!['PENDING', 'APPROVED', 'REJECTED'].includes(normalized)) {
        throw new AppError('Некорректный статус заявки', 400);
      }
      where.status = normalized;
    }

    return prisma.courseJoinRequest.findMany({
      where,
      include: {
        course: { select: { id: true, title: true, status: true } },
        student: {
          select: { id: true, email: true, firstName: true, lastName: true, avatarUrl: true },
        },
      },
      orderBy: [{ status: 'asc' }, { createdAt: 'desc' }],
    });
  }

  /**
   * Учитель одобряет или отклоняет заявку.
   * Одобрение = запись на курс + привязка студента к учителю.
   */
  async reviewJoinRequest(requestId, teacherId, decision) {
    const request = await prisma.courseJoinRequest.findUnique({
      where: { id: requestId },
      include: { course: true },
    });
    if (!request) throw new AppError('Заявка не найдена', 404);
    if (request.course.teacherId !== teacherId) throw new AppError('Нет доступа', 403);

    const action = String(decision || '').trim().toLowerCase();
    if (!['approve', 'approved', 'reject', 'rejected'].includes(action)) {
      throw new AppError('decision должен быть approve или reject', 400);
    }

    if (action.startsWith('reject')) {
      const updated = await prisma.courseJoinRequest.update({
        where: { id: requestId },
        data: { status: 'REJECTED', reviewedAt: new Date() },
      });
      return { request: updated };
    }

    await prisma.$transaction(async (tx) => {
      const enrollment = await tx.studentCourse.findFirst({
        where: { courseId: request.courseId, studentId: request.studentId },
      });
      if (!enrollment) {
        await tx.studentCourse.create({
          data: { courseId: request.courseId, studentId: request.studentId },
        });
      }

      const relation = await tx.teacherStudent.findFirst({
        where: { teacherId, studentId: request.studentId },
      });
      if (!relation) {
        await tx.teacherStudent.create({
          data: { teacherId, studentId: request.studentId },
        });
      }

      await tx.courseJoinRequest.update({
        where: { id: requestId },
        data: { status: 'APPROVED', reviewedAt: new Date() },
      });
    });

    const updated = await prisma.courseJoinRequest.findUnique({
      where: { id: requestId },
      include: {
        course: { select: { id: true, title: true } },
        student: { select: { id: true, email: true, firstName: true, lastName: true } },
      },
    });

    return { request: updated };
  }

  /** Учитель: студенты курса + кандидаты на добавление */
  async getCourseStudents(courseId, teacherId) {
    await this.assertOwnership(courseId, teacherId);

    const [enrollments, allStudents] = await Promise.all([
      prisma.studentCourse.findMany({
        where: { courseId },
        include: {
          student: {
            select: { id: true, email: true, firstName: true, lastName: true, avatarUrl: true },
          },
        },
        orderBy: { enrolledAt: 'asc' },
      }),
      prisma.user.findMany({
        where: { role: 'STUDENT' },
        select: { id: true, email: true, firstName: true, lastName: true },
        orderBy: [{ firstName: 'asc' }, { lastName: 'asc' }],
      }),
    ]);

    const enrolledIds = new Set(enrollments.map((item) => item.studentId));

    return {
      students: enrollments.map((item) => ({
        ...item.student,
        enrollmentId: item.id,
        progress: item.progress,
        enrolledAt: item.enrolledAt,
        completedAt: item.completedAt,
      })),
      availableStudents: allStudents.filter((student) => !enrolledIds.has(student.id)),
    };
  }

  /**
   * Учитель добавляет студента в свой курс.
   * Если студент ещё не привязан к учителю — привязка создаётся.
   */
  async addStudentToCourse(courseId, teacherId, { studentId, email } = {}) {
    await this.assertOwnership(courseId, teacherId);

    let student = null;
    if (studentId) {
      student = await prisma.user.findUnique({ where: { id: studentId } });
    } else if (email) {
      student = await prisma.user.findUnique({ where: { email: String(email).trim() } });
    } else {
      throw new AppError('Укажите studentId или email студента', 400);
    }

    if (!student) throw new AppError('Студент не найден', 404);
    if (student.role !== 'STUDENT') {
      throw new AppError('Этот пользователь не является студентом', 400);
    }

    const relation = await prisma.teacherStudent.findFirst({
      where: { teacherId, studentId: student.id },
    });
    if (!relation) {
      await prisma.teacherStudent.create({ data: { teacherId, studentId: student.id } });
    }

    const existing = await prisma.studentCourse.findFirst({
      where: { courseId, studentId: student.id },
    });

    const enrollment = existing || await prisma.studentCourse.create({
      data: { courseId, studentId: student.id },
    });

    return {
      enrollment,
      student: {
        id: student.id,
        email: student.email,
        firstName: student.firstName,
        lastName: student.lastName,
      },
    };
  }

  /** Проверка владельца курса */
  async assertOwnership(courseId, teacherId) {
    const course = await prisma.course.findUnique({ where: { id: courseId } });
    if (!course) throw new AppError('Курс не найден', 404);
    if (course.teacherId !== teacherId) throw new AppError('Нет доступа', 403);
    return course;
  }

  /** Задания, которые нельзя публиковать (не заполнены обязательные поля) */
  async findInvalidTasks(courseId) {
    const tasks = await prisma.task.findMany({ where: { courseId } });

    return tasks.filter((task) => {
      if (task.type === 'EAR_TRAINING') {
        const options = Array.isArray(task.answerOptions) ? task.answerOptions : [];
        return !task.correctAnswer || options.length < 2;
      }
      if (task.type === 'FINGERING_TEST') {
        const options = Array.isArray(task.answerOptions) ? task.answerOptions : [];
        const correct = task.correctAnswer || task.expectedNote;
        return !correct || options.length < 2 || !options.includes(correct);
      }
      if (
        task.type === 'PLAY_PRACTICE' ||
        task.type === 'PLAY_FINGERING' ||
        task.type === 'COMBO_FINGERING'
      ) {
        return !task.expectedNote;
      }
      return true;
    });
  }
}

module.exports = new CoursesService();
