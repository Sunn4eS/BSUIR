'use strict';

const pool = require('../config/db');
const { generateAccountNumber } = require('../utils/accountGenerator');
const ledger = require('../services/ledgerService');

const LIST_CONTRACTS_SQL = `
  SELECT
    dc.id,
    dc.contract_number,
    dc.term_months,
    dc.annual_rate,
    dc.currency,
    dc.start_date::text AS start_date,
    dc.maturity_date::text AS maturity_date,
    dc.amount,
    dc.status,
    dc.accrued_interest,
    dc.client_id,
    c.last_name,
    c.first_name,
    c.middle_name,
    dc.program_id,
    dp.name AS program_name,
    dp.deposit_type,
    dp.interest_payment,
    da.account_number AS deposit_account_number,
    da.status AS deposit_account_status,
    ia.account_number AS interest_account_number,
    ia.status AS interest_account_status
  FROM deposit_contracts dc
  JOIN clients c           ON c.id = dc.client_id
  JOIN deposit_programs dp ON dp.id = dc.program_id
  LEFT JOIN bank_accounts da ON da.id = dc.deposit_account_id
  LEFT JOIN bank_accounts ia ON ia.id = dc.interest_account_id
`;

function mapContract(row) {
  return {
    id: row.id,
    contract_number: row.contract_number,
    client_id: row.client_id,
    client_name: `${row.last_name} ${row.first_name} ${row.middle_name}`,
    program_id: row.program_id,
    program_name: row.program_name,
    deposit_type: row.deposit_type,
    interest_payment: row.interest_payment,
    term_months: row.term_months,
    annual_rate: Number(row.annual_rate),
    currency: row.currency,
    start_date: row.start_date,
    maturity_date: row.maturity_date,
    amount: Number(row.amount),
    status: row.status,
    accrued_interest: Number(row.accrued_interest),
    deposit_account_number: row.deposit_account_number,
    deposit_account_status: row.deposit_account_status,
    interest_account_number: row.interest_account_number,
    interest_account_status: row.interest_account_status,
  };
}

function mapAccount(row) {
  return {
    id: row.id,
    account_number: row.account_number,
    name: row.name,
    status: row.status,
    holder_type: row.holder_type,
    client_id: row.client_id,
    contract_id: row.contract_id,
  };
}

async function loadContract(db, contractId) {
  const { rows } = await db.query(`${LIST_CONTRACTS_SQL} WHERE dc.id = $1`, [contractId]);
  return rows.length > 0 ? mapContract(rows[0]) : null;
}

function handleDbError(err, res, next) {
  if (err.code === '23505') {
    const messages = {
      deposit_contracts_contract_number_key: 'Договор с таким номером уже существует',
    };
    return res.status(409).json({
      message: messages[err.constraint] || 'Нарушение уникальности данных',
    });
  }
  if (err.code === '23503') {
    return res.status(400).json({ message: 'Некорректная ссылка на клиента, программу или счёт' });
  }
  if (err.code === '22P02') {
    return res.status(400).json({ message: 'Некорректный формат переданных данных' });
  }
  return next(err);
}

/** Раскрытие accountId -> номер счёта в логах для UI (см. ledgerService) */
const decorateLogWithAccountNumbers = ledger.decorateEntriesWithAccounts;

/** GET /api/contracts — список депозитных договоров */
async function listContracts(req, res, next) {
  try {
    const { rows } = await pool.query(`${LIST_CONTRACTS_SQL} ORDER BY dc.id DESC`);
    res.json(rows.map(mapContract));
  } catch (err) {
    next(err);
  }
}

/**
 * POST /api/contracts — заключение депозитного договора.
 * В одной транзакции: создание двух счетов (депозитный + процентный),
 * заполнение журнала проводками открытия и обновление оборотов счетов.
 */
