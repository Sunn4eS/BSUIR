/**
 * scripts/student-agent.cjs — имитация ученика для проверки UI учителя
 * Входит в комнату по приглашению и отвечает на карточки.
 */

const { io } = require('socket.io-client');

const HOST = process.env.LIVE_E2E_HOST || 'http://backend:4000';
const API = `${HOST}/api`;
const STUDENT_EMAIL = process.env.STUDENT_EMAIL || 'student1@guitar.app';

async function api(path, { method = 'GET', body, token } = {}) {
  const res = await fetch(API + path, {
    method,
    headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: body ? JSON.stringify(body) : undefined,
  });
  return res.json();
}

(async () => {
  const login = await api('/auth/login', {
    method: 'POST',
    body: { email: STUDENT_EMAIL, password: 'password123' },
  });

  const socket = io(HOST, {
    auth: { token: `Bearer ${login.token}` },
    transports: ['websocket'],
    reconnection: false,
  });

  await new Promise((resolve, reject) => {
    socket.once('connect', resolve);
    socket.once('connect_error', reject);
  });

  console.log('[agent] connected as', STUDENT_EMAIL);

  socket.on('session_invited', ({ roomCode }) => {
    console.log('[agent] invited to', roomCode);
    socket.emit('join_room', { roomCode });
  });

  socket.on('room_joined', ({ session }) => {
    console.log('[agent] joined room', session?.roomCode);
  });

  socket.on('new_task_card', ({ card }) => {
    const data = card.task || card.cardData || {};
    console.log('[agent] card received:', data.type, data.title);
    socket.emit('task_status', { cardId: card.id, status: 'IN_PROGRESS' });

    setTimeout(() => {
      const answer = data.type === 'EAR_TRAINING' ? data.correctAnswer : true;
      socket.emit('task_answer', { cardId: card.id, answer, reactionMs: 900 });
      console.log('[agent] answered', card.id, '->', answer);
    }, 1200);
  });

  socket.on('session_ended', () => {
    console.log('[agent] session ended');
  });

  socket.on('room_error', (payload) => console.log('[agent] room_error', payload));
  socket.on('task_error', (payload) => console.log('[agent] task_error', payload));

  setTimeout(() => {
    socket.disconnect();
    process.exit(0);
  }, 90000);
})().catch((err) => {
  console.error('[agent] failed:', err);
  process.exit(1);
});
