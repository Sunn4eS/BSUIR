const { prisma } = require('../../config/database');
const { v4: uuidv4 } = require('uuid');

module.exports = function roomHandler(io, socket) {
  const user = socket.data.user;

  socket.on('join_room', async ({ roomCode } = {}) => {
    try {
      if (!roomCode) {
        socket.emit('room_error', { message: 'roomCode обязателен' });
        return;
      }

      let session = await prisma.liveSession.findUnique({
        where: { roomCode },
        include: {
          teacher: { select: { id: true, firstName: true, lastName: true, role: true } },
          student: { select: { id: true, firstName: true, lastName: true, role: true } },
        },
      });

      if (!session) {
        socket.emit('room_error', { message: 'Сессия не найдена' });
        return;
      }

      if (!session.isActive) {
        socket.emit('room_error', { message: 'Сессия завершена' });
        return;
      }

      const isParticipant =
        session.teacherId === user.id || session.studentId === user.id;
      if (!isParticipant) {
        socket.emit('room_error', { message: 'Вы не участник этой сессии' });
        return;
      }

      const roomName = `session:${roomCode}`;
      socket.join(roomName);
      socket.data.currentRoom = roomName;
      socket.data.sessionId   = session.id;

      const sockets = await io.in(roomName).fetchSockets();
      const participants = sockets
        .map((item) => item.data.user)
        .filter(Boolean)
        .map((item) => ({ id: item.id, role: item.role, firstName: item.firstName }));

      socket.emit('room_joined', {
        room: roomName,
        participants,
        session: {
          id: session.id,
          roomCode: session.roomCode,
          teacher: session.teacher,
          student: session.student,
        },
      });

      try {
        const cards = await prisma.liveTaskCard.findMany({
          where: { sessionId: session.id },
          include: { task: true },
          orderBy: { sentAt: 'asc' },
        });
        socket.emit('task_history', { cards });
        socket.emit('lesson:init_state', {
          tasks: cards,
          currentTaskIndex: cards.length > 0 ? cards.length - 1 : 0,
          maxAvailableIndex: cards.length > 0 ? cards.length - 1 : 0,
        });
      } catch (err) {
        console.error('[Room] task_history error:', err);
      }

      socket.to(roomName).emit('user_joined', {
        user: {
          id: user.id,
          firstName: user.firstName,
          lastName: user.lastName,
          role: user.role,
        },
      });

      console.log(`🏠 [Room] ${user.email} вошёл в ${roomName}`);
    } catch (err) {
      console.error('[Room] join_room error:', err);
      socket.emit('room_error', { message: 'Ошибка при входе в комнату' });
    }
  });

  socket.on('create_session', async ({ studentId } = {}) => {
    try {
      if (user.role !== 'TEACHER') {
        socket.emit('room_error', { message: 'Только учитель может создавать сессии' });
        return;
      }

      if (!studentId) {
        socket.emit('room_error', { message: 'studentId обязателен' });
        return;
      }

      const roomCode = uuidv4().slice(0, 8).toUpperCase();

      await prisma.liveSession.updateMany({
        where: {
          teacherId: user.id,
          studentId,
          isActive: true,
        },
        data: { isActive: false, endedAt: new Date() },
      });

      const session = await prisma.liveSession.create({
        data: {
          teacherId: user.id,
          studentId,
          roomCode,
        },
      });

      socket.emit('session_created', {
        sessionId: session.id,
        roomCode: session.roomCode,
        studentId,
      });

      io.to(`user:${studentId}`).emit('session_invited', {
        sessionId: session.id,
        roomCode: session.roomCode,
        teacher: {
          id: user.id,
          firstName: user.firstName,
          lastName: user.lastName,
        },
      });

      console.log(`📋 [Room] Сессия создана: ${roomCode} для студента ${studentId}`);
    } catch (err) {
      console.error('[Room] create_session error:', err);
      socket.emit('room_error', { message: 'Ошибка при создании сессии' });
    }
  });

  socket.on('get_active_session', async () => {
    try {
      if (user.role !== 'STUDENT') return;

      const session = await prisma.liveSession.findFirst({
        where: { studentId: user.id, isActive: true },
        include: {
          teacher: { select: { id: true, firstName: true, lastName: true } },
        },
        orderBy: { startedAt: 'desc' },
      });

      if (!session) {
        socket.emit('active_session', { session: null });
        return;
      }

      socket.emit('active_session', {
        session: {
          id: session.id,
          roomCode: session.roomCode,
          teacher: session.teacher,
        },
      });
    } catch (err) {
      console.error('[Room] get_active_session error:', err);
    }
  });

  socket.on('leave_room', ({ roomCode } = {}) => {
    try {
      const room = roomCode ? `session:${String(roomCode).toUpperCase()}` : socket.data.currentRoom;
      if (!room) return;

      socket.leave(room);
      socket.to(room).emit('user_left', { userId: user.id });

      if (socket.data.currentRoom === room) {
        socket.data.currentRoom = null;
        socket.data.sessionId = null;
      }

      console.log(`👋 [Room] ${user.email} покинул ${room}`);
    } catch (err) {
      console.error('[Room] leave_room error:', err);
    }
  });
};
