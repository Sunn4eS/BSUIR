const { prisma }   = require('../../config/database');
const { AppError } = require('../../middleware/errorHandler');

class UsersService {
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

    return relations.map((r) => {
      const { studentCourses, ...student } = r.student;
      return { ...student, enrollments: studentCourses };
    });
  }

  async addStudent(teacherId, studentEmail) {
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

    const relation = await prisma.teacherStudent.create({
      data: { teacherId, studentId: student.id },
    });

    return { relation, student: { id: student.id, email: student.email, firstName: student.firstName, lastName: student.lastName } };
  }

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

  async getStudentDashboard(studentId) {
    const enrollments = await prisma.studentCourse.findMany({
      where: {
        studentId,
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

    const taskResults = await prisma.taskResult.groupBy({
      by: ['status'],
      where: { studentId },
      _count: true,
    });

    return { enrollments, taskResults };
  }
}

module.exports = new UsersService();
