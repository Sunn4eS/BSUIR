const { io } = require('socket.io-client');

const HOST = process.env.LIVE_E2E_HOST || 'http://backend:4000';
const API = `${HOST}/api`;

const [, , mode, roomArg, watchSecArg] = process.argv;

async function api(path, { method = 'GET', body, token } = {}) {
  const res = await fetch(API + path, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(`${method} ${path} -> ${res.status} ${JSON.stringify(data)}`);
  return data;
}

function connect(token) {
  return io(HOST, {
    auth: { token: `Bearer ${token}` },
    transports: ['websocket'],
    reconnection: false,
  });
}

function waitEvent(socket, event, timeout = 10000) {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => {
      socket.off(event, handler);
      reject(new Error(`timeout waiting for ${event}`));
    }, timeout);
    const handler = (payload) => {
      clearTimeout(timer);
      socket.off(event, handler);
      resolve(payload);
    };
    socket.on(event, handler);
  });
}

function waitConnect(socket) {
  if (socket.connected) return Promise.resolve();
  return new Promise((resolve, reject) => {
    socket.once('connect', resolve);
    socket.once('connect_error', reject);
  });
}

(async () => {
  const teacherLogin = await api('/auth/login', {
    method: 'POST',
    body: { email: 'teacher@guitar.app', password: 'password123' },
  });

  const socket = connect(teacherLogin.token);
  socket.onAny((event, payload) => console.log(`  teacher <- ${event}`, JSON.stringify(payload).slice(0, 140)));
  await waitConnect(socket);

  const finish = (msg, code = 0) => {
    console.log(msg);
    socket.disconnect();
    process.exit(code);
  };

  try {
    if (mode === 'create') {
      const { students } = await api('/users/students', { token: teacherLogin.token });
      const student = students.find((s) => s.email === 'student1@guitar.app');
      if (!student) finish('FAIL: student1 not found', 1);

      socket.emit('create_session', { studentId: student.id });
      const created = await waitEvent(socket, 'session_created');
      finish(`ROOM:${created.roomCode}`);
    } else if (mode === 'send') {
      if (!roomArg) finish('FAIL: roomCode required', 1);
      socket.emit('join_room', { roomCode: roomArg });
      await waitEvent(socket, 'room_joined');

      socket.emit('send_task', {
        cardData: {
          type: 'EAR_TRAINING',
          title: 'Угадай: A',
          instruction: 'Прослушай звук и выбери правильный ответ',
          correctAnswer: 'A',
          answerOptions: ['A', 'C', 'D', 'G'],
        },
      });
      await waitEvent(socket, 'task_sent');
      finish('SENT_OK');
    } else if (mode === 'fingering') {
      if (!roomArg) finish('FAIL: roomCode required', 1);
      const subtype = process.argv[4] || 'build';
      const chord = process.argv[5] || 'Am';

      const options = [chord, ...['C', 'D', 'G', 'Em', 'Am', 'Bm'].filter((n) => n !== chord).slice(0, 3)];
      const cards = {
        build: {
          type: 'FINGERING_TEST',
          title: `Собери аппликатуру: ${chord}`,
          instruction: `Собери на грифе аппликатуру аккорда ${chord}`,
          fingeringMode: 'BUILD',
          correctAnswer: chord,
          expectedNote: chord,
          answerOptions: options,
        },
        guess: {
          type: 'FINGERING_TEST',
          title: `Аппликатура: ${chord}`,
          instruction: 'Посмотри на аппликатуру и выбери аккорд',
          fingeringMode: 'GUESS',
          correctAnswer: chord,
          expectedNote: chord,
          answerOptions: options,
        },
        play: {
          type: 'PLAY_FINGERING',
          title: `Сыграй аппликатуру: ${chord}`,
          instruction: `Собери и сыграй аккорд ${chord}`,
          expectedNote: chord,
          toleranceCents: 30,
        },
        combo: {
          type: 'COMBO_FINGERING',
          title: `Собери и сыграй: ${chord}`,
          instruction: `Сначала собери, затем сыграй аккорд ${chord}`,
          expectedNote: chord,
          toleranceCents: 30,
        },
      };
      const cardData = cards[subtype];
      if (!cardData) finish('FAIL: subtype must be build | guess | play | combo', 1);

      socket.emit('join_room', { roomCode: roomArg });
      await waitEvent(socket, 'room_joined');
      socket.emit('send_task', { cardData });
      await waitEvent(socket, 'task_sent');
      finish(`SENT_${subtype.toUpperCase()}_OK`);
    } else if (mode === 'end') {
      if (!roomArg) finish('FAIL: roomCode required', 1);
      socket.emit('join_room', { roomCode: roomArg });
      await waitEvent(socket, 'room_joined');
      socket.emit('end_session');
      await waitEvent(socket, 'session_ended');
      finish('ENDED_OK');
    } else if (mode === 'watch') {
      if (!roomArg) finish('FAIL: roomCode required', 1);
      const seconds = Number(watchSecArg) || 30;
      socket.emit('join_room', { roomCode: roomArg });
      await waitEvent(socket, 'room_joined');
      console.log(`WATCHING ${roomArg} for ${seconds}s...`);
      setTimeout(() => finish('WATCH_DONE'), seconds * 1000);
    } else {
      finish('FAIL: unknown mode (create | send | end | watch)', 1);
    }
  } catch (err) {
    finish(`FAIL: ${err.message}`, 1);
  }
})();
