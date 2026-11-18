/**
 * sockets/socket.server.js — инициализация Socket.io сервера
 *
 * Архитектура:
 * - Аутентификация через JWT в middleware (handshake)
 * - Комнаты (rooms) по шаблону: `session:{roomCode}`
 * - События: join_room, send_task, task_status_update, leave_room
 */

const { Server }    = require('socket.io');
const { verifyToken } = require('../config/jwt');
const { prisma }    = require('../config/database');
const roomHandler   = require('./handlers/room.handler');
const taskHandler   = require('./handlers/task.handler');

/**
 * Инициализирует Socket.io на существующем HTTP сервере
 * @param {import('http').Server} httpServer
 */
function initSocketServer(httpServer) {
  const io = new Server(httpServer, {
    cors: {
      origin: process.env.FRONTEND_URL || 'http://localhost:5173',
      methods: ['GET', 'POST'],
      credentials: true,
    },
    // Таймауты
    pingInterval: 10000,
    pingTimeout: 5000,
  });

  // ─── Middleware: аутентификация по JWT ──────────────────
  io.use(async (socket, next) => {
    try {
      // Токен передаётся в auth при connect:
      // socket = io(URL, { auth: { token: 'Bearer ...' } })
      const token = socket.handshake.auth?.token?.replace('Bearer ', '');

      if (!token) {
        return next(new Error('Токен не предоставлен'));
      }

      const decoded = verifyToken(token);

      // Проверяем пользователя в БД
      const user = await prisma.user.findUnique({
        where: { id: decoded.id },
        select: { id: true, email: true, role: true, firstName: true, lastName: true },
      });

      if (!user) {
        return next(new Error('Пользователь не найден'));
      }

      // Прикрепляем пользователя к сокету.
      // Роль нормализуем к верхнему регистру — как в HTTP-middleware,
      // чтобы проверки user.role === 'TEACHER' не зависели от регистра.
      socket.data.user = {
        ...user,
        role: String(user.role ?? '').trim().toUpperCase(),
      };
      next();
    } catch (err) {
      next(new Error('Неверный токен: ' + err.message));
    }
  });

  // ─── Основной обработчик подключения ────────────────────
  io.on('connection', async (socket) => {
    const user = socket.data.user;
    console.log(`🔌 [Socket] Подключён: ${user.email} (${user.role}) — ${socket.id}`);

    // Личная комната пользователя — для приглашений и адресных событий
    socket.join(`user:${user.id}`);

    // Регистрируем обработчики событий
    roomHandler(io, socket);
    taskHandler(io, socket);

    // Ученик мог перезагрузить страницу — напоминаем про активный урок
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
