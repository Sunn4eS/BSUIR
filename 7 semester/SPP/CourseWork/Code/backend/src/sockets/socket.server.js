const { Server }    = require('socket.io');
const { verifyToken } = require('../config/jwt');
const { prisma }    = require('../config/database');
const roomHandler   = require('./handlers/room.handler');
const taskHandler   = require('./handlers/task.handler');

function initSocketServer(httpServer) {
  const io = new Server(httpServer, {
    cors: {
      origin: process.env.FRONTEND_URL || 'http://localhost:5173',
      methods: ['GET', 'POST'],
      credentials: true,
    },
    pingInterval: 10000,
    pingTimeout: 5000,
  });

  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth?.token?.replace('Bearer ', '');

      if (!token) {
        return next(new Error('Токен не предоставлен'));
      }

      const decoded = verifyToken(token);

      const user = await prisma.user.findUnique({
        where: { id: decoded.id },
        select: { id: true, email: true, role: true, firstName: true, lastName: true },
      });

      if (!user) {
        return next(new Error('Пользователь не найден'));
      }

      socket.data.user = {
        ...user,
        role: String(user.role ?? '').trim().toUpperCase(),
      };
      next();
    } catch (err) {
      next(new Error('Неверный токен: ' + err.message));
    }
  });

  io.on('connection', async (socket) => {
    const user = socket.data.user;
    console.log(`🔌 [Socket] Подключён: ${user.email} (${user.role}) — ${socket.id}`);

    socket.join(`user:${user.id}`);

    roomHandler(io, socket);
    taskHandler(io, socket);

    if (user.role === 'STUDENT') {
      try {
        const activeSession = await prisma.liveSession.findFirst({
          where: { studentId: user.id, isActive: true },
          include: {
            teacher: { select: { id: true, firstName: true, lastName: true } },
          },
          orderBy: { startedAt: 'desc' },
        });

        if (activeSession) {
          socket.emit('session_invited', {
            sessionId: activeSession.id,
            roomCode: activeSession.roomCode,
            teacher: activeSession.teacher,
          });
        }
      } catch (err) {
        console.error('[Socket] active session lookup error:', err);
      }
    }

    socket.on('disconnect', (reason) => {
      console.log(`🔌 [Socket] Отключён: ${user.email} — ${reason}`);
    });
  });

  console.log('⚡ Socket.io инициализирован');
  return io;
}

module.exports = { initSocketServer };
