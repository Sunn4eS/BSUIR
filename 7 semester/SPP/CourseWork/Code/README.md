# 🎸 Guitar Trainer

Платформа для обучения игре на гитаре: курсы и задания-карточки, тренировка слуха, практика игры с тюнером и live-сессии между учителем и студентом в реальном времени.

## Стек

| Слой | Технологии |
|------|-----------|
| Frontend | React 18, Vite 5, React Router, Zustand, Axios, Socket.io-client |
| Backend | Node.js 20, Express 4, Prisma 5, Socket.io, JWT, bcrypt |
| База данных | PostgreSQL 16 |
| Инфраструктура | Docker Compose (dev / production-таргеты) |

## Структура проекта

```
GuitarTrainer/
├── backend/            # Express API + Socket.io + Prisma
│   ├── prisma/         # schema.prisma, миграции, seed.js
│   └── src/            # app.js, server.js, modules, sockets, middleware
├── frontend/           # React + Vite приложение
│   ├── src/            # pages, components, hooks, store, api
│   ├── vite.config.js
│   └── nginx.conf      # конфиг для production-сборки
├── database/init/      # SQL, выполняемый при первом старте Postgres
├── docker-compose.yml
├── .env.example        # шаблон переменных окружения
└── README.md
```

## Требования

- **Docker Desktop** (рекомендуемый способ) — либо
- **Node.js ≥ 20**, **npm** и **PostgreSQL 16** для локального запуска без Docker

---

## 🚀 Быстрый старт (Docker)

### 1. Создать `.env`

В корне проекта уже есть `.env`, но если его нет — скопируйте шаблон:

```bash
cp .env.example .env
```

При необходимости измените значения (порты, пароли, `JWT_SECRET`).

### 2. Запустить контейнеры

```bash
docker compose up --build -d
```

Поднимутся три сервиса:

| Сервис | Контейнер | Порт на хосте |
|--------|-----------|---------------|
| PostgreSQL | `guitar_trainer_db` | `5432` |
| Backend (Express) | `guitar_trainer_backend` | `4000` |
| Frontend (Vite) | `guitar_trainer_frontend` | `5173` |

Дождитесь, пока база пройдёт healthcheck, и проверьте логи:

```bash
docker compose logs -f backend
```

### 3. Применить схему БД и тестовые данные

Миграции **не применяются автоматически** при старте контейнера, поэтому выполните один раз:

```bash
docker compose exec backend npx prisma migrate deploy
docker compose exec backend npx prisma db seed
```

> `db seed` очищает таблицы и заново создаёт тестовые данные. Не запускайте на реальных данных.

### 4. Открыть приложение

- Frontend: **http://localhost:5173**
- Backend API: **http://localhost:4000/api**
- Health check: **http://localhost:4000/api/health**
- Prisma Studio (по желанию):
  ```bash
  docker compose exec backend npx prisma studio
  ```

### Остановка

```bash
docker compose down          # остановить контейнеры
docker compose down -v       # остановить и удалить данные БД
```

---

## 💻 Запуск без Docker (локальная разработка)

### 1. Запустить PostgreSQL

Проще всего поднять только базу из compose:

```bash
docker compose up -d postgres
```

Либо используйте локальный PostgreSQL и создайте БД `guitar_trainer` с пользователем `guitar_user` / паролем `guitar_secret`.

### 2. Backend

```bash
cd backend
npm install
```

Убедитесь, что в `backend/.env` указан корректный `DATABASE_URL`:

```env
DATABASE_URL=postgresql://guitar_user:guitar_secret@localhost:5432/guitar_trainer?schema=public
```

Затем сгенерируйте Prisma Client, примените миграции и запустите сервер:

```bash
npx prisma generate
npx prisma migrate deploy
npm run prisma:seed      # тестовые данные (опционально)
npm run dev              # nodemon, http://localhost:4000
```

### 3. Frontend

В отдельном терминале:

```bash
cd frontend
npm install
npm run dev              # http://localhost:5173
```

Frontend по умолчанию обращается к `http://localhost:4000` (см. `src/api/axios.js` и `src/hooks/useSocket.js`), поэтому дополнительные настройки не нужны. Если backend запущен на другом адресе — создайте `frontend/.env`:

```env
VITE_API_URL=http://localhost:4000
VITE_WS_URL=http://localhost:4000
```

---

## 🔧 Переменные окружения

Корневой `.env` используется **Docker Compose**. Backend читает `backend/.env` (при локальном запуске) — сейчас там только `DATABASE_URL`, остальные значения берутся из дефолтов в коде.

