const { prisma } = require('../src/config/database');
const { AppError } = require('../src/middleware/errorHandler');

async function assertTeacherCourseOwner(courseId, teacherId) {
  const course = await prisma.course.findUnique({
    where: { id: courseId },
    select: { id: true, teacherId: true, title: true, isPublished: true, status: true },
  });

  if (!course) {
    throw new AppError('Курс не найден', 404);
  }

  if (course.teacherId !== teacherId) {
    throw new AppError('Доступ запрещен: вы не являетесь автором этого курса', 403);
  }

  return course;
}

class CourseEnrollmentController {

  async getCatalog(req, res, next) {
    try {
      const studentId = req.user?.id;

      const courses = await prisma.course.findMany({
        where: {
          OR: [
            { isPublished: true },
            { status: 'PUBLISHED' },
          ],
        },
        include: {
          teacher: {
            select: {
              id: true,
              email: true,
              name: true,
              firstName: true,
              lastName: true,
              avatarUrl: true,
            },
          },
          _count: {
            select: {
              tasks: true,
              enrollments: true,
            },
          },
          enrollments: studentId ? {
            where: { studentId },
            select: {
              id: true,
              status: true,
              enrolledAt: true,
            },
          } : false,
          studentCourses: studentId ? {
            where: { studentId },
            select: {
              id: true,
              progress: true,
            },
          } : false,
        },
        orderBy: { createdAt: 'desc' },
      });

      const catalog = courses.map((course) => {
        let enrollmentStatus = 'NONE';
        let enrollmentId = null;

        if (course.enrollments && course.enrollments.length > 0) {
          enrollmentStatus = course.enrollments[0].status;
          enrollmentId = course.enrollments[0].id;
        } else if (course.studentCourses && course.studentCourses.length > 0) {
          enrollmentStatus = 'APPROVED';
        }

        const teacherDisplayName =
          course.teacher?.name ||
          [course.teacher?.firstName, course.teacher?.lastName].filter(Boolean).join(' ') ||
          course.teacher?.email ||
          'Преподаватель';

        return {
          id: course.id,
          title: course.title,
          description: course.description,
          isPublished: course.isPublished || course.status === 'PUBLISHED',
          createdAt: course.createdAt,
          taskCount: course._count?.tasks ?? 0,
          studentsCount: course._count?.enrollments ?? 0,
          teacher: {
            ...course.teacher,
            displayName: teacherDisplayName,
          },
          enrollmentStatus,
          enrollmentId,
        };
      });

      res.json({ courses: catalog });
    } catch (error) {
      next(error);
    }
  }

  async enroll(req, res, next) {
    try {
      const courseId = req.params.id;
      const studentId = req.user.id;

      const course = await prisma.course.findUnique({
        where: { id: courseId },
      });

      if (!course) {
        throw new AppError('Курс не найден', 404);
      }

      const isPublished = course.isPublished || course.status === 'PUBLISHED';
      if (!isPublished) {
        throw new AppError('Курс еще не опубликован для записи', 400);
      }

      const existingEnrollment = await prisma.courseEnrollment.findUnique({
        where: {
          courseId_studentId: {
            courseId,
            studentId,
          },
        },
      });

      if (existingEnrollment) {
        if (existingEnrollment.status === 'APPROVED') {
          return res.status(400).json({
            error: 'Вы уже зачислены на этот курс',
            status: 'APPROVED',
          });
        }
        if (existingEnrollment.status === 'PENDING') {
          return res.status(400).json({
            error: 'Заявка уже отправлена и находится на рассмотрении',
            status: 'PENDING',
          });
        }
        const updated = await prisma.courseEnrollment.update({
          where: { id: existingEnrollment.id },
          data: { status: 'PENDING', enrolledAt: new Date() },
        });

        return res.status(200).json({
          message: 'Заявка повторно отправлена преподавателю',
          enrollment: updated,
        });
      }

      const enrollment = await prisma.courseEnrollment.create({
        data: {
          courseId,
          studentId,
          status: 'PENDING',
        },
      });

      try {
        await prisma.courseJoinRequest.upsert({
          where: { courseId_studentId: { courseId, studentId } },
          create: { courseId, studentId, status: 'PENDING' },
          update: { status: 'PENDING' },
        });
      } catch {
      }

      res.status(201).json({
        message: 'Заявка на вступление успешно создана',
        enrollment,
      });
    } catch (error) {
      next(error);
    }
  }

