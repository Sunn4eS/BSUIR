const { io } = require('socket.io-client');
const HOST = process.env.LIVE_E2E_HOST || 'http://backend:4000';
const API = `${HOST}/api`;

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
  const t = await api('/auth/login', { method: 'POST', body: { email: 'teacher@guitar.app', password: 'password123' } });
  const { students } = await api('/users/students', { token: t.token });
  const student = students.find((s) => s.email === 'student1@guitar.app');

  const teacher = io(HOST, { auth: { token: `Bearer ${t.token}` }, transports: ['websocket'], reconnection: false });
  await new Promise((r) => teacher.once('connect', r));

  teacher.onAny((e, p) => console.log('teacher <-', e, JSON.stringify(p).slice(0, 140)));

  teacher.emit('create_session', { studentId: student.id });
  const created = await new Promise((r) => teacher.once('session_created', r));
  console.log('created', created.roomCode);

  teacher.emit('join_room', { roomCode: created.roomCode });
  const joined = await new Promise((r) => teacher.once('room_joined', r));
  console.log('joined', joined.room?.roomName || joined.room);

  await wait(300);
  console.log('emitting send_task...');
  teacher.emit('send_task', {
    cardData: { type: 'EAR_TRAINING', title: 'debug', correctAnswer: 'A', answerOptions: ['A', 'B'] },
  });
  await wait(3000);
  console.log('done waiting');
  teacher.emit('end_session');
  await wait(500);
  teacher.disconnect();
  process.exit(0);
})();
