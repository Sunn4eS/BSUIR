'use strict';

/**
 * Модуль 4 «Эмулятор банкомата (ATM)» — контроллер банкомата №001.
 * Изолированный API /api/atm: проверка карты, авторизация по ПИН (3 попытки,
 * блокировка), остаток кредитного счёта 2400, снятие наличных (Дт 2400 / Кт 1010),
 * оплата мобильной связи (Дт 2400 / Кт 7327) с формированием данных для чека.
 *
 * Сессии банкомата хранятся в памяти сервера (Map) с TTL 15 минут.
 */

const crypto = require('crypto');
const pool = require('../config/db');
const ledger = require('../services/ledgerService');

const ATM_ID = '001';
const SESSION_TTL_MS = 15 * 60 * 1000;
const MAX_PIN_ATTEMPTS = 3;
const OPERATORS = ['МТС', 'А1', 'Life'];

/** Хранилище сессий: sessionId -> { cardId, contractId, createdAt } */
const sessions = new Map();

// ---------------------------------------------------------------------------
// Утилиты
// ---------------------------------------------------------------------------

function fail(res, status, message) {
  return res.status(status).json({ message });
}

function formatDate(value) {
  if (!value) return '';
  const [y, m, d] = String(value).split('-');
  if (!y || !m || !d) return String(value);
  return `${d}.${m}.${y}`;
}

function maskCardNumber(cardNumber) {
  const last4 = String(cardNumber).slice(-4);
  return `**** **** **** ${last4}`;
}

function generateAuthCode() {
  return String(crypto.randomInt(0, 1000000)).padStart(6, '0');
}

function round2(value) {
  return Math.round((Number(value) + Number.EPSILON) * 100) / 100;
}

async function getBankDate(db) {
  const { rows } = await db.query("SELECT value FROM bank_settings WHERE key = 'bank_date'");
  return rows[0] ? rows[0].value : null;
}

/** Поиск карты вместе с договором и клиентом */
const CARD_WITH_CONTRACT_SQL = `
  SELECT
    c.id AS card_id,
    c.card_number,
    c.pin_code,
    c.pin_attempts,
    c.is_blocked,
    c.account_id,
    c.contract_id,
    cc.contract_number,
    cc.status  AS contract_status,
    cl.last_name, cl.first_name, cl.middle_name
  FROM credit_cards c
  JOIN credit_contracts cc ON cc.id = c.contract_id
  JOIN clients cl          ON cl.id = cc.client_id
`;

async function findCardByNumber(db, cardNumber) {
  const { rows } = await db.query(
    `${CARD_WITH_CONTRACT_SQL} WHERE c.card_number = $1`,
    [cardNumber]
  );
  return rows[0] || null;
}

async function findCardById(db, cardId) {
  const { rows } = await db.query(
    `${CARD_WITH_CONTRACT_SQL} WHERE c.id = $1`,
    [cardId]
  );
  return rows[0] || null;
}

function createSession(cardId, contractId) {
  const sessionId = crypto.randomBytes(16).toString('hex');
  sessions.set(sessionId, { cardId, contractId, createdAt: Date.now() });
  return sessionId;
}

function getSession(sessionId) {
  if (!sessionId) return null;
  const session = sessions.get(sessionId);
  if (!session) return null;
  if (Date.now() - session.createdAt > SESSION_TTL_MS) {
    sessions.delete(sessionId);
    return null;
  }
  return session;
}

/** Проверка обязательной сессии запроса */
function requireSession(req) {
  const session = getSession(req.body && req.body.session_id);
  if (!session) {
    const err = new Error('Сессия банкомата недействительна или истекла. Вставьте карту заново.');
    err.status = 401;
    throw err;
  }
  return session;
}

/**
 * Состояние кредитного счёта 2400 по карте:
 * лимит = сумма договора; задолженность = сальдо счёта 2400 (активный: Дт - Кт);
 * доступный остаток = лимит - задолженность.
 */
