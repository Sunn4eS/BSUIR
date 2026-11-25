const { PrismaClient, Role, TaskType, TaskResultStatus, CourseStatus } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Начинаем заполнение БД тестовыми данными...');

  await prisma.liveTaskCard.deleteMany();
  await prisma.liveSession.deleteMany();
  await prisma.taskResult.deleteMany();
  await prisma.studentCourse.deleteMany();
  await prisma.task.deleteMany();
  await prisma.course.deleteMany();
  await prisma.teacherStudent.deleteMany();
  await prisma.user.deleteMany();

  const passwordHash = await bcrypt.hash('password123', 10);

  const teacher = await prisma.user.create({
    data: {
      email: 'teacher@guitar.app',
      passwordHash,
      firstName: 'Алексей',
      lastName: 'Иванов',
      role: Role.TEACHER,
    },
  });

  const student1 = await prisma.user.create({
    data: {
      email: 'student1@guitar.app',
      passwordHash,
      firstName: 'Мария',
      lastName: 'Петрова',
      role: Role.STUDENT,
    },
  });

  const student2 = await prisma.user.create({
    data: {
      email: 'student2@guitar.app',
      passwordHash,
      firstName: 'Дмитрий',
      lastName: 'Сидоров',
      role: Role.STUDENT,
    },
  });

  console.log(`✅ Создано пользователей: teacher, student1, student2`);

  await prisma.teacherStudent.createMany({
    data: [
      { teacherId: teacher.id, studentId: student1.id },
      { teacherId: teacher.id, studentId: student2.id },
    ],
  });

  const course = await prisma.course.create({
    data: {
      title: 'Основы гитары для начинающих',
      description: 'Базовые аккорды, ноты и техника игры',
      status: CourseStatus.PUBLISHED,
      publishedAt: new Date(),
      teacherId: teacher.id,
    },
  });

  await prisma.task.createMany({
    data: [
      {
        courseId: course.id,
        type: TaskType.EAR_TRAINING,
        title: 'Угадай ноту',
        instruction: 'Прослушай звук и выбери правильную ноту',
        audioContent: 'notes/A4.mp3',
        answerOptions: ['A', 'B', 'C', 'D'],
        correctAnswer: 'A',
        orderIndex: 1,
        isTemplate: true,
      },
      {
        courseId: course.id,
        type: TaskType.EAR_TRAINING,
        title: 'Угадай аккорд',
        instruction: 'Определи, какой аккорд звучит',
        audioContent: 'chords/Am.mp3',
        answerOptions: ['Am', 'C', 'G', 'Em'],
        correctAnswer: 'Am',
        orderIndex: 2,
        isTemplate: true,
      },
      {
        courseId: course.id,
        type: TaskType.PLAY_PRACTICE,
        title: 'Сыграй ноту E',
        instruction: 'Настрой первую струну на ноту E4 (329.63 Гц)',
        expectedNote: 'E4',
        toleranceCents: 25,
        orderIndex: 3,
        isTemplate: true,
      },
      {
        courseId: course.id,
        type: TaskType.PLAY_PRACTICE,
        title: 'Сыграй аккорд Am',
        instruction: 'Возьми аккорд Am и держи 3 секунды',
        expectedNote: 'Am',
        toleranceCents: 30,
        orderIndex: 4,
        isTemplate: true,
      },
    ],
  });

  console.log(`✅ Создан курс "${course.title}" с 4 заданиями`);

  await prisma.studentCourse.createMany({
    data: [
      { studentId: student1.id, courseId: course.id, progress: 50 },
      { studentId: student2.id, courseId: course.id, progress: 0 },
    ],
  });

  console.log('✅ Студенты записаны на курс');
  console.log('\n📋 Тестовые аккаунты:');
  console.log('   Учитель: teacher@guitar.app  / password123');
  console.log('   Студент 1: student1@guitar.app / password123');
  console.log('   Студент 2: student2@guitar.app / password123');
}

main()
  .catch((e) => {
    console.error('❌ Ошибка при заполнении БД:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
