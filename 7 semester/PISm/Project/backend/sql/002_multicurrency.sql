-- ---------------------------------------------------------------------------
-- Миграция 002: мультивалютность (ЛР2, доработка модуля 2)
--
-- init.sql выполняется только на пустом volume, поэтому изменения схемы
-- продублированы здесь в идемпотентном виде (ADD COLUMN IF NOT EXISTS).
-- Скрипм безопасен для повторного запуска.
--
-- 1. bank_accounts.currency — валюта счёта (клиентские — валюта договора,
--    системные 1010/7327 — строго BYN).
-- 2. journal_entry_lines.currency / amount_byn — валюта строки проводки и её
--    эквивалент в базовой валюте BYN для сведения баланса.
-- 3. deposit_contracts.currency — снимаем ограничение «только BYN».
-- ---------------------------------------------------------------------------

BEGIN;

-- 1. Валюта счёта -----------------------------------------------------------
ALTER TABLE bank_accounts
    ADD COLUMN IF NOT EXISTS currency CHAR(3) NOT NULL DEFAULT 'BYN';

ALTER TABLE bank_accounts DROP CONSTRAINT IF EXISTS bank_accounts_currency_check;
ALTER TABLE bank_accounts
    ADD CONSTRAINT bank_accounts_currency_check
    CHECK (currency IN ('BYN', 'USD', 'EUR', 'RUB'));

-- Системные счёта всегда в BYN (уже так по умолчанию, но фиксируем явно).
UPDATE bank_accounts SET currency = 'BYN' WHERE holder_type = 'SYSTEM';

-- 2. Мультивалютные строки проводок ----------------------------------------
ALTER TABLE journal_entry_lines
    ADD COLUMN IF NOT EXISTS currency CHAR(3) NOT NULL DEFAULT 'BYN';

ALTER TABLE journal_entry_lines
    ADD COLUMN IF NOT EXISTS amount_byn NUMERIC(18, 2) NOT NULL DEFAULT 0;

-- Для уже существующих строк эквивалент BYN равен сумме (все они были BYN).
UPDATE journal_entry_lines
   SET amount_byn = amount
 WHERE amount_byn = 0 AND amount <> 0;

-- 3. Валюта договора: BYN, USD, EUR, RUB -----------------------------------
ALTER TABLE deposit_contracts DROP CONSTRAINT IF EXISTS deposit_contracts_currency_check;
ALTER TABLE deposit_contracts
    ADD CONSTRAINT deposit_contracts_currency_check
    CHECK (currency IN ('BYN', 'USD', 'EUR', 'RUB'));

COMMIT;