async function loadCardState(db, cardId) {
  const card = await findCardById(db, cardId);
  if (!card) {
    const err = new Error('Карта не найдена');
    err.status = 401;
    throw err;
  }
  if (card.is_blocked) {
    const err = new Error('Карта заблокирована. Обратитесь в банк');
    err.status = 403;
    throw err;
  }
  if (card.contract_status !== 'ACTIVE') {
    const err = new Error(`Кредитный договор ${card.contract_number} не является действующим (статус: ${card.contract_status})`);
    err.status = 400;
    throw err;
  }

  const accountRes = await db.query(
    `SELECT id, account_number, debit_turnover, credit_turnover, status
       FROM bank_accounts WHERE id = $1`,
    [card.account_id]
  );
  if (accountRes.rows.length === 0) {
    throw new Error('Кредитный счёт карты не найден');
  }
  const account = accountRes.rows[0];
  const debt = round2(Number(account.debit_turnover) - Number(account.credit_turnover));
  const contractRes = await db.query(
    'SELECT amount FROM credit_contracts WHERE id = $1',
    [card.contract_id]
  );
  const limit = round2(Number(contractRes.rows[0].amount));

  return {
    card_id: card.card_id,
    card_number: card.card_number,
    contract_number: card.contract_number,
    contract_status: card.contract_status,
    account_id: account.id,
    credit_limit: limit,
    current_debt: Math.max(0, debt),
    available_balance: round2(Math.max(0, limit - Math.max(0, debt))),
    account_number: account.account_number,
    account_status: account.status,
  };
}

/** Данные чека по шаблону банкомата №001 */
function composeReceipt(params) {
  const now = new Date();
  const time = [now.getHours(), now.getMinutes(), now.getSeconds()]
    .map((n) => String(n).padStart(2, '0'))
    .join(':');
  return {
    bank_name: 'ЗАО «Банк Дабрабыт»',
    atm_id: ATM_ID,
    datetime: `${formatDate(params.bankDate)} ${time}`,
    card: maskCardNumber(params.cardNumber),
    operation_number: params.transactionId,
    auth_code: params.authCode,
    operation_type: params.operationLabel,
    amount: params.amount,
    available_balance: params.available,
    status: 'УСПЕШНО',
    operator: params.operator || null,
    phone: params.phone || null,
  };
}

// ---------------------------------------------------------------------------
// GET /api/atm/cards — список карт (админка + быстрый выбор в банкомате)
// ---------------------------------------------------------------------------

async function listCards(req, res, next) {
  try {
    const { rows } = await pool.query(`
      SELECT
        c.id,
        c.card_number,
        c.pin_code,
        c.pin_attempts,
        c.is_blocked,
        c.contract_id,
        cc.contract_number,
        cc.status AS contract_status,
        cl.last_name, cl.first_name, cl.middle_name
      FROM credit_cards c
      JOIN credit_contracts cc ON cc.id = c.contract_id
      JOIN clients cl          ON cl.id = cc.client_id
      ORDER BY c.id ASC
    `);
    res.json(rows.map((row) => ({
      id: row.id,
      card_number: row.card_number,
      pin_code: row.pin_code,
      pin_attempts: Number(row.pin_attempts),
      is_blocked: row.is_blocked,
      contract_id: row.contract_id,
      contract_number: row.contract_number,
      contract_status: row.contract_status,
      client_name: `${row.last_name} ${row.first_name} ${row.middle_name}`,
    })));
  } catch (err) {
    next(err);
  }
}

// ---------------------------------------------------------------------------
// POST /api/atm/card-check — проверка наличия карты и статуса блокировки
// ---------------------------------------------------------------------------

async function cardCheck(req, res, next) {
  try {
    const cardNumber = String((req.body && req.body.card_number) || '').replace(/\s+/g, '');
    if (!/^\d{16}$/.test(cardNumber)) {
      return fail(res, 400, 'Введите корректный номер карты (16 цифр)');
    }

    const db = await pool.connect();
    try {
      const card = await findCardByNumber(db, cardNumber);
      if (!card) return fail(res, 404, 'Карта не найдена. Проверьте номер карты');

      res.json({
        card_number: maskCardNumber(card.card_number),
        last4: card.card_number.slice(-4),
        is_blocked: card.is_blocked,
        pin_attempts: Number(card.pin_attempts),
        contract_number: card.contract_number,
        contract_status: card.contract_status,
        client_name: `${card.last_name} ${card.first_name} ${card.middle_name}`,
      });
    } finally {
      db.release();
    }
  } catch (err) {
    next(err);
  }
}

// ---------------------------------------------------------------------------
// POST /api/atm/authorize — проверка ПИН, 3 попытки, блокировка карты
// ---------------------------------------------------------------------------

