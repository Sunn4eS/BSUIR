/**
 * modules/tasks/tasks.service.js — CRUD заданий + результаты
 */

const { prisma } = require('../../config/database');
const { AppError } = require('../../middleware/errorHandler');

const EDITABLE_FIELDS = [
  'title',
  'instruction',
  'audioContent',
  'answerOptions',
  'expectedNote',
  'toleranceCents',
  'correctAnswer',
  'fingeringMode',
  'orderIndex',
  'isTemplate',
];

const VALID_TASK_TYPES = [
  'EAR_TRAINING',
  'PLAY_PRACTICE',
  'FINGERING_TEST',
  'PLAY_FINGERING',
  'COMBO_FINGERING',
];
const VALID_FINGERING_MODES = ['BUILD', 'GUESS'];

function pickEditable(data = {}) {
  return EDITABLE_FIELDS.reduce((acc, field) => {
    if (data[field] !== undefined) acc[field] = data[field];
    return acc;
  }, {});
}

/** Нормализует варианты ответа в массив строк */
function normalizeOptions(value) {
  if (Array.isArray(value)) return value.map((item) => String(item).trim()).filter(Boolean);
  if (typeof value === 'string') {
    return value
      .split(',')
      .map((item) => item.trim())
      .filter(Boolean);
  }
  return [];
}

/** Проверяет обязательные поля задания */
function validateTask(type, payload) {
  if (!type || !VALID_TASK_TYPES.includes(type)) {
    throw new AppError('Некорректный тип задания', 400);
  }

  if (!payload.title || !String(payload.title).trim()) {
    throw new AppError('Название задания обязательно', 400);
  }

  if (type === 'EAR_TRAINING') {
    const options = normalizeOptions(payload.answerOptions);
    if (options.length < 2) {
      throw new AppError('Для тренировки слуха нужно минимум 2 варианта ответа', 400);
    }
    if (!payload.correctAnswer) {
      throw new AppError('Укажите правильный ответ', 400);
    }
    if (!options.includes(String(payload.correctAnswer))) {
      throw new AppError('Правильный ответ должен быть одним из вариантов', 400);
    }
  }

  if (type === 'FINGERING_TEST') {
    const options = normalizeOptions(payload.answerOptions);
    if (options.length < 2) {
      throw new AppError('Для карточки аппликатуры нужно минимум 2 варианта ответа', 400);
    }
    const correctAnswer = payload.correctAnswer || payload.expectedNote;
    if (!correctAnswer) {
      throw new AppError('Укажите аккорд — правильный ответ', 400);
    }
    if (!options.includes(String(correctAnswer))) {
      throw new AppError('Правильный аккорд должен быть одним из вариантов', 400);
    }
    if (payload.fingeringMode && !VALID_FINGERING_MODES.includes(payload.fingeringMode)) {
      throw new AppError('Режим аппликатуры: BUILD или GUESS', 400);
    }
  }

  if (type === 'PLAY_PRACTICE' && !payload.expectedNote) {
    throw new AppError('Укажите ноту или аккорд для практики', 400);
  }

  if ((type === 'PLAY_FINGERING' || type === 'COMBO_FINGERING') && !payload.expectedNote) {
    throw new AppError('Укажите аккорд для аппликатуры', 400);
  }
}

class TasksService {
  /** Создать задание в курсе */
  async createTask(courseId, teacherId, data = {}) {
    const course = await prisma.course.findUnique({ where: { id: courseId } });
    if (!course) throw new AppError('Курс не найден', 404);
    if (course.teacherId !== teacherId) throw new AppError('Нет доступа', 403);

    const payload = pickEditable(data);
    payload.title = payload.title?.trim();
    payload.answerOptions = normalizeOptions(data.answerOptions);
    payload.toleranceCents = Number.isFinite(Number(data.toleranceCents))
      ? Number(data.toleranceCents)
      : 20;

    // Режим аппликатуры актуален только для FINGERING_TEST
    payload.fingeringMode =
      data.type === 'FINGERING_TEST' && VALID_FINGERING_MODES.includes(data.fingeringMode)
        ? data.fingeringMode
        : data.type === 'FINGERING_TEST'
          ? 'GUESS'
          : null;

    validateTask(data.type, payload);

    const lastTask = await prisma.task.findFirst({
      where: { courseId },
      orderBy: { orderIndex: 'desc' },
      select: { orderIndex: true },
    });

    return prisma.task.create({
      data: {
        courseId,
        type: data.type,
        ...payload,
        orderIndex: Number.isFinite(Number(data.orderIndex))
          ? Number(data.orderIndex)
          : (lastTask?.orderIndex ?? 0) + 1,
        isTemplate: Boolean(data.isTemplate),
      },
    });
  }

