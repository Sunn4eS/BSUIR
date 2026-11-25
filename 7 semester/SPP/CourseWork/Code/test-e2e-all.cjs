const assert = require('assert');
const http = require('http');

console.log('=== ТЕСТИРОВАНИЕ БЛОКА 2: DSP YIN ALGORITHM ===');

function synthesizeGuitarPluck(freq, sampleRate = 48000, length = 2048) {
  const buffer = new Float32Array(length);
  const decay = 0.998;
  let amp = 0.6;

  for (let i = 0; i < length; i++) {
    const t = i / sampleRate;
    const fundamental = Math.sin(2 * Math.PI * freq * t);
    const h2 = 0.45 * Math.sin(2 * Math.PI * freq * 2 * t);
    const h3 = 0.2 * Math.sin(2 * Math.PI * freq * 3 * t);
    buffer[i] = amp * (fundamental + h2 + h3);
    amp *= decay;
  }
  return buffer;
}

function testYIN(buffer, sampleRate, minFreq = 70, maxFreq = 1000) {
  const windowSize = Math.floor(buffer.length / 2);
  const minTau = Math.max(2, Math.floor(sampleRate / maxFreq));
  const maxTau = Math.min(windowSize, Math.floor(sampleRate / minFreq));

  const d = new Float32Array(maxTau);
  for (let tau = 1; tau < maxTau; tau++) {
    let sum = 0;
    for (let j = 0; j < windowSize; j++) {
      const diff = buffer[j] - buffer[j + tau];
      sum += diff * diff;
    }
    d[tau] = sum;
  }

  const dPrime = new Float32Array(maxTau);
  dPrime[0] = 1;
  let runningSum = 0;
  for (let tau = 1; tau < maxTau; tau++) {
    runningSum += d[tau];
    dPrime[tau] = runningSum === 0 ? 1 : (d[tau] * tau) / runningSum;
  }

  let tauFound = -1;
  for (let tau = minTau; tau < maxTau; tau++) {
    if (dPrime[tau] < 0.15) {
      while (tau + 1 < maxTau && dPrime[tau + 1] < dPrime[tau]) {
        tau++;
      }
      tauFound = tau;
      break;
    }
  }

  if (tauFound === -1) {
    let minVal = Infinity;
    for (let tau = minTau; tau < maxTau; tau++) {
      if (dPrime[tau] < minVal) {
        minVal = dPrime[tau];
        tauFound = tau;
      }
    }
  }

  let refinedTau = tauFound;
  if (tauFound > 0 && tauFound < maxTau - 1) {
    const s0 = dPrime[tauFound - 1];
    const s1 = dPrime[tauFound];
    const s2 = dPrime[tauFound + 1];
    const denom = 2 * (2 * s1 - s0 - s2);
    if (denom !== 0) {
      refinedTau = tauFound + (s2 - s0) / denom;
    }
  }

  return sampleRate / refinedTau;
}

const GUITAR_STRINGS = [
  { name: 'E2', freq: 82.41, midi: 40 },
  { name: 'A2', freq: 110.0, midi: 45 },
  { name: 'D3', freq: 146.83, midi: 50 },
  { name: 'G3', freq: 196.0, midi: 55 },
  { name: 'B3', freq: 246.94, midi: 59 },
  { name: 'E4', freq: 329.63, midi: 64 },
];

const sampleRate = 48000;
for (const string of GUITAR_STRINGS) {
  const buffer = synthesizeGuitarPluck(string.freq, sampleRate, 2048);
  const detectedFreq = testYIN(buffer, sampleRate);
  const detectedMidi = Math.round(12 * Math.log2(detectedFreq / 440) + 69);
  const cents = Math.round(1200 * Math.log2(detectedFreq / string.freq));

  assert.strictEqual(detectedMidi, string.midi, `Струна ${string.name}: MIDI не совпал`);
  assert(Math.abs(cents) <= 15, `Струна ${string.name}: отклонение в центах > 15 (${cents})`);
  console.log(`✅ [DSP PASS] Струна ${string.name}: ожидалось ${string.freq} Hz, определено ${detectedFreq.toFixed(2)} Hz (отклонение ${cents} cents)`);
}

console.log('\n=== ТЕСТИРОВАНИЕ БЛОКА 3: REST API КУРСОВ И ЗАЯВОК ===');