  async getMyCourses(req, res, next) {
    try {
      const studentId = req.user.id;

      const enrollments = await prisma.courseEnrollment.findMany({
        where: {
          studentId,
          status: 'APPROVED',
        },
        include: {
          course: {
            include: {
              teacher: {
                select: {
                  id: true,
                  name: true,
                  firstName: true,
                  lastName: true,
                  email: true,
                },
              },
              tasks: {
                orderBy: { orderIndex: 'asc' },
              },
              _count: {
                select: { tasks: true },
              },
            },
          },
        },
        orderBy: { enrolledAt: 'desc' },
      });

      let courses = enrollments.map((enr) => {
        const c = enr.course;
        const teacherDisplayName =
          c.teacher?.name ||
          [c.teacher?.firstName, c.teacher?.lastName].filter(Boolean).join(' ') ||
          c.teacher?.email ||
          'Преподаватель';

        return {
          id: c.id,
          title: c.title,
          description: c.description,
          isPublished: c.isPublished || c.status === 'PUBLISHED',
          enrolledAt: enr.enrolledAt,
          enrollmentId: enr.id,
          tasksCount: c._count?.tasks ?? c.tasks?.length ?? 0,
          tasks: c.tasks,
          teacher: {
            ...c.teacher,
            displayName: teacherDisplayName,
          },
        };
      });

      if (courses.length === 0) {
        const legacyCourses = await prisma.studentCourse.findMany({
          where: { studentId },
          include: {
            course: {
              include: {
                teacher: {
                  select: { id: true, name: true, firstName: true, lastName: true, email: true },
                },
                tasks: { orderBy: { orderIndex: 'asc' } },
                _count: { select: { tasks: true } },
              },
            },
          },
        });

        courses = legacyCourses.map((item) => ({
          id: item.course.id,
          title: item.course.title,
          description: item.course.description,
          isPublished: item.course.isPublished || item.course.status === 'PUBLISHED',
          enrolledAt: item.enrolledAt,
          enrollmentId: item.id,
          progress: item.progress,
          tasksCount: item.course._count?.tasks ?? item.course.tasks?.length ?? 0,
          tasks: item.course.tasks,
          teacher: {
            ...item.course.teacher,
            displayName: [item.course.teacher?.firstName, item.course.teacher?.lastName].filter(Boolean).join(' ') || item.course.teacher?.email,
          },
        }));
      }

      res.json({ courses });
    } catch (error) {
      next(error);
    }
  }

  async getCourseTasks(req, res, next) {
    try {
      const courseId = req.params.id;
      const user = req.user;
      const role = String(user?.role || '').toUpperCase();

      const course = await prisma.course.findUnique({
        where: { id: courseId },
        include: {
          tasks: {
            orderBy: { orderIndex: 'asc' },
          },
          teacher: {
            select: { id: true, name: true, firstName: true, lastName: true, email: true },
          },
        },
      });

      if (!course) {
        throw new AppError('Курс не найден', 404);
      }

      if (role === 'TEACHER') {
        if (course.teacherId !== user.id) {
          throw new AppError('Доступ запрещен: вы не являетесь преподавателем этого курса', 403);
        }
      } else {
        const approvedEnrollment = await prisma.courseEnrollment.findFirst({
          where: {
            courseId,
            studentId: user.id,
            status: 'APPROVED',
          },
        });

        const legacyApproved = approvedEnrollment
          ? true
          : await prisma.studentCourse.findFirst({
              where: { courseId, studentId: user.id },
            });

        if (!approvedEnrollment && !legacyApproved) {
          throw new AppError('Доступ к заданиям закрыт: вы не зачислены на этот курс', 403);
        }
      }

      res.json({
        course: {
          id: course.id,
          title: course.title,
          description: course.description,
          teacher: course.teacher,
        },
        tasks: course.tasks,
      });
    } catch (error) {
      next(error);
    }
  }

