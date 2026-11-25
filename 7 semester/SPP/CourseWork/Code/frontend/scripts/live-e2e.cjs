const { io } = require('socket.io-client');

const HOST = process.env.LIVE_E2E_HOST || 'http://backend:4000';
const API = `${HOST}/api`;
const WS = HOST;

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
  return io(WS, {
    auth: { token: `Bearer ${token}` },
    transports: ['websocket'],
    reconnection: false,
  });
}

function waitEvent(socket, event, timeout = 8000) {
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

function waitEventMatching(socket, event, predicate, timeout = 8000) {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => {
      socket.off(event, handler);
      reject(new Error(`timeout waiting for matching ${event}`));
    }, timeout);
    const handler = (payload) => {
      if (!predicate(payload)) return;
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
  const results = [];
  const check = (name, ok, detail = '') => {
    results.push({ name, ok, detail });
    console.log(`${ok ? 'PASS' : 'FAIL'} — ${name}${detail ? ` (${detail})` : ''}`);
    if (!ok) process.exitCode = 1;
  };

  const teacherLogin = await api('/auth/login', {
    method: 'POST',
    body: { email: 'teacher@guitar.app', password: 'password123' },
  });
  const studentLogin = await api('/auth/login', {
    method: 'POST',
    body: { email: 'student1@guitar.app', password: 'password123' },
  });

  const { students } = await api('/users/students', { token: teacherLogin.token });
  const student = students.find((s) => s.email === 'student1@guitar.app');
  check('teacher sees student1', Boolean(student), student?.id);

  const library = await api('/courses/library', { token: teacherLogin.token });
  const libraryTask = library.courses?.[0]?.tasks?.[0];
  check('published library has a task', Boolean(libraryTask), libraryTask?.title);

  const teacher = connect(teacherLogin.token);
  const studentSocket = connect(studentLogin.token);
  await Promise.all([waitConnect(teacher), waitConnect(studentSocket)]);
  check('both sockets connected', true);

  teacher.onAny((event, payload) => console.log('  teacher <-', event, JSON.stringify(payload).slice(0, 160)));
  studentSocket.onAny((event, payload) => console.log('  student <-', event, JSON.stringify(payload).slice(0, 160)));
  teacher.on('task_error', (p) => console.log('  TEACHER task_error', p));
  studentSocket.on('task_error', (p) => console.log('  STUDENT task_error', p));
  teacher.on('room_error', (p) => console.log('  TEACHER room_error', p));
  studentSocket.on('room_error', (p) => console.log('  STUDENT room_error', p));

  const invites = [];
  studentSocket.on('session_invited', (payload) => invites.push(payload));

  async function waitFor(fn, timeout = 8000) {
    const started = Date.now();
    while (Date.now() - started < timeout) {
      const value = fn();
      if (value) return value;
      await new Promise((resolve) => setTimeout(resolve, 50));
    }
    throw new Error('timeout waiting for condition');
  }

  const newCard = waitEvent(studentSocket, 'new_task_card');
  const myResult = waitEvent(studentSocket, 'my_task_result');
  const studentEnded = waitEvent(studentSocket, 'session_ended');

  const created = waitEvent(teacher, 'session_created');
  const taskSent = waitEvent(teacher, 'task_sent');
  const statusUpdated = waitEvent(teacher, 'card_status_updated');
  const taskResult = waitEvent(teacher, 'task_result');
  const teacherEnded = waitEvent(teacher, 'session_ended');

  [newCard, myResult, studentEnded, created, taskSent, statusUpdated, taskResult, teacherEnded]
    .forEach((promise) => promise.catch(() => {}));

  teacher.emit('create_session', { studentId: student.id });
  const createdPayload = await created;
  check('teacher create_session', Boolean(createdPayload?.roomCode), createdPayload?.roomCode);

  const invitedPayload = await waitFor(
    () => invites.find((item) => item.roomCode === createdPayload.roomCode)
  );
  check('student receives session_invited', invitedPayload?.roomCode === createdPayload.roomCode);

  const teacherJoined = waitEvent(teacher, 'room_joined');
  const studentJoined = waitEvent(studentSocket, 'room_joined');
  const studentSeesTeacher = waitEvent(studentSocket, 'user_joined');

  studentSocket.emit('join_room', { roomCode: createdPayload.roomCode });
  const studentRoom = await studentJoined;
  check('student joined room', studentRoom?.session?.roomCode === createdPayload.roomCode);

  teacher.emit('join_room', { roomCode: createdPayload.roomCode });
  const teacherRoom = await teacherJoined;
  check('teacher joined room', teacherRoom?.session?.roomCode === createdPayload.roomCode);
  const teacherSeen = await studentSeesTeacher.catch(() => null);
  check('student sees teacher joined', teacherSeen?.user?.role === 'TEACHER');

  await new Promise((resolve) => setTimeout(resolve, 300));

  console.log('  emitting send_task (quick card)');
  teacher.emit('send_task', {
    cardData: {
      type: 'EAR_TRAINING',
      title: 'E2E: угадай A',
      correctAnswer: 'A',
      answerOptions: ['A', 'C', 'D', 'G'],
    },
  });

  const sent = await taskSent;
  const card = await newCard;
  check('teacher receives task_sent', sent?.card?.id === card?.card?.id);
  check('student receives new_task_card', card?.card?.cardData?.correctAnswer === 'A');

  const cardId = card.card.id;

  studentSocket.emit('task_status', { cardId, status: 'IN_PROGRESS' });
  const statusPayload = await statusUpdated;
  check('teacher sees IN_PROGRESS', statusPayload?.status === 'IN_PROGRESS');

  studentSocket.emit('task_answer', { cardId, answer: 'A', reactionMs: 1234 });
  const result = await taskResult;
  const mine = await myResult;
  check('teacher sees correct result', result?.isCorrect === true);
  check('student sees my_task_result', mine?.isCorrect === true);

  const taskSent2 = waitEvent(teacher, 'task_sent');
  const newCard2 = waitEvent(studentSocket, 'new_task_card');
  teacher.emit('send_task', { taskId: libraryTask.id });
  const sent2 = await taskSent2;
  const card2 = await newCard2;
  check('library task delivered', sent2?.card?.taskId === libraryTask.id && card2?.card?.taskId === libraryTask.id);

  const libStatusP = waitEvent(teacher, 'card_status_updated');
  studentSocket.emit('task_status', { cardId: card2.card.id, status: 'IN_PROGRESS' });
  const libStatus = await libStatusP;
  check('library card IN_PROGRESS', libStatus?.status === 'IN_PROGRESS');

  async function sendQuickCard(cardData) {
    const sentP = waitEvent(teacher, 'task_sent');
    const newP = waitEvent(studentSocket, 'new_task_card');
    teacher.emit('send_task', { cardData });
    const [sent, card] = await Promise.all([sentP, newP]);
    return { sent, card };
  }

  async function answerCard(cardId, answer) {
    const resultP = waitEvent(teacher, 'task_result');
    const mineP = waitEvent(studentSocket, 'my_task_result');
    studentSocket.emit('task_answer', { cardId, answer, reactionMs: 500 });
    const [result, mine] = await Promise.all([resultP, mineP]);
    return { result, mine };
  }

  const guess = await sendQuickCard({
    type: 'FINGERING_TEST',
    title: 'E2E: угадай аппликатуру Am',
    fingeringMode: 'GUESS',
    correctAnswer: 'Am',
    answerOptions: ['Am', 'C', 'D', 'G'],
  });
  check('FINGERING_TEST GUESS доставлена',
    guess.card?.card?.cardData?.fingeringMode === 'GUESS'
      && guess.card?.card?.cardData?.correctAnswer === 'Am');
  const guessResult = await answerCard(guess.card.card.id, 'Am');
  check('FINGERING_TEST GUESS: верный ответ зачтён',
    guessResult.result?.isCorrect === true && guessResult.mine?.isCorrect === true);

  const build = await sendQuickCard({
    type: 'FINGERING_TEST',
    title: 'E2E: собери Am',
    fingeringMode: 'BUILD',
    expectedNote: 'Am',
    correctAnswer: 'Am',
    answerOptions: ['Am', 'C', 'D', 'G'],
  });
  check('FINGERING_TEST BUILD доставлена',
    build.card?.card?.cardData?.fingeringMode === 'BUILD');
  const buildResult = await answerCard(build.card.card.id, {
    chord: 'Am',
    frets: [-1, 0, 2, 2, 1, 0],
    correct: true,
  });
  check('FINGERING_TEST BUILD: объектный ответ зачтён',
    buildResult.result?.isCorrect === true && typeof buildResult.result?.answer === 'string',
    `answer=${buildResult.result?.answer?.slice(0, 48)}`);

  const play = await sendQuickCard({
    type: 'PLAY_FINGERING',
    title: 'E2E: сыграй Am',
    expectedNote: 'Am',
    toleranceCents: 30,
  });
  check('PLAY_FINGERING доставлена',
    play.card?.card?.cardData?.type === 'PLAY_FINGERING'
      && play.card?.card?.cardData?.expectedNote === 'Am');
  const playResult = await answerCard(play.card.card.id, true);
  check('PLAY_FINGERING: вердикт true зачтён', playResult.result?.isCorrect === true);

  const combo = await sendQuickCard({
    type: 'COMBO_FINGERING',
    title: 'E2E: собери и сыграй C',
    expectedNote: 'C',
    toleranceCents: 30,
  });
  check('COMBO_FINGERING доставлена',
    combo.card?.card?.cardData?.type === 'COMBO_FINGERING');
  const comboResult = await answerCard(combo.card.card.id, false);
  check('COMBO_FINGERING: неверный вердикт не зачтён',
    comboResult.result?.isCorrect === false && comboResult.mine?.isCorrect === false);

  const taskErrorP = waitEvent(teacher, 'task_error');
  teacher.emit('send_task', { cardData: { type: 'FINGERING', title: 'бред', expectedNote: 'Am' } });
  const taskError = await taskErrorP;
  check('неизвестный тип карточки отклонён', Boolean(taskError?.message), taskError?.message);

  const historyP = waitEvent(studentSocket, 'task_history');
  studentSocket.emit('join_room', { roomCode: createdPayload.roomCode });
  const history = await historyP;
  const historyIds = (history?.cards || []).map((c) => c.id);
  const expectedIds = [
    cardId,
    card2.card.id,
    guess.card.card.id,
    build.card.card.id,
    play.card.card.id,
    combo.card.card.id,
  ];
  check('task_history: все карточки по порядку отправки',
    historyIds.length === expectedIds.length && expectedIds.every((id, i) => historyIds[i] === id),
    `cards=${historyIds.length}`);
  const statuses = (history?.cards || []).map((c) => c.status);
  check('task_history: статусы карточек',
    JSON.stringify(statuses) === JSON.stringify(['CORRECT', 'IN_PROGRESS', 'CORRECT', 'CORRECT', 'CORRECT', 'INCORRECT']),
    statuses.join(','));

  const student2Login = await api('/auth/login', {
    method: 'POST',
    body: { email: 'student2@guitar.app', password: 'password123' },
  });

  const available = await api('/courses/available', { token: student2Login.token });
  const targetCourse = available.courses?.find((course) => !course.isEnrolled);

  if (targetCourse) {
    const join = await api(`/courses/${targetCourse.id}/join`, {
      method: 'POST',
      token: student2Login.token,
      body: { message: 'E2E: хочу на курс' },
    });
    check('student sends join request', join.request?.status === 'PENDING');

    const teacherRequests = await api('/courses/join-requests?status=PENDING', {
      token: teacherLogin.token,
    });
    check(
      'teacher sees join request',
      Boolean(teacherRequests.requests?.find((request) => request.id === join.request.id))
    );

    const approved = await api(`/courses/join-requests/${join.request.id}`, {
      method: 'PATCH',
      token: teacherLogin.token,
      body: { decision: 'approve' },
    });
    check('teacher approves join request', approved.request?.status === 'APPROVED');

    const courseStudents = await api(`/courses/${targetCourse.id}/students`, {
      token: teacherLogin.token,
    });
    const approvedStudent = courseStudents.students?.find(
      (item) => item.email === 'student2@guitar.app'
    );
    check('approved student appears in course', Boolean(approvedStudent));

    if (approvedStudent) {
      await api(`/courses/${targetCourse.id}/students/${approvedStudent.id}`, {
        method: 'DELETE',
        token: teacherLogin.token,
      });
      const afterRemove = await api(`/courses/${targetCourse.id}/students`, {
        token: teacherLogin.token,
      });
      check(
        'teacher removes student from course',
        !afterRemove.students?.some((item) => item.email === 'student2@guitar.app')
      );
    }

    const added = await api(`/courses/${targetCourse.id}/students`, {
      method: 'POST',
      token: teacherLogin.token,
      body: { email: 'student2@guitar.app' },
    });
    check(
      'teacher adds student by email',
      added.student?.email === 'student2@guitar.app'
    );

    await api(`/courses/${targetCourse.id}/students/${added.student.id}`, {
      method: 'DELETE',
      token: teacherLogin.token,
    });
  }

  teacher.emit('end_session');
  const endedTeacher = await teacherEnded;
  const endedStudent = await studentEnded;
  check('teacher receives session_ended', Boolean(endedTeacher?.sessionId));
  check('student receives session_ended', endedStudent?.sessionId === endedTeacher?.sessionId);

  teacher.disconnect();
  studentSocket.disconnect();

  const failed = results.filter((r) => !r.ok);
  console.log(`\n${results.length - failed.length}/${results.length} checks passed`);
  process.exit(failed.length ? 1 : 0);
})().catch((err) => {
  console.error('E2E FAILED:', err);
  process.exit(1);
});
