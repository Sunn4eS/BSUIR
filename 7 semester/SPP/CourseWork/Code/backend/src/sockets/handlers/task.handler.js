/**
 * sockets/handlers/task.handler.js
 * Управление заданиями в Live-сессии
 *
 * CLIENT → SERVER:
 *   send_task    { taskId?, cardData? }  — учитель отправляет карточку
 *   task_status  { cardId, status }      — ученик обновляет статус
 *   task_answer  { cardId, answer, reactionMs } — ученик отвечает
 *   end_session                          — учитель завершает урок
 *
 * SERVER → CLIENT:
 *   new_task_card       { card }                         — ученику
 *   task_sent           { card }                         — учителю
 *   card_status_updated { cardId, status, studentId }    — учителю
 *   task_result         { cardId, isCorrect, answer }    — учителю
 *   my_task_result      { cardId, isCorrect }            — ученику
 *   session_ended       { sessionId }                    — всем
 */

const { prisma } = require('../../config/database');

const VALID_STATUSES = ['PENDING', 'IN_PROGRESS', 'CORRECT', 'INCORRECT', 'SKIPPED'];
const VALID_TYPES = [
  'EAR_TRAINING',    // угадать ноту/аккорд на слух
  'PLAY_PRACTICE',   // сыграть ноту/аккорд
  'FINGERING_TEST',  // угадать/собрать аппликатуру аккорда
  'PLAY_FINGERING',  // сыграть аппликатуру аккорда по грифу
  'COMBO_FINGERING', // собрать аппликатуру, затем сыграть её
];
const FINGERING_TYPES = ['FINGERING_TEST', 'PLAY_FINGERING', 'COMBO_FINGERING'];
const VALID_FINGERING_MODES = ['BUILD', 'GUESS'];

/** Разбор списка вариантов ответа: массив или строка через запятую */
function parseOptions(value) {
  if (Array.isArray(value)) {
    return value.map((item) => String(item).trim()).filter(Boolean);
  }
  return String(value || '')
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean);
}

/** Нормализует «карточку на лету», пришедшую от учителя */
function normalizeCardData(cardData) {
  if (!cardData || typeof cardData !== 'object') return null;

  const type = cardData.type || cardData.task?.type;
  if (!VALID_TYPES.includes(type)) return null;

  const title = cardData.title || cardData.task?.title;
  if (!title) return null;

  if (type === 'EAR_TRAINING') {
    const options = parseOptions(cardData.answerOptions);
    if (!cardData.correctAnswer || options.length < 2) return null;

    return {
      ...cardData,
      type,
      title,
      answerOptions: options,
    };
  }

  if (type === 'FINGERING_TEST') {
    // Аппликатура: GUESS — выбор из вариантов, BUILD — сборка на грифе
    const options = parseOptions(cardData.answerOptions);
    const correctAnswer = cardData.correctAnswer || cardData.expectedNote;
    if (!correctAnswer || options.length < 2) return null;

    const fingeringMode = VALID_FINGERING_MODES.includes(cardData.fingeringMode)
      ? cardData.fingeringMode
      : 'GUESS';

    return {
      ...cardData,
      type,
      title,
      answerOptions: options,
      correctAnswer,
      fingeringMode,
    };
  }

  if (type === 'PLAY_FINGERING' || type === 'COMBO_FINGERING') {
    // Сыграть (и, возможно, сначала собрать) аппликатуру аккорда
    if (!cardData.expectedNote) return null;

    return {
      ...cardData,
      type,
      title,
      toleranceCents: Number(cardData.toleranceCents) || 30,
    };
  }

  // PLAY_PRACTICE
  if (!cardData.expectedNote) return null;

  return {
    ...cardData,
    type,
    title,
    toleranceCents: Number(cardData.toleranceCents) || 20,
  };
}

