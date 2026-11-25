CREATE EXTENSION IF NOT EXISTS "pgcrypto";

COMMENT ON TABLE users           IS 'Пользователи системы: учителя и студенты';
COMMENT ON TABLE teacher_students IS 'Связь учитель ↔ студент (многие ко многим)';
COMMENT ON TABLE courses         IS 'Курсы: наборы заданий, создаются учителями';
COMMENT ON TABLE tasks           IS 'Задания-карточки: EAR_TRAINING или PLAY_PRACTICE';
COMMENT ON TABLE student_courses IS 'Запись студента на курс с отслеживанием прогресса';
COMMENT ON TABLE task_results    IS 'Результаты выполнения заданий студентами';
COMMENT ON TABLE live_sessions   IS 'Real-time сессии учитель ↔ студент через WebSockets';
COMMENT ON TABLE live_task_cards IS 'Карточки-задания, отправленные в рамках live-сессии';
