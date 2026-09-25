-- ============================================================================
-- Лабораторная работа №1. Вариант 3.
-- Модуль «Клиенты»: подсистема ввода и модификации данных о клиентах банка.
-- Создание таблиц-справочников, таблицы clients, ограничений целостности
-- и начальных данных (seed).
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Таблицы-справочники
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS cities (
    id   SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS marital_statuses (
    id   SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS citizenships (
    id   SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS disability_groups (
    id   SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

-- ---------------------------------------------------------------------------
-- 2. Заполнение справочников (seed)
-- ---------------------------------------------------------------------------

INSERT INTO cities (id, name) VALUES
    (1, 'Минск'),
    (2, 'Брест'),
    (3, 'Гродно'),
    (4, 'Витебск'),
    (5, 'Гомель'),
    (6, 'Могилев')
ON CONFLICT (id) DO NOTHING;

INSERT INTO marital_statuses (id, name) VALUES
    (1, 'Холост/Не замужем'),
    (2, 'Женат/Замужем'),
    (3, 'Разведен/-а'),
    (4, 'Вдовец/Вдова')
ON CONFLICT (id) DO NOTHING;

INSERT INTO citizenships (id, name) VALUES
    (1, 'Беларусь'),
    (2, 'Россия'),
    (3, 'Украина'),
    (4, 'Польша'),
    (5, 'Литва'),
    (6, 'Казахстан')
ON CONFLICT (id) DO NOTHING;

INSERT INTO disability_groups (id, name) VALUES
    (1, 'Нет'),
    (2, 'I группа'),
    (3, 'II группа'),
    (4, 'III группа')
ON CONFLICT (id) DO NOTHING;

-- переустановка последовательностей после вставки с явными id
SELECT setval(pg_get_serial_sequence('cities', 'id'), (SELECT MAX(id) FROM cities));
SELECT setval(pg_get_serial_sequence('marital_statuses', 'id'), (SELECT MAX(id) FROM marital_statuses));
SELECT setval(pg_get_serial_sequence('citizenships', 'id'), (SELECT MAX(id) FROM citizenships));
SELECT setval(pg_get_serial_sequence('disability_groups', 'id'), (SELECT MAX(id) FROM disability_groups));

-- ---------------------------------------------------------------------------
-- 3. Таблица clients со связями Foreign Key и ограничениями UNIQUE
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS clients (
    id                    SERIAL PRIMARY KEY,
    last_name             TEXT         NOT NULL,
    first_name            TEXT         NOT NULL,
    middle_name           TEXT         NOT NULL,
    birth_date            DATE         NOT NULL,
    passport_series       TEXT         NOT NULL,
    passport_number       TEXT         NOT NULL,
    issued_by             TEXT         NOT NULL,
    issue_date            DATE         NOT NULL,
    identification_number TEXT         NOT NULL,
    birth_place           TEXT         NOT NULL,
    city_id               INTEGER      NOT NULL REFERENCES cities (id),
    actual_address        TEXT         NOT NULL,
    home_phone            TEXT,
    mobile_phone          TEXT,
    email                 TEXT,
    marital_status_id     INTEGER      NOT NULL REFERENCES marital_statuses (id),
    citizenship_id        INTEGER      NOT NULL REFERENCES citizenships (id),
    disability_group_id   INTEGER      NOT NULL REFERENCES disability_groups (id),
    is_pensioner          BOOLEAN      NOT NULL DEFAULT FALSE,
    monthly_income        NUMERIC(14, 2),
    work_place            TEXT,
    position              TEXT,
    is_military_obligated BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at            TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT clients_identification_number_key UNIQUE (identification_number),
    CONSTRAINT clients_passport_series_passport_number_key UNIQUE (passport_series, passport_number),
    CONSTRAINT clients_full_name_birth_date_key UNIQUE (last_name, first_name, middle_name, birth_date)
);

-- ---------------------------------------------------------------------------
-- 4. Начальные данные: 5 клиентов с полным набором полей
-- ---------------------------------------------------------------------------

INSERT INTO clients (
    last_name, first_name, middle_name, birth_date,
    passport_series, passport_number, issued_by, issue_date,
    identification_number, birth_place, city_id, actual_address,
    home_phone, mobile_phone, email,
    marital_status_id, citizenship_id, disability_group_id,
    is_pensioner, monthly_income, work_place, position, is_military_obligated
) VALUES
    ('Иванов', 'Иван', 'Иванович', '1985-03-15',
     'AB', '1234567', 'Октябрьское РУВД г. Минска', '2010-04-12',
     '1503859A005PB4', 'г. Минск', 1, 'г. Минск, ул. Сурганова, д. 10, кв. 25',
     '+375 (17) 123-45-67', '+375 (29) 123-45-67', 'ivanov.ivan@gmail.com',
     2, 1, 1,
     FALSE, 1500.00, 'ОАО «Белоруснефть»', 'Инженер', TRUE),

    ('Петрова', 'Анна', 'Сергеевна', '1990-01-10',
     'BM', '2345678', 'Первомайское РУВД г. Минска', '2012-06-20',
     '1001903C007PB4', 'г. Брест', 2, 'г. Брест, ул. Московская, д. 5, кв. 12',
     NULL, '+375 (29) 234-56-78', 'petrova.anna@tut.by',
     1, 1, 1,
     FALSE, 1200.00, 'ОАО «Брестский мясокомбинат»', 'Бухгалтер', FALSE),

    ('Сидоров', 'Пётр', 'Андреевич', '1974-07-22',
     'HB', '3456789', 'Ленинское РУВД г. Гродно', '2005-03-11',
     '2207741B003PB4', 'г. Гродно', 3, 'г. Гродно, ул. Кирова, д. 15, кв. 3',
     '+375 (152) 34-56-78', '+375 (29) 345-67-89', 'sidorov.petr@mail.ru',
     2, 1, 3,
     FALSE, 850.00, 'Гродненский государственный университет', 'Преподаватель', TRUE),

    ('Ковалёва', 'Елена', 'Дмитриевна', '1995-06-05',
     'MP', '4567890', 'Центральное РУВД г. Витебска', '2015-09-15',
     '0506954D002PB4', 'г. Витебск', 4, 'г. Витебск, ул. Ленина, д. 42, кв. 8',
     NULL, '+375 (33) 456-78-90', 'kovaleva.elena@yandex.by',
     1, 1, 1,
     FALSE, 1100.00, 'ООО «Витебские традиции»', 'Менеджер', FALSE),

    ('Козлов', 'Николай', 'Викторович', '1980-12-30',
     'KH', '5678901', 'Советское РУВД г. Гомеля', '2008-02-14',
     '3012805E001PB4', 'г. Гомель', 5, 'г. Гомель, пр-т Победы, д. 100, кв. 17',
     '+375 (232) 67-89-01', '+375 (25) 567-89-01', 'kozlov.nikolay@tut.by',
     4, 2, 4,
     FALSE, 2000.00, 'ОАО «Гомсельмаш»', 'Мастер цеха', TRUE);

-- ============================================================================
-- МОДУЛЬ 2. ДЕПОЗИТНЫЕ ОПЕРАЦИИ С ФИЗИЧЕСКИМИ ЛИЦАМИ (банк «Дабрабыт»)
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 5. План счетов (chart_of_accounts)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS chart_of_accounts (
    id   SERIAL PRIMARY KEY,
    code CHAR(4)     NOT NULL UNIQUE,
    name TEXT        NOT NULL,
    type CHAR(1)     NOT NULL CHECK (type IN ('A', 'P')) -- A — активный, P — пассивный
);

INSERT INTO chart_of_accounts (id, code, name, type) VALUES
    (1, '1010', 'Касса банка', 'A'),
    (2, '7327', 'Счёт фонда развития банка (СФРБ)', 'P'),
    (3, '3014', 'Текущие (расчётные) счета физических лиц', 'P'),
    (4, '3414', 'Срочные безотзывные депозиты физических лиц', 'P'),
    (5, '3404', 'Депозиты физических лиц до востребования / отзывные', 'P'),
    (6, '3474', 'Процентные счета по депозитам физических лиц', 'P'),
    (7, '2400', 'Кредиты, предоставленные физическим лицам (текущий/основной кредитный счет)', 'A'),
    (8, '2470', 'Процентные счета по кредитам физических лиц', 'A')
ON CONFLICT (id) DO NOTHING;

SELECT setval(pg_get_serial_sequence('chart_of_accounts', 'id'), (SELECT MAX(id) FROM chart_of_accounts));

-- ---------------------------------------------------------------------------
-- 6. Счета (bank_accounts). Формулы сальдо:
--    A: Сальдо = Дебет - Кредит (>= 0)
--    P: Сальдо = Кредит - Дебет (>= 0)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS bank_accounts (
    id               SERIAL PRIMARY KEY,
    account_number   CHAR(13)     NOT NULL UNIQUE,
    chart_account_id INTEGER      NOT NULL REFERENCES chart_of_accounts (id),
    holder_type      VARCHAR(10)  NOT NULL DEFAULT 'SYSTEM' CHECK (holder_type IN ('SYSTEM', 'CLIENT')),
    client_id        INTEGER      REFERENCES clients (id),
    contract_id      INTEGER,
    name             TEXT         NOT NULL,
    status           VARCHAR(10)  NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'CLOSED')),
    debit_turnover   NUMERIC(18, 2) NOT NULL DEFAULT 0 CHECK (debit_turnover >= 0),
    credit_turnover  NUMERIC(18, 2) NOT NULL DEFAULT 0 CHECK (credit_turnover >= 0),
    created_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------------
-- 7. Депозитные программы банка «Дабрабыт»
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS deposit_programs (
    id               SERIAL PRIMARY KEY,
    name             TEXT        NOT NULL UNIQUE,
    deposit_type     VARCHAR(12) NOT NULL CHECK (deposit_type IN ('IRREVOCABLE', 'REVOCABLE')),
    interest_payment VARCHAR(12) NOT NULL CHECK (interest_payment IN ('AT_MATURITY', 'MONTHLY')),
    description      TEXT
);

CREATE TABLE IF NOT EXISTS deposit_program_terms (
    id          SERIAL PRIMARY KEY,
    program_id  INTEGER      NOT NULL REFERENCES deposit_programs (id),
    term_months INTEGER      NOT NULL CHECK (term_months > 0),
    annual_rate NUMERIC(6, 2) NOT NULL CHECK (annual_rate > 0 AND annual_rate < 100),
    UNIQUE (program_id, term_months)
);

INSERT INTO deposit_programs (id, name, deposit_type, interest_payment, description) VALUES
    (1, 'Шчодры', 'IRREVOCABLE', 'AT_MATURITY',
     'Срочный безотзывный вклад. Проценты выплачиваются только в конце срока вклада.'),
    (2, 'Основательный', 'REVOCABLE', 'MONTHLY',
     'Срочный отзывный вклад. Проценты выплачиваются ежемесячно.')
ON CONFLICT (id) DO NOTHING;

INSERT INTO deposit_program_terms (program_id, term_months, annual_rate) VALUES
    (1, 13, 12.60),
    (1, 18, 12.60),
    (1, 24, 12.60),
    (1, 37, 14.30),
    (2, 13, 6.00)
ON CONFLICT (program_id, term_months) DO NOTHING;

SELECT setval(pg_get_serial_sequence('deposit_programs', 'id'), (SELECT MAX(id) FROM deposit_programs));

-- ---------------------------------------------------------------------------
-- 8. Депозитные договоры
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS deposit_contracts (
    id                  SERIAL PRIMARY KEY,
    contract_number     TEXT          NOT NULL UNIQUE,
    client_id           INTEGER       NOT NULL REFERENCES clients (id),
    program_id          INTEGER       NOT NULL REFERENCES deposit_programs (id),
    term_months         INTEGER       NOT NULL CHECK (term_months > 0),
    annual_rate         NUMERIC(6, 2) NOT NULL CHECK (annual_rate > 0 AND annual_rate < 100),
    currency            CHAR(3)       NOT NULL DEFAULT 'BYN' CHECK (currency = 'BYN'),
    start_date          DATE          NOT NULL,
    maturity_date       DATE          NOT NULL,
    amount              NUMERIC(18, 2) NOT NULL CHECK (amount > 0),
    status              VARCHAR(12)   NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'COMPLETED')),
    accrued_interest    NUMERIC(18, 2) NOT NULL DEFAULT 0 CHECK (accrued_interest >= 0),
    deposit_account_id  INTEGER       REFERENCES bank_accounts (id),
    interest_account_id INTEGER       REFERENCES bank_accounts (id),
    created_at          TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    CHECK (maturity_date > start_date)
);

-- FK: contract_id в bank_accounts (добавляется после создания deposit_contracts)
ALTER TABLE bank_accounts DROP CONSTRAINT IF EXISTS bank_accounts_contract_id_fkey;
ALTER TABLE bank_accounts
    ADD CONSTRAINT bank_accounts_contract_id_fkey
    FOREIGN KEY (contract_id) REFERENCES deposit_contracts (id);

-- ---------------------------------------------------------------------------
-- 9. Журнал проводок (journal_entries + journal_entry_lines)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS journal_entries (
    id          SERIAL PRIMARY KEY,
    entry_date  DATE        NOT NULL,
    contract_id INTEGER     REFERENCES deposit_contracts (id),
    kind        VARCHAR(40) NOT NULL,
    comment     TEXT        NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS journal_entry_lines (
    id         SERIAL PRIMARY KEY,
    entry_id   INTEGER        NOT NULL REFERENCES journal_entries (id) ON DELETE CASCADE,
    account_id INTEGER        NOT NULL REFERENCES bank_accounts (id),
    side       CHAR(1)        NOT NULL CHECK (side IN ('D', 'C')),
    amount     NUMERIC(18, 2) NOT NULL CHECK (amount >= 0)
);

-- ---------------------------------------------------------------------------
-- 10. Банковская дата и системные счета (seed)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS bank_settings (
    key   TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

INSERT INTO bank_settings (key, value)
VALUES ('bank_date', TO_CHAR(DATE_TRUNC('month', CURRENT_DATE)::date, 'YYYY-MM-DD'))
ON CONFLICT (key) DO NOTHING;

-- Последовательность уникальных 8-значных номеров для клиентских счетов
CREATE SEQUENCE IF NOT EXISTS bank_account_seq START 1;

-- 1) Касса банка (1010, A): дебет = 0, кредит = 0, сальдо = 0.
--    Номер: 1010 + 00000001 + контрольный ключ EAN-13 (5) = 1010000000015
INSERT INTO bank_accounts (account_number, chart_account_id, holder_type, name, status, debit_turnover, credit_turnover)
VALUES ('1010000000015', 1, 'SYSTEM', 'Касса банка', 'OPEN', 0, 0);

-- 2) Счёт фонда развития банка (7327, P):
--    стартовое кредитовое сальдо = 100 000 000.00 BYN (дебет = 0, кредит = 100 000 000).
--    Номер: 7327 + 00000001 + контрольный ключ EAN-13 (8) = 7327000000018
INSERT INTO bank_accounts (account_number, chart_account_id, holder_type, name, status, debit_turnover, credit_turnover)
VALUES ('7327000000018', 2, 'SYSTEM', 'Счёт фонда развития банка (СФРБ)', 'OPEN', 0, 100000000.00);

-- Последовательность продолжается с номера 3 (системные счета заняли 1 и 2)
SELECT setval('bank_account_seq', 2);

-- ============================================================================
-- МОДУЛЬ 3. КРЕДИТНЫЕ ОПЕРАЦИИ С ФИЗИЧЕСКИМИ ЛИЦАМИ (банк «Дабрабыт»)
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 11. Кредитные программы
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS credit_programs (
    id             SERIAL PRIMARY KEY,
    name           TEXT         NOT NULL UNIQUE,
    repayment_type VARCHAR(24)  NOT NULL CHECK (repayment_type IN ('ANNUITY', 'PRINCIPAL_AT_MATURITY')),
    description    TEXT
);

CREATE TABLE IF NOT EXISTS credit_program_terms (
    id          SERIAL PRIMARY KEY,
    program_id  INTEGER        NOT NULL REFERENCES credit_programs (id),
    term_months INTEGER        NOT NULL CHECK (term_months > 0),
    annual_rate NUMERIC(6, 2)  NOT NULL CHECK (annual_rate > 0 AND annual_rate < 100),
    UNIQUE (program_id, term_months)
);

INSERT INTO credit_programs (id, name, repayment_type, description) VALUES
    (1, 'Кредит «На ЛИЧНОЕ»', 'ANNUITY',
     'Потребительский кредит. Аннуитетный ежемесячный платёж: часть основного долга + начисленные проценты.'),
    (2, 'Кредит «ПОД КЛЮЧ»', 'PRINCIPAL_AT_MATURITY',
     'Ежемесячно уплачиваются только начисленные проценты; основной долг погашается единоразово в последний месяц срока.')
ON CONFLICT (id) DO NOTHING;

-- «На ЛИЧНОЕ»: срок 13..60 месяцев, ставка 17.65% годовых
INSERT INTO credit_program_terms (program_id, term_months, annual_rate)
SELECT 1, m, 17.65 FROM generate_series(13, 60) AS m
ON CONFLICT (program_id, term_months) DO NOTHING;

-- «ПОД КЛЮЧ»: срок 12..240 месяцев, ставка 5.00% годовых
INSERT INTO credit_program_terms (program_id, term_months, annual_rate)
SELECT 2, m, 5.00 FROM generate_series(12, 240) AS m
ON CONFLICT (program_id, term_months) DO NOTHING;

SELECT setval(pg_get_serial_sequence('credit_programs', 'id'), (SELECT MAX(id) FROM credit_programs));

-- ---------------------------------------------------------------------------
-- 12. Кредитные договоры
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS credit_contracts (
    id                  SERIAL PRIMARY KEY,
    contract_number     TEXT           NOT NULL UNIQUE,
    client_id           INTEGER        NOT NULL REFERENCES clients (id),
    program_id          INTEGER        NOT NULL REFERENCES credit_programs (id),
    term_months         INTEGER        NOT NULL CHECK (term_months > 0),
    annual_rate         NUMERIC(6, 2)  NOT NULL CHECK (annual_rate > 0 AND annual_rate < 100),
    currency            CHAR(3)        NOT NULL DEFAULT 'BYN' CHECK (currency = 'BYN'),
    start_date          DATE           NOT NULL,
    maturity_date       DATE           NOT NULL,
    amount              NUMERIC(18, 2) NOT NULL CHECK (amount > 0),
    status              VARCHAR(12)    NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'CLOSED')),
    credit_account_id   INTEGER        REFERENCES bank_accounts (id),
    interest_account_id INTEGER        REFERENCES bank_accounts (id),
    created_at          TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    CHECK (maturity_date > start_date)
);

-- Связь кредитных счетов с договором (колонка credit_contract_id в bank_accounts)
ALTER TABLE bank_accounts ADD COLUMN IF NOT EXISTS credit_contract_id INTEGER;
ALTER TABLE bank_accounts DROP CONSTRAINT IF EXISTS bank_accounts_credit_contract_id_fkey;
ALTER TABLE bank_accounts
    ADD CONSTRAINT bank_accounts_credit_contract_id_fkey
    FOREIGN KEY (credit_contract_id) REFERENCES credit_contracts (id);

-- Журнал проводок: связь с кредитными договорами
ALTER TABLE journal_entries ADD COLUMN IF NOT EXISTS credit_contract_id INTEGER;
ALTER TABLE journal_entries DROP CONSTRAINT IF EXISTS journal_entries_credit_contract_id_fkey;
ALTER TABLE journal_entries
    ADD CONSTRAINT journal_entries_credit_contract_id_fkey
    FOREIGN KEY (credit_contract_id) REFERENCES credit_contracts (id);