async function authorize(req, res, next) {
  try {
    const cardNumber = String((req.body && req.body.card_number) || '').replace(/\s+/g, '');
    const pin = String((req.body && req.body.pin) || '').replace(/\s+/g, '');

    if (!/^\d{16}$/.test(cardNumber)) return fail(res, 400, 'Введите корректный номер карты (16 цифр)');
    if (!/^\d{4}$/.test(pin)) return fail(res, 400, 'ПИН-код состоит из 4 цифр');

    const db = await pool.connect();
    try {
      const card = await findCardByNumber(db, cardNumber);
      if (!card) return fail(res, 404, 'Карта не найдена. Проверьте номер карты');
      if (card.is_blocked) return fail(res, 423, 'Карта заблокирована. Обратитесь в банк');

      if (card.contract_status !== 'ACTIVE') {
        return fail(res, 400, `Кредитный договор ${card.contract_number} не является действующим (статус: ${card.contract_status})`);
      }

      if (card.pin_code !== pin) {
        const attempts = Number(card.pin_attempts) + 1;
        if (attempts >= MAX_PIN_ATTEMPTS) {
          await db.query(
            'UPDATE credit_cards SET pin_attempts = $1, is_blocked = TRUE WHERE id = $2',
            [attempts, card.card_id]
          );
          return fail(res, 423, 'Карта заблокирована. Обратитесь в банк');
        }
        await db.query(
          'UPDATE credit_cards SET pin_attempts = $1 WHERE id = $2',
          [attempts, card.card_id]
        );
        return fail(res, 401, `Неверный ПИН-код. Осталось попыток: ${MAX_PIN_ATTEMPTS - attempts}`);
      }

      // Успех: сбрасываем счётчик попыток, создаём сессию
      await db.query(
        'UPDATE credit_cards SET pin_attempts = 0 WHERE id = $1',
        [card.card_id]
      );

      const sessionId = createSession(card.card_id, card.contract_id);
      res.json({
        session_id: sessionId,
        card_number: maskCardNumber(card.card_number),
        last4: card.card_number.slice(-4),
        client_name: `${card.last_name} ${card.first_name} ${card.middle_name}`,
        contract_number: card.contract_number,
      });
    } finally {
      db.release();
    }
  } catch (err) {
    next(err);
  }
}

// ---------------------------------------------------------------------------
// POST /api/atm/balance — остаток кредитного счёта 2400
// ---------------------------------------------------------------------------

async function balance(req, res, next) {
  try {
    const session = requireSession(req);
    const db = await pool.connect();
    try {
      const state = await loadCardState(db, session.cardId);
      const bankDate = await getBankDate(db);
      res.json({
        ...state,
        last4: state.card_number.slice(-4),
        bank_date: bankDate,
      });
    } finally {
      db.release();
    }
  } catch (err) {
    next(err);
  }
}

// ---------------------------------------------------------------------------
// Общая логика проводок WITHDRAW / PAYMENT: транзакция, чек, обновление остатка
// ---------------------------------------------------------------------------

async function runAtmTransaction(req, res, next, { operationType, operationLabel, comment, operator, phone, linesFor }) {
  const session = requireSession(req);

  const db = await pool.connect();
  try {
    await db.query('BEGIN');

    const bankDate = await getBankDate(db);
    const state = await loadCardState(db, session.cardId);
    const amount = round2(req.body && req.body.amount);

    if (!(amount > 0)) {
      await db.query('ROLLBACK');
      return fail(res, 400, 'Укажите корректную сумму операции');
    }

    if (round2(amount - state.available_balance) > 0) {
      await db.query('ROLLBACK');
      return fail(
        res,
        400,
        `Недостаточно средств на кредитном счёте. Доступно: ${state.available_balance.toFixed(2)} BYN`
      );
    }

    // Банковская проводка внутри транзакции (BEGIN ... COMMIT)
    const lines = await linesFor(db, state, amount);
    const entry = await ledger.postEntry(db, {
      entryDate: bankDate,
      creditContractId: session.contractId,
      kind: operationType === 'WITHDRAW' ? 'ATM_WITHDRAW' : 'ATM_PAYMENT',
      comment,
      lines,
    });

    // Запись операции банкомата для чека и аудита
    const authCode = generateAuthCode();
    const txRes = await db.query(
      `INSERT INTO atm_transactions
         (card_id, contract_id, operation_type, amount, operator, phone_number, auth_code, entry_id)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING id`,
      [
        session.cardId, session.contractId, operationType, amount,
        operator || null, phone || null, authCode, entry.id,
      ]
    );
    const transactionId = Number(txRes.rows[0].id);

    // Актуальное состояние счёта после проводки
    const newState = await loadCardState(db, session.cardId);

    await db.query('COMMIT');

    const receipt = composeReceipt({
      bankDate,
      transactionId,
      authCode,
      operationLabel,
      cardNumber: newState.card_number,
      amount,
      available: newState.available_balance,
      operator,
      phone,
    });

    res.json({
      receipt,
      available_balance: newState.available_balance,
      current_debt: newState.current_debt,
      credit_limit: newState.credit_limit,
    });
  } catch (err) {
    await db.query('ROLLBACK');
    next(err);
  } finally {
    db.release();
  }
}