async function createContract(req, res, next) {
  const db = await pool.connect();
  try {
    await db.query('BEGIN');

    const b = req.body;

    // 1. Системные счета
    const cash = await ledger.getSystemAccount(db, '1010');
    const sfrb = await ledger.getSystemAccount(db, '7327');

    // 2. Уникальные 8-значные номера из последовательности БД
    const seqRes = await db.query("SELECT nextval('bank_account_seq') AS v");
    const seqStart = Number(seqRes.rows[0].v);

    // Депозитный счёт: 3414 (безотзывный) или 3404 (отзывный); процентный — 3474
    const depositCode = b.deposit_type === 'REVOCABLE' ? '3404' : '3414';
    const depositAccountNumber = generateAccountNumber(depositCode, seqStart);
    const interestAccountNumber = generateAccountNumber('3474', seqStart + 1);

    // 3. Дата окончания срока: start_date + term_months
    const maturityRes = await db.query(
      `SELECT (TO_DATE($1, 'YYYY-MM-DD') + (($2) || ' months')::interval)::date::text AS maturity_date`,
      [b.start_date, b.term_months]
    );
    const maturityDate = maturityRes.rows[0].maturity_date;

    // 4. Договор
    const contractRes = await db.query(
      `INSERT INTO deposit_contracts
         (contract_number, client_id, program_id, term_months, annual_rate, currency,
          start_date, maturity_date, amount, status, accrued_interest)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, 'ACTIVE', 0)
       RETURNING id`,
      [
        b.contract_number, b.client_id, b.program_id, b.term_months,
        b.annual_rate, b.currency, b.start_date, maturityDate, b.amount,
      ]
    );
    const contractId = Number(contractRes.rows[0].id);

    // 5. Счета клиента
    const clientName = `${b.client_last_name} ${b.client_first_name} ${b.client_middle_name}`;

    const depositAccRes = await db.query(
      `INSERT INTO bank_accounts
         (account_number, chart_account_id, holder_type, client_id, contract_id, name, status)
       VALUES ($1, (SELECT id FROM chart_of_accounts WHERE code = $2), 'CLIENT', $3, $4, $5, 'OPEN')
       RETURNING id`,
      [
        depositAccountNumber, depositCode, b.client_id, contractId,
        `Депозитный (текущий) счёт: ${clientName}, договор ${b.contract_number}`,
      ]
    );
    const depositAccountId = Number(depositAccRes.rows[0].id);

    const interestAccRes = await db.query(
      `INSERT INTO bank_accounts
         (account_number, chart_account_id, holder_type, client_id, contract_id, name, status)
       VALUES ($1, (SELECT id FROM chart_of_accounts WHERE code = '3474'), 'CLIENT', $2, $3, $4, 'OPEN')
       RETURNING id`,
      [
        interestAccountNumber, b.client_id, contractId,
        `Процентный счёт по договору ${b.contract_number}`,
      ]
    );
    const interestAccountId = Number(interestAccRes.rows[0].id);

    await db.query(
      'UPDATE deposit_contracts SET deposit_account_id = $1, interest_account_id = $2 WHERE id = $3',
      [depositAccountId, interestAccountId, contractId]
    );

    // 6. Проводки заключения договора (пример: сумма 1000 BYN)
    const amount = Number(b.amount);

    // 6.1 Внесение денег в кассу: Дебет 1010 (Касса) + A
    const payInEntry = await ledger.postEntry(db, {
      entryDate: b.start_date,
      contractId,
      kind: 'CONTRACT_OPEN_PAY_IN',
      comment: `Внесение денег в кассу по договору ${b.contract_number}`,
      lines: [{ accountId: cash.id, side: 'D', amount }],
    });

    // 6.2 Перевод денег из кассы на текущий счёт:
    //     Кредит 1010 (Касса) + A; Кредит Текущий счёт клиента + A
    const transferEntry = await ledger.postEntry(db, {
      entryDate: b.start_date,
      contractId,
      kind: 'CONTRACT_OPEN_TRANSFER',
      comment: `Перевод денег из кассы на текущий счёт по договору ${b.contract_number}`,
      lines: [
        { accountId: cash.id, side: 'C', amount },
        { accountId: depositAccountId, side: 'C', amount },
      ],
    });

    // 6.3 Использование денег банком (перечисление в СФРБ):
    //     Дебет Текущий счёт клиента + A; Кредит 7327 (СФРБ) + A
    const sfrbEntry = await ledger.postEntry(db, {
      entryDate: b.start_date,
      contractId,
      kind: 'CONTRACT_OPEN_SFRB',
      comment: `Использование денег банком (перечисление в СФРБ) по договору ${b.contract_number}`,
      lines: [
        { accountId: depositAccountId, side: 'D', amount },
        { accountId: sfrb.id, side: 'C', amount },
      ],
    });

    const log = await decorateLogWithAccountNumbers(db, [payInEntry, transferEntry, sfrbEntry]);

    await db.query('COMMIT');

    const contract = await loadContract(db, contractId);
    const accountsRes = await db.query(
      'SELECT id, account_number, name, status, holder_type, client_id, contract_id FROM bank_accounts WHERE id = ANY($1::int[])',
      [[depositAccountId, interestAccountId]]
    );

    res.status(201).json({
      contract,
      deposit_account: mapAccount(accountsRes.rows.find((r) => r.id === depositAccountId)),
      interest_account: mapAccount(accountsRes.rows.find((r) => r.id === interestAccountId)),
      log,
    });
  } catch (err) {
    await db.query('ROLLBACK');
    handleDbError(err, res, next);
  } finally {
    db.release();
  }
}

module.exports = {
  listContracts,
  createContract,
};