function request(options, body = null) {
  return new Promise((resolve, reject) => {
    const req = http.request(
      {
        host: 'localhost',
        port: 4000,
        ...options,
        headers: {
          'Content-Type': 'application/json',
          ...(options.headers || {}),
        },
      },
      (res) => {
        let data = '';
        res.on('data', (chunk) => (data += chunk));
        res.on('end', () => {
          try {
            resolve({ status: res.statusCode, data: JSON.parse(data) });
          } catch {
            resolve({ status: res.statusCode, raw: data });
          }
        });
      }
    );
    req.on('error', reject);
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

async function runApiTests() {
  try {
    const teacherLogin = await request(
      { path: '/api/auth/login', method: 'POST' },
      { email: 'teacher@guitar.app', password: 'password123' }
    );
    assert.strictEqual(teacherLogin.status, 200, 'Вход учителя не удался');
    const teacherToken = teacherLogin.data.token;
    console.log('✅ Вход преподавателя успешен');

    const studentLogin = await request(
      { path: '/api/auth/login', method: 'POST' },
      { email: 'student1@guitar.app', password: 'password123' }
    );
    assert.strictEqual(studentLogin.status, 200, 'Вход студента не удался');
    const studentToken = studentLogin.data.token;
    console.log('✅ Вход студента успешен');

    const newCourseRes = await request(
      {
        path: '/api/courses',
        method: 'POST',
        headers: { Authorization: `Bearer ${teacherToken}` },
      },
      {
        title: 'Тестовый курс DSP ' + Date.now(),
        description: 'Обучение игре медиатором и пальцами',
        isPublished: true,
      }
    );
    assert.strictEqual(newCourseRes.status, 201, 'Курс не создан');
    const courseId = newCourseRes.data.course.id;
    console.log(`✅ [POST /api/courses] Курс создан: id=${courseId}, isPublished=${newCourseRes.data.course.isPublished}`);

    const taskRes = await request(
      {
        path: `/api/tasks/course/${courseId}`,
        method: 'POST',
        headers: { Authorization: `Bearer ${teacherToken}` },
      },
      {
        type: 'PLAY_PRACTICE',
        title: 'Сыграй ноту E2',
        expectedNote: 'E2',
        toleranceCents: 25,
      }
    );
    assert.strictEqual(taskRes.status, 201, 'Задание не создано');
    const taskId = taskRes.data.task.id;
    console.log(`✅ Задание добавлено: id=${taskId}`);

    const catalogRes = await request(
      {
        path: '/api/courses/catalog',
        method: 'GET',
        headers: { Authorization: `Bearer ${studentToken}` },
      }
    );
    assert.strictEqual(catalogRes.status, 200, 'Каталог не получен');
    const catalogCourse = catalogRes.data.courses.find((c) => c.id === courseId);
    assert(catalogCourse, 'Созданный курс отсутствует в каталоге');
    assert.strictEqual(catalogCourse.enrollmentStatus, 'NONE', 'Статус заявки должен быть NONE');
    console.log('✅ [GET /api/courses/catalog] Каталог получен, статус заявки: NONE');

    const enrollRes = await request(
      {
        path: `/api/courses/${courseId}/enroll`,
        method: 'POST',
        headers: { Authorization: `Bearer ${studentToken}` },
      }
    );
    assert.strictEqual(enrollRes.status, 201, 'Ошибка отправки заявки');
    assert.strictEqual(enrollRes.data.enrollment.status, 'PENDING');
    const enrollmentId = enrollRes.data.enrollment.id;
    console.log(`✅ [POST /api/courses/:id/enroll] Заявка создана: status=PENDING, enrollmentId=${enrollmentId}`);

    const catalogAfterEnroll = await request(
      {
        path: '/api/courses/catalog',
        method: 'GET',
        headers: { Authorization: `Bearer ${studentToken}` },
      }
    );
    const updatedCourseInCatalog = catalogAfterEnroll.data.courses.find((c) => c.id === courseId);
    assert.strictEqual(updatedCourseInCatalog.enrollmentStatus, 'PENDING', 'Статус в каталоге должен стать PENDING');
    console.log('✅ [GET /api/courses/catalog] Статус в каталоге успешно обновился на PENDING');

    const enrollmentsListRes = await request(
      {
        path: `/api/courses/${courseId}/enrollments`,
        method: 'GET',
        headers: { Authorization: `Bearer ${teacherToken}` },
      }
    );
    assert.strictEqual(enrollmentsListRes.status, 200, 'Заявки не получены учителем');
    const pendingEnr = enrollmentsListRes.data.enrollments.find((e) => e.id === enrollmentId);
    assert(pendingEnr, 'Заявка не найдена в списке учителя');
    console.log('✅ [GET /api/courses/:id/enrollments] Учитель видит поступившую заявку');

    const approveRes = await request(
      {
        path: `/api/courses/${courseId}/enrollments/${enrollmentId}`,
        method: 'PATCH',
        headers: { Authorization: `Bearer ${teacherToken}` },
      },
      { status: 'APPROVED' }
    );
    assert.strictEqual(approveRes.status, 200, 'Ошибка одобрения заявки');
    assert.strictEqual(approveRes.data.enrollment.status, 'APPROVED');
    console.log('✅ [PATCH /api/courses/:id/enrollments/:enrollmentId] Заявка успешно одобрена (status=APPROVED)');

    const myCoursesRes = await request(
      {
        path: '/api/courses/my-courses',
        method: 'GET',
        headers: { Authorization: `Bearer ${studentToken}` },
      }
    );
    assert.strictEqual(myCoursesRes.status, 200, 'Ошибка получения моих курсов');
    const myApprovedCourse = myCoursesRes.data.courses.find((c) => c.id === courseId);
    assert(myApprovedCourse, 'Одобренный курс не появился в my-courses');
    console.log('✅ [GET /api/courses/my-courses] Курс отображается в «Мое обучение»');

    const tasksRes = await request(
      {
        path: `/api/courses/${courseId}/tasks`,
        method: 'GET',
        headers: { Authorization: `Bearer ${studentToken}` },
      }
    );
    assert.strictEqual(tasksRes.status, 200, 'Ошибка доступа к заданиям курса');
    assert(tasksRes.data.tasks.length > 0, 'Задания курса не получены');
    console.log('✅ [GET /api/courses/:id/tasks] Задания курса успешно получены учеником');

    const submitRes = await request(
      {
        path: `/api/tasks/${taskId}/submit`,
        method: 'POST',
        headers: { Authorization: `Bearer ${studentToken}` },
      },
      {
        isCorrect: true,
        answer: 'E2',
        reactionMs: 420,
      }
    );
    assert.strictEqual(submitRes.status, 201, 'Ошибка отправки результата');
    assert.strictEqual(submitRes.data.taskResult.isCorrect, true);
    console.log('✅ [POST /api/tasks/:id/submit] Результат сохранен в TaskResult со статусом CORRECT');

    const addByEmailRes = await request(
      {
        path: `/api/courses/${courseId}/students`,
        method: 'POST',
        headers: { Authorization: `Bearer ${teacherToken}` },
      },
      { email: 'student2@guitar.app' }
    );
    assert.strictEqual(addByEmailRes.status, 201, 'Ошибка добавления студента по email');
    console.log('✅ [POST /api/courses/:id/students] Студент 2 успешно добавлен напрямую по email');

    const student1Id = studentLogin.data.user.id;
    const deleteStudentRes = await request(
      {
        path: `/api/courses/${courseId}/students/${student1Id}`,
        method: 'DELETE',
        headers: { Authorization: `Bearer ${teacherToken}` },
      }
    );
    assert.strictEqual(deleteStudentRes.status, 200, 'Ошибка исключения студента');
    console.log('✅ [DELETE /api/courses/:id/students/:studentId] Студент успешно исключен из курса');

    const tasksAfterDeleteRes = await request(
      {
        path: `/api/courses/${courseId}/tasks`,
        method: 'GET',
        headers: { Authorization: `Bearer ${studentToken}` },
      }
    );
    assert.strictEqual(tasksAfterDeleteRes.status, 403, 'После исключения доступ к заданиям должен возвращать 403');
    console.log('✅ [GET /api/courses/:id/tasks] Проверка безопасности: 403 Forbidden после исключения из курса');

    console.log('\n🎉 ВСЕ ТЕСТЫ УСПЕШНО ПРОЙДЕНЫ! АРХИТЕКТУРА И DSP ПОЛНОСТЬЮ ВАЛИДИРОВАНЫ.');
  } catch (err) {
    console.error('❌ ОШИБКА В ТЕСТАХ:', err);
    process.exit(1);
  }
}

runApiTests();
