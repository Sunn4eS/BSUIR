/**
 * modules/users/users.service.js — бизнес-логика для пользователей
 * Управление студентами учителя, профили, привязки
 */

const { prisma }   = require('../../config/database');
const { AppError } = require('../../middleware/errorHandler');

class UsersService {
  /**
   * Получить список студентов данного учителя
   * @param {string} teacherId
   */
  async getMyStudents(teacherId) {
    const relations = await prisma.teacherStudent.findMany({
      where: { teacherId },
      include: {
        student: {
          select: {
            id: true,
            email: true,
            firstName: true,
            lastName: true,
            avatarUrl: true,
            createdAt: true,
            // Реальные записи на курс живут в student_courses (StudentCourse).
            // Legacy-связь enrollments (CourseEnrollment) не содержит прогресса.
            studentCourses: {
              select: {
                courseId: true,
                progress: true,
                enrolledAt: true,
                course: { select: { title: true } },
              },
            },
          },
        },
      },
    });

    // Сохраняем прежнюю форму ответа: фронтенд читает student.enrollments.
    return relations.map((r) => {
      const { studentCourses, ...student } = r.student;
      return { ...student, enrollments: studentCourses };
    });
  }

  /**
   * Привязать студента к учителю по email
   * @param {string} teacherId
   * @param {string} studentEmail
   */
  async addStudent(teacherId, studentEmail) {
    // Ищем студента по email
    const student = await prisma.user.findUnique({
      where: { email: studentEmail },
    });

    if (!student) {
      throw new AppError('Пользователь с таким email не найден', 404);
    }

    if (student.role !== 'STUDENT') {
      throw new AppError('Этот пользователь не является студентом', 400);
    }

    if (student.id === teacherId) {
      throw new AppError('Вы не можете добавить себя', 400);
    }

    // Создаём связь (если уже есть — вернём ошибку Prisma P2002, которая обрабатывается в errorHandler)
    const relation = await prisma.teacherStudent.create({
      data: { teacherId, studentId: student.id },
    });

    return { relation, student: { id: student.id, email: student.email, firstName: student.firstName, lastName: student.lastName } };
  }

  /**
   * Отвязать студента от учителя
   * @param {string} teacherId
   * @param {string} studentId
   */
  async removeStudent(teacherId, studentId) {
    const relation = await prisma.teacherStudent.findFirst({
      where: { teacherId, studentId },
    });

    if (!relation) {
      throw new AppError('Студент не привязан к вам', 404);
    }

    await prisma.teacherStudent.delete({ where: { id: relation.id } });

    return { message: 'Студент успешно отвязан' };
  }

  /**
   * Получить дашборд студента: курсы, прогресс, задания
   * @param {string} studentId
   */
  async getStudentDashboard(studentId) {
    const enrollments = await prisma.studentCourse.findMany({
      where: {
        studentId,
        // Ученик видит только опубликованные курсы
        course: { status: 'PUBLISHED' },
      },
      include: {
        course: {
          include: {
            tasks: { orderBy: { orderIndex: 'asc' } },
            teacher: { select: { firstName: true, lastName: true, email: true } },
          },
        },
      },
      orderBy: { enrolledAt: 'desc' },
    });

    // Статистика: общее кол-во заданий, выполненных, в процессе
    const taskResults = await prisma.taskResult.groupBy({
      by: ['status'],
      where: { studentId },
      _count: true,
    });

    return { enrollments, taskResults };
  }
}

module.exports = new UsersService();
