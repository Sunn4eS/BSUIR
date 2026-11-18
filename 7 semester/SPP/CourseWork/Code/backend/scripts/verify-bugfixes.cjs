/**
 * scripts/verify-bugfixes.cjs — локальная проверка исправлений багов
 * 1) roles middleware: регистронезависимая проверка роли
 * 2) jwt.generateToken: role всегда в payload и в верхнем регистре
 * 3) createCourse: приём status 'draft'/'published' (мокну Prisma)
 * Запуск: node scripts/verify-bugfixes.cjs (из папки backend)
 */

const assert = require('assert');
const { generateToken } = require('../src/config/jwt');
const { requireTeacher, requireStudent } = require('../src/middleware/roles');

const results = [];
function check(name, fn) {
  try {
    fn();
    results.push(true);
    console.log(`PASS — ${name}`);
  } catch (err) {
    results.push(false);
    console.log(`FAIL — ${name}: ${err.message}`);
  }
}

// ── 1. Роли без учёта регистра ─────────────────────────────────
function makeReqResNext(role) {
  const req = { user: role === undefined ? null : { id: 'u1', role } };
  const calls = { next: null, status: null };
  const res = { status(code) { calls.status = code; return this; }, json() {} };
  const next = (err) => { calls.next = err || 'ok'; };
  return { req, res, next, calls };
}

check('requireTeacher пропускает "TEACHER"', () => {
  const { req, res, next, calls } = makeReqResNext('TEACHER');
  requireTeacher(req, res, next);
  assert.strictEqual(calls.next, 'ok');
});

check('requireTeacher пропускает "teacher" (нижний регистр)', () => {
  const { req, res, next, calls } = makeReqResNext('teacher');
  requireTeacher(req, res, next);
  assert.strictEqual(calls.next, 'ok');
});

check('requireTeacher пропускает " Teacher " (с пробелами)', () => {
  const { req, res, next, calls } = makeReqResNext(' Teacher ');
  requireTeacher(req, res, next);
  assert.strictEqual(calls.next, 'ok');
});

check('requireTeacher отклоняет студента (403)', () => {
  const { req, res, next, calls } = makeReqResNext('student');
  requireTeacher(req, res, next);
  assert.ok(calls.next instanceof Error);
  assert.strictEqual(calls.next.statusCode, 403);
  assert.strictEqual(calls.next.message, 'Разрешено только для учителя');
});

check('requireTeacher отклоняет без роли', () => {
  const { req, res, next, calls } = makeReqResNext(undefined);
  requireTeacher(req, res, next);
  assert.ok(calls.next instanceof Error);
  assert.strictEqual(calls.next.statusCode, 403);
});

check('requireStudent пропускает "student"', () => {
  const { req, res, next, calls } = makeReqResNext('student');
  requireStudent(req, res, next);
  assert.strictEqual(calls.next, 'ok');
});

// ── 2. JWT: role в payload ────────────────────────────────────
const jwt = require('jsonwebtoken');
const SECRET = process.env.JWT_SECRET || 'dev_secret_change_in_prod';

check('generateToken кладёт role в payload (верхний регистр)', () => {
  const token = generateToken({ id: 'u1', email: 't@x.com', role: 'teacher' });
  const decoded = jwt.verify(token, SECRET);
  assert.strictEqual(decoded.role, 'TEACHER');
  assert.strictEqual(decoded.id, 'u1');
  assert.strictEqual(decoded.email, 't@x.com');
});

check('generateToken бросает ошибку без role', () => {
  assert.throws(() => generateToken({ id: 'u1', email: 't@x.com' }), /роль/);
});

check('generateToken бросает ошибку с мусорной ролью', () => {
  assert.throws(() => generateToken({ id: 'u1', email: 't@x.com', role: 'admin' }), /роль/);
});

// ── 3. createCourse: приём status ─────────────────────────────
// Подменяем prisma-клиент моком до загрузки сервиса
const created = [];
const prismaStub = {
  course: {
    create: async ({ data }) => {
      created.push(data);
      return { id: 'c-' + created.length, ...data };
    },
  },
};

const databasePath = require.resolve('../src/config/database.js');
const originalLoad = require.cache[databasePath];
require.cache[databasePath] = {
  id: databasePath,
  filename: databasePath,
  loaded: true,
  exports: { prisma: prismaStub },
};

const coursesService = require('../src/modules/courses/courses.service.js');

(async () => {
  await (async () => {
    try {
      const c1 = await coursesService.createCourse('teacher-1', {
        title: 'Курс A',
        status: 'published',
      });
      assert.strictEqual(c1.status, 'PUBLISHED');
      assert.ok(c1.publishedAt instanceof Date);

      const c2 = await coursesService.createCourse('teacher-1', {
        title: 'Курс B',
        status: 'DRAFT',
      });
      assert.strictEqual(c2.status, 'DRAFT');
      assert.strictEqual(c2.publishedAt, undefined);

      const c3 = await coursesService.createCourse('teacher-1', { title: 'Курс C' });
      assert.strictEqual(c3.status, 'DRAFT');

      let threw = null;
      try {
        await coursesService.createCourse('teacher-1', { title: 'Курс D', status: 'bogus' });
      } catch (e) { threw = e; }
      assert.ok(threw && threw.statusCode === 400, 'невалидный status должен давать 400');

      assert.ok(created.every((d) => d.teacherId === 'teacher-1'), 'курс должен привязываться к teacherId');

      results.push(true, true, true, true, true);
      console.log('PASS — createCourse status=published -> PUBLISHED + publishedAt');
      console.log('PASS — createCourse status=DRAFT -> DRAFT');
      console.log('PASS — createCourse без status -> DRAFT (по умолчанию)');
      console.log('PASS — createCourse с мусорным status -> 400');
      console.log('PASS — createCourse привязывает teacherId=req.user.id');
    } catch (err) {
      results.push(false);
      console.log(`FAIL — createCourse: ${err.message}`);
    } finally {
      if (originalLoad) require.cache[databasePath] = originalLoad;
    }
  })();

  const failed = results.filter((r) => !r).length;
  console.log(`\n${results.length - failed}/${results.length} checks passed`);
  process.exit(failed ? 1 : 0);
})();
