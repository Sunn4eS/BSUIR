-- Карточки аппликатуры: 3 новых типа заданий + режим сборки на грифе

-- Новые значения enum TaskType (PostgreSQL 16 разрешает ADD VALUE в транзакции)
ALTER TYPE "TaskType" ADD VALUE 'FINGERING_TEST';
ALTER TYPE "TaskType" ADD VALUE 'PLAY_FINGERING';
ALTER TYPE "TaskType" ADD VALUE 'COMBO_FINGERING';

-- Режим карточки FINGERING_TEST: GUESS (выбор из вариантов) или BUILD (сборка)
ALTER TABLE "tasks" ADD COLUMN "fingering_mode" TEXT;