| Переменная | По умолчанию | Назначение |
|------------|--------------|-----------|
| `POSTGRES_USER` | `guitar_user` | Пользователь PostgreSQL |
| `POSTGRES_PASSWORD` | `guitar_secret` | Пароль PostgreSQL |
| `POSTGRES_DB` | `guitar_trainer` | Имя базы данных |
| `POSTGRES_PORT` | `5432` | Порт БД на хосте |
| `BACKEND_PORT` | `4000` | Порт backend на хосте |
| `FRONTEND_PORT` | `5173` | Порт frontend на хосте |
| `NODE_ENV` | `development` | Режим Node.js |
| `JWT_SECRET` | dev-значение | Секрет подписи JWT — **обязательно смените в production** |
| `JWT_EXPIRES_IN` | `7d` | Время жизни токена |
| `FRONTEND_URL` | `http://localhost:5173` | Разрешённый origin для CORS |
| `VITE_API_URL` | `http://localhost:4000` | Базовый URL API для frontend |
| `VITE_WS_URL` | `http://localhost:4000` | URL Socket.io-сервера |

---

## 👤 Тестовые аккаунты

Создаются командой `npm run prisma:seed`:

| Роль | Email | Пароль |
|------|-------|--------|
| Учитель | `teacher@guitar.app` | `password123` |
| Студент 1 | `student1@guitar.app` | `password123` |
| Студент 2 | `student2@guitar.app` | `password123` |

---

## 📜 Полезные команды

### Backend (`backend/`)

| Команда | Описание |
|---------|----------|
| `npm run dev` | Запуск с hot-reload (nodemon) |
| `npm start` | Запуск без hot-reload |
| `npm run prisma:generate` | Генерация Prisma Client |
| `npm run prisma:migrate` | Создать/применить миграцию (`migrate dev`) |
| `npm run prisma:studio` | Открыть Prisma Studio |
| `npm run prisma:seed` | Заполнить БД тестовыми данными |
| `npm run prisma:reset` | Полностью сбросить БД и применить миграции |

### Docker

| Команда | Описание |
|---------|----------|
| `docker compose up --build -d` | Собрать и запустить всё в фоне |
| `docker compose logs -f <service>` | Логи сервиса (`postgres` / `backend` / `frontend`) |
| `docker compose exec backend sh` | Войти в контейнер backend |
| `docker compose down -v` | Остановить и удалить volume с данными БД |

### Production-сборка

Образы содержат отдельные production-таргеты:

```bash
docker build --target production -t guitar-trainer-backend ./backend
docker build --target production -t guitar-trainer-frontend ./frontend
```

Frontend в production раздаётся через nginx (SPA fallback + прокси `/api` на backend).

---

## 🔌 API (кратко)

Все маршруты, кроме `/api/health` и `/api/auth/*`, требуют заголовок `Authorization: Bearer <token>`.

| Метод | Маршрут | Доступ |
|-------|---------|--------|
| `GET` | `/api/health` | публичный |
| `POST` | `/api/auth/register` | публичный |
| `POST` | `/api/auth/login` | публичный |
| `GET` | `/api/auth/me` | авторизованный |
| `GET/POST/DELETE` | `/api/users/students` | учитель |
| `GET` | `/api/users/dashboard` | студент |
| `GET/POST/PUT/DELETE` | `/api/courses` | учитель |
| `POST/DELETE` | `/api/courses/:id/enroll` | учитель |
| `GET` | `/api/tasks/templates` | учитель |
| `POST/PUT/DELETE` | `/api/tasks/...` | учитель |
| `POST` | `/api/tasks/:taskId/result` | студент |
| `GET` | `/api/tasks/results/course/:courseId` | студент |

WebSocket-события live-сессий обрабатываются Socket.io на том же порту (`4000`).

---

## 🩺 Возможные проблемы

**Порт занят (`5432`, `4000` или `5173`)**
Измените соответствующие переменные в `.env` (`POSTGRES_PORT`, `BACKEND_PORT`, `FRONTEND_PORT`) или остановите занявший порт процесс.

**Backend падает с ошибкой подключения к БД**
Проверьте, что PostgreSQL запущен и `DATABASE_URL` указывает на правильный хост. Внутри Docker хост — `postgres`, при локальном запуске — `localhost`.

**`Table does not exist` / пустые списки**
Не применены миграции. Выполните `npx prisma migrate deploy` (в контейнере — через `docker compose exec backend ...`).

**Ошибки `COMMENT ON TABLE ... does not exist` в логах Postgres при первом старте**
Это нормально: `database/init/01_comments.sql` выполняется до миграций Prisma. Таблицы создаёт Prisma, комментарии к ним не влияют на работу приложения.

**Frontend не видит API / ошибки CORS**
Убедитесь, что `FRONTEND_URL` совпадает с адресом, на котором открыт frontend, а `VITE_API_URL` указывает на доступный backend. После изменения `VITE_*` перезапустите dev-сервер.
