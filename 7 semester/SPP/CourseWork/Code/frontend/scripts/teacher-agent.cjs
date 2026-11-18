/**
 * scripts/teacher-agent.cjs — имитация учителя для проверки UI ученика
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
const wait = (ms) => new Promise((r) => setTimeout(r, ms));

(async () => {
  const login = await api('/auth/login', {
    method: 'POST',
    body: { email: 'teacher@guitar.app', password: 'password123' },
  });
  const { students } = await api('/users/students', { token: login.token });
  const student = students.find((s) => s.email === STUDENT_EMAIL);

  const socket = io(HOST, { auth: { token: `Bearer ${login.token}` }, transports: ['websocket'], reconnection: false });
  await new Promise((resolve, reject) => {
    socket.once('connect', resolve);
    socket.once('connect_error', reject);
  });

  socket.on('room_joined', async ({ session, participants }) => {
    console.log('[teacher-agent] room joined', session?.roomCode, 'participants:', participants?.map((p) => p.role));
  });
  socket.on('user_joined', ({ user }) => console.log('[teacher-agent] user joined', user?.firstName, user?.role));
  socket.on('task_sent', ({ card }) => console.log('[teacher-agent] task sent', card.id));

  socket.emit('create_session', { studentId: student.id });
  const created = await new Promise((r) => socket.once('session_created', r));
  console.log('[teacher-agent] session created', created.roomCode);

  socket.emit('join_room', { roomCode: created.roomCode });
  await wait(4000);

  socket.emit('send_task', {
    cardData: {
      type: 'EAR_TRAINING',
      title: 'Угадай ноту',
      instruction: 'Прослушай звук и выбери правильный ответ',
      correctAnswer: 'A',
      answerOptions: ['A', 'C', 'D', 'G'],
    },
  });

  await wait(20000);

  socket.emit('send_task', {
    cardData: {
      type: 'PLAY_PRACTICE',
      title: 'Сыграй ноту E',
      instruction: 'Сыграй и удержи ноту E4',
      expectedNote: 'E4',
      toleranceCents: 20,
    },
  });

  await wait(25000);
  socket.emit('end_session');
  await wait(1000);
  socket.disconnect();
  process.exit(0);
})().catch((err) => {
  console.error('[teacher-agent] failed:', err);
  process.exit(1);
});