  async submitTaskResult(req, res, next) {
    try {
      const taskId = req.params.id;
      const studentId = req.user.id;
      const { isCorrect, answer, reactionMs } = req.body;

      const task = await prisma.task.findUnique({
        where: { id: taskId },
        include: { course: true },
      });

      if (!task) {
        throw new AppError('Задание не найдено', 404);
      }

      const verifiedCorrect = Boolean(isCorrect);
      const status = verifiedCorrect ? 'CORRECT' : 'INCORRECT';

      const taskResult = await prisma.taskResult.create({
        data: {
          taskId,
          studentId,
          isCorrect: verifiedCorrect,
          status,
          answer: answer !== undefined ? String(answer) : null,
          reactionMs: Number(reactionMs) || null,
          completedAt: new Date(),
        },
      });

      try {
        const totalTasks = await prisma.task.count({ where: { courseId: task.courseId } });
        if (totalTasks > 0) {
          const completedTasks = await prisma.taskResult.groupBy({
            by: ['taskId'],
            where: {
              studentId,
              isCorrect: true,
              task: { courseId: task.courseId },
            },
          });
          const progress = Math.min(100, Math.round((completedTasks.length / totalTasks) * 100));

          await prisma.studentCourse.updateMany({
            where: { courseId: task.courseId, studentId },
            data: {
              progress,
              ...(progress === 100 ? { completedAt: new Date() } : {}),
            },
          });
        }
      } catch {
      }

      res.status(201).json({
        success: true,
        taskResult,
      });
    } catch (error) {
      next(error);
    }
  }

  async createCourse(req, res, next) {
    try {
      const teacherId = req.user.id;
      const { title, description, isPublished } = req.body;

      if (!title || !String(title).trim()) {
        throw new AppError('Название курса обязательно', 400);
      }

      const published = Boolean(isPublished);

      const course = await prisma.course.create({
        data: {
          title: String(title).trim(),
          description: description ? String(description).trim() : null,
          teacherId,
          isPublished: published,
          status: published ? 'PUBLISHED' : 'DRAFT',
          publishedAt: published ? new Date() : null,
        },
      });

      res.status(201).json({
        success: true,
        course,
      });
    } catch (error) {
      next(error);
    }
  }

  async getCourseEnrollments(req, res, next) {
    try {
      const courseId = req.params.id;
      const teacherId = req.user.id;

      await assertTeacherCourseOwner(courseId, teacherId);

      const enrollments = await prisma.courseEnrollment.findMany({
        where: { courseId },
        include: {
          student: {
            select: {
              id: true,
              email: true,
              name: true,
              firstName: true,
              lastName: true,
              avatarUrl: true,
            },
          },
        },
        orderBy: [
          { status: 'asc' },
          { enrolledAt: 'desc' },
        ],
      });

      const formatted = enrollments.map((enr) => {
        const studentDisplayName =
          enr.student?.name ||
          [enr.student?.firstName, enr.student?.lastName].filter(Boolean).join(' ') ||
          enr.student?.email;

        return {
          id: enr.id,
          courseId: enr.courseId,
          studentId: enr.studentId,
          status: enr.status,
          enrolledAt: enr.enrolledAt,
          student: {
            ...enr.student,
            displayName: studentDisplayName,
          },
        };
      });

      res.json({ enrollments: formatted });
    } catch (error) {
      next(error);
    }
  }