  /** Обновить задание */
  async updateTask(taskId, teacherId, data = {}) {
    const task = await prisma.task.findUnique({
      where: { id: taskId },
      include: { course: true },
    });
    if (!task) throw new AppError('Задание не найдено', 404);
    if (task.course.teacherId !== teacherId) throw new AppError('Нет доступа', 403);

    const payload = pickEditable(data);
    if (data.answerOptions !== undefined) {
      payload.answerOptions = normalizeOptions(data.answerOptions);
    }
    if (data.toleranceCents !== undefined) {
      payload.toleranceCents = Number(data.toleranceCents) || 20;
    }
    if (data.fingeringMode !== undefined) {
      payload.fingeringMode = VALID_FINGERING_MODES.includes(data.fingeringMode)
        ? data.fingeringMode
        : null;
    }

    const merged = { ...task, ...payload };
    validateTask(merged.type, merged);

    return prisma.task.update({ where: { id: taskId }, data: payload });
  }

  /** Удалить задание */
  async deleteTask(taskId, teacherId) {
    const task = await prisma.task.findUnique({
      where: { id: taskId },
      include: { course: true },
    });
    if (!task) throw new AppError('Задание не найдено', 404);
    if (task.course.teacherId !== teacherId) throw new AppError('Нет доступа', 403);

    await prisma.task.delete({ where: { id: taskId } });
    return { message: 'Задание удалено' };
  }

  /** Получить все шаблонные задания учителя */
  async getTemplates(teacherId) {
    return prisma.task.findMany({
      where: {
        isTemplate: true,
        course: { teacherId },
      },
      include: { course: { select: { id: true, title: true, status: true } } },
      orderBy: { createdAt: 'desc' },
    });
  }

  /**
   * Сохранить результат выполнения задания студентом
   */
  async submitTaskResult(studentId, taskId, { status, answer, reactionMs, liveSessionId }) {
    const task = await prisma.task.findUnique({
      where: { id: taskId },
      include: { course: true },
    });
    if (!task) throw new AppError('Задание не найдено', 404);
    if (task.course.status !== 'PUBLISHED') {
      throw new AppError('Курс ещё не опубликован', 403);
    }

    const enrollment = await prisma.studentCourse.findFirst({
      where: { studentId, courseId: task.courseId },
    });
    if (!enrollment) throw new AppError('Вы не записаны на этот курс', 403);

    const existing = await prisma.taskResult.findFirst({
      where: { studentId, taskId, liveSessionId: liveSessionId ?? null },
    });

    let result;
    if (existing) {
      result = await prisma.taskResult.update({
        where: { id: existing.id },
        data: {
          status,
          answer,
          reactionMs,
          attempts: { increment: 1 },
        },
      });
    } else {
      result = await prisma.taskResult.create({
        data: {
          studentId,
          taskId,
          status: status || 'IN_PROGRESS',
          answer,
          reactionMs,
          liveSessionId,
          attempts: 1,
        },
      });
    }

    await this.updateCourseProgress(studentId, task.courseId);
    return result;
  }

  /** Пересчитать прогресс ученика по курсу (процент верных заданий) */
  async updateCourseProgress(studentId, courseId) {
    const [total, correct] = await Promise.all([
      prisma.task.count({ where: { courseId } }),
      prisma.taskResult.count({
        where: { studentId, status: 'CORRECT', task: { courseId } },
      }),
    ]);

    if (total === 0) return;

    const progress = Math.min(100, Math.round((correct / total) * 100));

    await prisma.studentCourse.updateMany({
      where: { studentId, courseId },
      data: {
        progress,
        ...(progress >= 100 ? { completedAt: new Date() } : {}),
      },
    });
  }

  /** Получить результаты студента по курсу */
  async getStudentResults(studentId, courseId) {
    return prisma.taskResult.findMany({
      where: {
        studentId,
        task: { courseId },
      },
      include: {
        task: { select: { title: true, type: true, orderIndex: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }
}

module.exports = new TasksService();
