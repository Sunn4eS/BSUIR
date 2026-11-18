-- =============================================================
-- Guitar Trainer — Начальные данные (seed)
-- Выполняется автоматически при первом запуске postgres контейнера
-- =============================================================

-- Этот файл только для проверки структуры и наполнения тестовыми данными.
-- В продакшне используй `npx prisma db seed`

-- Расширение для uuid_generate_v4() (Prisma использует gen_random_uuid())
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Комментарии к таблицам (документация прямо в БД)
COMMENT ON TABLE users           IS 'Пользователи системы: учителя и студенты';
COMMENT ON TABLE teacher_students IS 'Связь учитель ↔ студент (многие ко многим)';
COMMENT ON TABLE courses         IS 'Курсы: наборы заданий, создаются учителями';
COMMENT ON TABLE tasks           IS 'Задания-карточки: EAR_TRAINING или PLAY_PRACTICE';
COMMENT ON TABLE student_courses IS 'Запись студента на курс с отслеживанием прогресса';
COMMENT ON TABLE task_results    IS 'Результаты выполнения заданий студентами';
COMMENT ON TABLE live_sessions   IS 'Real-time сессии учитель ↔ студент через WebSockets';
COMMENT ON TABLE live_task_cards IS 'Карточки-задания, отправленные в рамках live-сессии';