// ---------------------------------------------------------------------------
// POST /api/atm/withdraw — снятие наличных:
//   Дт 2400 (кредитный счёт клиента) + сумма; Кт 1010 (касса/банкомат) + сумма
// ---------------------------------------------------------------------------

async function withdraw(req, res, next) {
  try {
    const amount = Number((req.body && req.body.amount) || NaN);
    if (!Number.isInteger(amount) || amount <= 0) {
      return fail(res, 400, 'Сумма снятия должна быть целым положительным числом');
    }

    const session = requireSession(req);
    const card = await findCardById(pool, session.cardId);
    if (!card) return fail(res, 401, 'Сессия банкомата недействительна');

    return runAtmTransaction(req, res, next, {
      operationType: 'WITHDRAW',
      operationLabel: 'Снятие наличных',
      comment: `Снятие наличных через банкомат №${ATM_ID}, карта ${maskCardNumber(card.card_number)}, сумма ${amount.toFixed(2)} BYN`,
      operator: null,
      phone: null,
      linesFor: async (db, state, amt) => {
        const cash = await ledger.getSystemAccount(db, '1010');
        return [
          { accountId: state.account_id, side: 'D', amount: amt }, // долг клиента растёт
          { accountId: cash.id, side: 'C', amount: amt },          // выданы наличные
        ];
      },
    });
  } catch (err) {
    next(err);
  }
}

// ---------------------------------------------------------------------------
// POST /api/atm/payment — оплата мобильной связи:
//   оператор (А1, МТС, Life), номер телефона (10 цифр), сумма.
//   Дт 2400 + сумма; Кт 7327 (СФРБ) + сумма.
// ---------------------------------------------------------------------------

async function payment(req, res, next) {
  try {
    const body = req.body || {};
    const operator = String(body.operator || '').trim();
    const phone = String(body.phone || '').replace(/\s+/g, '');
    const amount = round2(Number(body.amount));

    if (!OPERATORS.includes(operator)) {
      return fail(res, 400, `Выберите оператора: ${OPERATORS.join(', ')}`);
    }
    if (!/^\d{10}$/.test(phone)) {
      return fail(res, 400, 'Номер телефона должен состоять из 10 цифр');
    }
    if (!(amount > 0)) {
      return fail(res, 400, 'Укажите корректную сумму оплаты');
    }

    const session = requireSession(req);
    const card = await findCardById(pool, session.cardId);
    if (!card) return fail(res, 401, 'Сессия банкомата недействительна');

    return runAtmTransaction(req, res, next, {
      operationType: 'PAYMENT',
      operationLabel: 'Оплата услуг (мобильная связь)',
      comment: `Оплата мобильной связи ${operator}, номер ${phone}, через банкомат №${ATM_ID}, карта ${maskCardNumber(card.card_number)}`,
      operator,
      phone,
      linesFor: async (db, state, amt) => {
        const sfrb = await ledger.getSystemAccount(db, '7327');
        return [
          { accountId: state.account_id, side: 'D', amount: amt }, // списание с кредитного счёта
          { accountId: sfrb.id, side: 'C', amount: amt },          // в пользу банка/СФРБ
        ];
      },
    });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  listCards,
  cardCheck,
  authorize,
  balance,
  withdraw,
  payment,
};