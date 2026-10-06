-- ============================================================================
-- 003_credit_currency.sql — мультивалютность кредитных договоров (Модуль 3)
-- ============================================================================
-- Расширяет валюту кредитного договора до того же набора, что и у депозитного
-- (BYN / USD / EUR / RUB). Скрипт идемпотентный — его можно применять
-- повторно, в том числе к базе, где ограничение уже снято.
--
-- init.sql правится только на пустом volume, поэтому схема дублируется здесь:
-- на уже существующей базе именно этот скрипт снимает CHECK (currency = 'BYN').
--
-- Порядок колонок в journal_entry_lines и bank_accounts уже изменён в
-- 002_multicurrency.sql — здесь колонки не добавляются, только ограничение.
-- ============================================================================

BEGIN;

-- --- 1. Снимаем прежнее ограничение и ставим общий список валют ---------------
-- Имя ограничения по умолчанию Postgres для безымянного CHECK на колонке:
-- credit_contracts_currency_check. DROP ... IF EXISTS делает скрипт безопасным
-- и для базы, где ограничение ещё не было наложено вовсе.
ALTER TABLE credit_contracts DROP CONSTRAINT IF EXISTS credit_contracts_currency_check;

ALTER TABLE credit_contracts
    ADD CONSTRAINT credit_contracts_currency_check
    CHECK (currency IN ('BYN', 'USD', 'EUR', 'RUB'));

-- --- 2. Приводим существующие значения к каноническому виду ------------------
-- CHAR(3) в Postgres дополняет значения пробелами, поэтому приводим к TEXT
-- и обрезаем хвостовые пробелы. Типа не меняем — колонка остаётся CHAR(3).
UPDATE credit_contracts
   SET currency = BTRIM(currency::text)
 WHERE currency <> BTRIM(currency::text);

COMMIT;

-- ============================================================================
-- Проверка после применения:
--   SELECT conname, pg_get_constraintdef(oid)
--     FROM pg_constraint
--    WHERE conrelid = 'credit_contracts'::regclass
--      AND conname = 'credit_contracts_currency_check';
-- Ожидается: CHECK (currency = ANY (ARRAY['BYN'::bpchar, 'USD'::bpchar,
--                                              'EUR'::bpchar, 'RUB'::bpchar]))
-- ============================================================================