module.exports = function taskHandler(io, socket) {
  const user = socket.data.user;

  // ── send_task ────────────────────────────────────────────
  socket.on('send_task', async ({ taskId, cardData } = {}) => {
    try {
      if (user.role !== 'TEACHER') {
        socket.emit('task_error', { message: 'Только учитель может отправлять задания' });
        return;
      }

      const sessionId = socket.data.sessionId;
      if (!sessionId) {
        socket.emit('task_error', { message: 'Вы не в сессии' });
        return;
      }

      const session = await prisma.liveSession.findUnique({ where: { id: sessionId } });
      if (!session || !session.isActive) {
        socket.emit('task_error', { message: 'Сессия неактивна' });
        return;
      }

      let normalizedCardData = null;

      if (taskId) {
        const task = await prisma.task.findUnique({
          where: { id: taskId },
          include: { course: { select: { teacherId: true, status: true } } },
        });

        if (!task) {
          socket.emit('task_error', { message: 'Задание не найдено' });
          return;
        }
        if (task.course.teacherId !== user.id) {
          socket.emit('task_error', { message: 'Нет доступа к этому заданию' });
          return;
        }
        if (task.course.status !== 'PUBLISHED') {
          socket.emit('task_error', { message: 'Курс задания не опубликован' });
          return;
        }
      } else {
        normalizedCardData = normalizeCardData(cardData);
        if (!normalizedCardData) {
          socket.emit('task_error', { message: 'Некорректные данные карточки' });
          return;
        }
      }

      const card = await prisma.liveTaskCard.create({
        data: {
          sessionId,
          taskId: taskId || null,
          cardData: normalizedCardData,
          status: 'PENDING',
        },
        include: { task: true },
      });

      // Доставляем ученику в личную комнату (даже если он ещё не в session-room)
      io.to(`user:${session.studentId}`).emit('new_task_card', { card });

      // Подтверждение учителю
      socket.emit('task_sent', { card });

      // Оповещаем комнату о новом активном задании урока
      const roomName = `session:${session.roomCode}`;
      const cardsInSession = await prisma.liveTaskCard.count({ where: { sessionId } });
      io.to(roomName).emit('lesson:set_task', {
        card,
        currentTaskIndex: Math.max(0, cardsInSession - 1),
        totalTasks: cardsInSession,
      });

      console.log(`📤 [Task] Карточка ${card.id} отправлена ученику ${session.studentId}`);
    } catch (err) {
      console.error('[Task] send_task error:', err);
      socket.emit('task_error', { message: 'Ошибка при отправке задания' });
    }
  });

  // ── task_status ──────────────────────────────────────────
  socket.on('task_status', async ({ cardId, status } = {}) => {
    try {
      if (!cardId || !VALID_STATUSES.includes(status)) return;

      const card = await prisma.liveTaskCard.findUnique({
        where: { id: cardId },
        include: { session: true },
      });

      if (!card) return;
      if (card.session.studentId !== user.id) {
        socket.emit('task_error', { message: 'Карточка принадлежит другой сессии' });
        return;
      }

      // Обновляем атомарно (условие в WHERE): финальный статус
      // (CORRECT/INCORRECT/SKIPPED) не перетирается опоздавшим
      // IN_PROGRESS/PENDING — например, от вкладки ученика, открытой
      // на другой странице
      const updated = await prisma.liveTaskCard.updateMany({
        where: {
          id: cardId,
          status: { in: ['PENDING', 'IN_PROGRESS'] },
        },
        data: {
          status,
          ...(status !== 'PENDING' && status !== 'IN_PROGRESS'
            ? { completedAt: new Date() }
            : {}),
        },
      });

      if (updated.count === 0) {
        console.log(`↩️ [Task] Статус карточки ${cardId} уже финальный — игнорирую ${status}`);
        return;
      }

      io.to(`session:${card.session.roomCode}`).emit('card_status_updated', {
        cardId,
        status,
        studentId: user.id,
        timestamp: new Date().toISOString(),
      });
    } catch (err) {
      console.error('[Task] task_status error:', err);
    }
  });

  // ── task_answer ──────────────────────────────────────────
  socket.on('task_answer', async ({ cardId, answer, reactionMs } = {}) => {
    try {
      if (!cardId || answer === undefined) return;

      const card = await prisma.liveTaskCard.findUnique({
        where: { id: cardId },
        include: { task: true, session: true },
      });

      if (!card) {
        socket.emit('task_error', { message: 'Карточка не найдена' });
        return;
      }

      if (card.session.studentId !== user.id) {
        socket.emit('task_error', { message: 'Карточка принадлежит другой сессии' });
        return;
      }

      let isCorrect = false;
      const payload = card.task || card.cardData || {};

      if (payload.type === 'EAR_TRAINING') {
        isCorrect =
          String(payload.correctAnswer).toLowerCase() === String(answer).toLowerCase();
      } else if (payload.type === 'FINGERING_TEST') {
        if ((payload.fingeringMode || 'GUESS') === 'BUILD') {
          // Клиент сам проверил собранную аппликатуру на грифе:
          // { chord, frets, correct } — доверяем, как PLAY_PRACTICE
          isCorrect = Boolean(
            answer && typeof answer === 'object' && answer.correct === true
          );
        } else {
          const correctAnswer = payload.correctAnswer || payload.expectedNote;
          isCorrect =
            Boolean(correctAnswer) &&
            String(correctAnswer).toLowerCase() === String(answer).toLowerCase();
        }
      } else if (
        payload.type === 'PLAY_FINGERING' ||
        payload.type === 'COMBO_FINGERING' ||
        payload.type === 'PLAY_PRACTICE'
      ) {
        // Микрофонная проверка выполняется на клиенте — серверу
        // приходит только вердикт
        isCorrect = answer === true || answer === 'correct';
      }

      const status = isCorrect ? 'CORRECT' : 'INCORRECT';
      const answerText =
        answer !== null && typeof answer === 'object'
          ? JSON.stringify(answer)
          : String(answer);

      await prisma.liveTaskCard.update({
        where: { id: cardId },
        data: { status, completedAt: new Date() },
      });

      if (card.taskId) {
        await prisma.taskResult.create({
          data: {
            studentId: user.id,
            taskId: card.taskId,
            status,
            answer: answerText,
            reactionMs,
            liveSessionId: card.sessionId,
            attempts: 1,
          },
        });
      }

      io.to(`session:${card.session.roomCode}`).emit('task_result', {
        cardId,
        isCorrect,
        answer: answerText,
        studentId: user.id,
        reactionMs,
      });

      // Также транслируем по протоколу урока
      io.to(`session:${card.session.roomCode}`).emit('lesson:task_completed', {
        cardId,
        taskId: card.taskId,
        studentId: user.id,
        isCorrect,
        status,
        answer: answerText,
        reactionMs,
      });

      socket.emit('my_task_result', { cardId, isCorrect });

      console.log(`✅ [Task] cardId=${cardId} answer=${answer} correct=${isCorrect}`);
    } catch (err) {
      console.error('[Task] task_answer error:', err);
      socket.emit('task_error', { message: 'Ошибка при обработке ответа' });
    }
  });

  // ── lesson:set_task (Учитель переключает задание для сессии) ─────────
  socket.on('lesson:set_task', async ({ taskIndex, cardId } = {}) => {
    try {
      if (user.role !== 'TEACHER') return;
      const room = socket.data.currentRoom;
      if (room) {
        io.to(room).emit('lesson:set_task', {
          currentTaskIndex: taskIndex,
          cardId,
        });
      }
    } catch (err) {
      console.error('[Task] lesson:set_task error:', err);
    }
  });

  // ── lesson:student_navigate (Ученик запрашивает переключение) ────────
  socket.on('lesson:student_navigate', ({ targetIndex } = {}) => {
    socket.emit('lesson:student_navigate_ack', {
      currentTaskIndex: targetIndex,
    });
  });

  // ── lesson:task_completed (Прямой триггер от ученика) ───────────────
  socket.on('lesson:task_completed', async (data = {}) => {
    const { cardId, answer, reactionMs } = data;
    if (cardId) {
      socket.emit('task_answer', { cardId, answer: answer ?? 'correct', reactionMs });
    }
  });

  // ── end_session ──────────────────────────────────────────
  socket.on('end_session', async () => {
    try {
      if (user.role !== 'TEACHER') return;

      const sessionId = socket.data.sessionId;
      if (!sessionId) return;

      const session = await prisma.liveSession.findUnique({ where: { id: sessionId } });
      if (!session || session.teacherId !== user.id) return;

      await prisma.liveSession.update({
        where: { id: sessionId },
        data: { isActive: false, endedAt: new Date() },
      });

      const room = `session:${session.roomCode}`;
      io.to(room).emit('session_ended', { sessionId });

      // Выводим всех из комнаты
      io.in(room).socketsLeave(room);

      console.log(`🏁 [Task] Сессия ${sessionId} завершена учителем`);
    } catch (err) {
      console.error('[Task] end_session error:', err);
    }
  });
};