  async updateEnrollmentStatus(req, res, next) {
    try {
      const { id: courseId, enrollmentId } = req.params;
      const teacherId = req.user.id;
      const { status, decision } = req.body;

      await assertTeacherCourseOwner(courseId, teacherId);

      let targetStatus = null;
      if (status) {
        const upper = String(status).trim().toUpperCase();
        if (['APPROVED', 'REJECTED', 'PENDING'].includes(upper)) {
          targetStatus = upper;
        }
      } else if (decision) {
        const d = String(decision).trim().toLowerCase();
        if (d === 'approve' || d === 'approved') targetStatus = 'APPROVED';
        if (d === 'reject' || d === 'rejected') targetStatus = 'REJECTED';
      }

      if (!targetStatus) {
        throw new AppError("Некорректный статус. Ожидается 'APPROVED' или 'REJECTED'", 400);
      }

      const enrollment = await prisma.courseEnrollment.findUnique({
        where: { id: enrollmentId },
      });

      if (!enrollment || enrollment.courseId !== courseId) {
        throw new AppError('Заявка на курс не найдена', 404);
      }

      const updatedEnrollment = await prisma.$transaction(async (tx) => {
        const updated = await tx.courseEnrollment.update({
          where: { id: enrollmentId },
          data: { status: targetStatus },
          include: {
            student: {
              select: { id: true, email: true, name: true, firstName: true, lastName: true },
            },
          },
        });

        if (targetStatus === 'APPROVED') {
          const rel = await tx.teacherStudent.findFirst({
            where: { teacherId, studentId: enrollment.studentId },
          });
          if (!rel) {
            await tx.teacherStudent.create({
              data: { teacherId, studentId: enrollment.studentId },
            });
          }

          const sc = await tx.studentCourse.findFirst({
            where: { courseId, studentId: enrollment.studentId },
          });
          if (!sc) {
            await tx.studentCourse.create({
              data: { courseId, studentId: enrollment.studentId },
            });
          }
        } else if (targetStatus === 'REJECTED') {
          await tx.studentCourse.deleteMany({
            where: { courseId, studentId: enrollment.studentId },
          });
        }

        return updated;
      });

      res.json({
        success: true,
        enrollment: updatedEnrollment,
      });
    } catch (error) {
      next(error);
    }
  }

  async addStudent(req, res, next) {
    try {
      const courseId = req.params.id;
      const teacherId = req.user.id;
      const { email, studentId } = req.body;

      await assertTeacherCourseOwner(courseId, teacherId);

      let targetStudent = null;
      if (email && String(email).trim()) {
        targetStudent = await prisma.user.findUnique({
          where: { email: String(email).trim().toLowerCase() },
        });
      } else if (studentId) {
        targetStudent = await prisma.user.findUnique({
          where: { id: studentId },
        });
      } else {
        throw new AppError('Укажите email студента', 400);
      }

      if (!targetStudent) {
        throw new AppError('Пользователь с указанным email не найден', 404);
      }

      if (String(targetStudent.role).toUpperCase() !== 'STUDENT') {
        throw new AppError('Указанный пользователь не имеет роли студента', 400);
      }

      const enrollment = await prisma.$transaction(async (tx) => {
        const relation = await tx.teacherStudent.findFirst({
          where: { teacherId, studentId: targetStudent.id },
        });
        if (!relation) {
          await tx.teacherStudent.create({
            data: { teacherId, studentId: targetStudent.id },
          });
        }

        const enr = await tx.courseEnrollment.upsert({
          where: {
            courseId_studentId: {
              courseId,
              studentId: targetStudent.id,
            },
          },
          create: {
            courseId,
            studentId: targetStudent.id,
            status: 'APPROVED',
          },
          update: {
            status: 'APPROVED',
          },
          include: {
            student: {
              select: { id: true, email: true, name: true, firstName: true, lastName: true },
            },
          },
        });

        const sc = await tx.studentCourse.findFirst({
          where: { courseId, studentId: targetStudent.id },
        });
        if (!sc) {
          await tx.studentCourse.create({
            data: { courseId, studentId: targetStudent.id },
          });
        }

        return enr;
      });

      res.status(201).json({
        success: true,
        message: 'Студент успешно зачислен на курс',
        enrollment,
        student: {
          id: targetStudent.id,
          email: targetStudent.email,
          name: targetStudent.name || `${targetStudent.firstName || ''} ${targetStudent.lastName || ''}`.trim(),
        },
      });
    } catch (error) {
      next(error);
    }
  }

  async removeStudent(req, res, next) {
    try {
      const { id: courseId, studentId } = req.params;
      const teacherId = req.user.id;

      await assertTeacherCourseOwner(courseId, teacherId);

      await prisma.$transaction(async (tx) => {
        await tx.courseEnrollment.deleteMany({
          where: { courseId, studentId },
        });

        await tx.studentCourse.deleteMany({
          where: { courseId, studentId },
        });

        await tx.courseJoinRequest.deleteMany({
          where: { courseId, studentId },
        });
      });

      res.json({
        success: true,
        message: 'Студент успешно исключен из курса',
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new CourseEnrollmentController();
