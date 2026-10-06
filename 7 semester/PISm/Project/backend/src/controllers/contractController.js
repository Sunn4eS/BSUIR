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
    da.currency AS deposit_account_currency,
    ia.account_number AS interest_account_number,
    ia.status AS interest_account_status,
    ia.currency AS interest_account_currency
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
    deposit_account_currency: row.deposit_account_currency || row.currency,
    interest_account_number: row.interest_account_number,
    interest_account_status: row.interest_account_status,
    interest_account_currency: row.interest_account_currency || row.currency,
  };
}

function mapAccount(row) {
  return {
    id: row.id,
    account_number: row.account_number,
    name: row.name,
    currency: row.currency || ledger.currency.BASE_CURRENCY,
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

    // 5. Счета клиента — в валюте договора
    const clientName = `${b.client_last_name} ${b.client_first_name} ${b.client_middle_name}`;

    const depositAccRes = await db.query(
      `INSERT INTO bank_accounts
         (account_number, chart_account_id, holder_type, client_id, contract_id, name, currency, status)
       VALUES ($1, (SELECT id FROM chart_of_accounts WHERE code = $2), 'CLIENT', $3, $4, $5, $6, 'OPEN')
       RETURNING id`,
      [
        depositAccountNumber, depositCode, b.client_id, contractId,
        `Депозитный (текущий) счёт: ${clientName}, договор ${b.contract_number}`,
        b.currency,
      ]
    );
    const depositAccountId = Number(depositAccRes.rows[0].id);

    const interestAccRes = await db.query(
      `INSERT INTO bank_accounts
         (account_number, chart_account_id, holder_type, client_id, contract_id, name, currency, status)
       VALUES ($1, (SELECT id FROM chart_of_accounts WHERE code = '3474'), 'CLIENT', $2, $3, $4, $5, 'OPEN')
       RETURNING id`,
      [
        interestAccountNumber, b.client_id, contractId,
        `Процентный счёт по договору ${b.contract_number}`,
        b.currency,
      ]
    );
    const interestAccountId = Number(interestAccRes.rows[0].id);

    await db.query(
      'UPDATE deposit_contracts SET deposit_account_id = $1, interest_account_id = $2 WHERE id = $3',
      [depositAccountId, interestAccountId, contractId]
    );

    // 6. Проводки заключения договора.
    // Сумма в валюте договора; postEntry сам приводит каждую сторону к родной
    // валюте счёта (клиентские — валюта договора, системные — BYN по курсу).
    const amount = Number(b.amount);
    const contractCurrency = b.currency;

    // 6.1 Внесение денег в кассу: Дебет 1010 (Касса) + A
    const payInEntry = await ledger.postEntry(db, {
      entryDate: b.start_date,
      contractId,
      kind: 'CONTRACT_OPEN_PAY_IN',
      comment: `Внесение денег в кассу по договору ${b.contract_number}`,
      currency: contractCurrency,
      lines: [{ accountId: cash.id, side: 'D', amount }],
    });

    // 6.2 Перевод денег из кассы на текущий счёт:
    //     Кредит 1010 (Касса) + A; Кредит Текущий счёт клиента + A
    const transferEntry = await ledger.postEntry(db, {
      entryDate: b.start_date,
      contractId,
      kind: 'CONTRACT_OPEN_TRANSFER',
      comment: `Перевод денег из кассы на текущий счёт по договору ${b.contract_number}`,
      currency: contractCurrency,
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
      currency: contractCurrency,
      lines: [
        { accountId: depositAccountId, side: 'D', amount },
        { accountId: sfrb.id, side: 'C', amount },
      ],
    });

    const log = await decorateLogWithAccountNumbers(db, [payInEntry, transferEntry, sfrbEntry]);

    await db.query('COMMIT');

    const contract = await loadContract(db, contractId);
    const accountsRes = await db.query(
      `SELECT id, account_number, name, currency, status, holder_type, client_id, contract_id
         FROM bank_accounts WHERE id = ANY($1::int[])`,
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

/**
 * DELETE /api/contracts/:id — удаление депозитного договора (Admin-режим).
 *
 * Порядок удаления обусловлен внешними ключами и выбран так, чтобы ничего не
 * потерять и не нарушить ссылки:
 *   1. строки проводок по счетам договора и по его проводкам;
 *   2. сторно оборотов на системных счетах (Касса, СФРБ) — иначе оборотная
 *      ведомость осталась бы с «призрачными» суммами удалённого договора;
 *   3. сами проводки договора;
 *   4. обнуление ссылок договора на счета (иначе счета нельзя удалить);
 *   5. удаление счетов договора;
 *   6. удаление самого договора.
 * Всё выполняется в одной транзакции: при ошибке ничего не удаляется.
 */
async function deleteContract(req, res, next) {
  const db = await pool.connect();
  try {
    await db.query('BEGIN');

    const id = Number(req.params.id);
    if (!Number.isInteger(id) || id <= 0) {
      await db.query('ROLLBACK');
      return res.status(400).json({ message: 'Некорректный идентификатор договора' });
    }

    const contractRes = await db.query(
      `SELECT id, contract_number, deposit_account_id, interest_account_id
         FROM deposit_contracts WHERE id = $1`,
      [id]
    );
    if (contractRes.rows.length === 0) {
      await db.query('ROLLBACK');
      return res.status(404).json({ message: 'Договор не найден' });
    }

    const contract = contractRes.rows[0];
    const accountIds = [contract.deposit_account_id, contract.interest_account_id]
      .filter((value) => value !== null && value !== undefined)
      .map(Number);

    // 1. Собираем удаляемые строки: понадобятся для сторно оборотов
    const linesRes = await db.query(
      `SELECT jel.account_id, jel.side, SUM(jel.amount) AS amount
         FROM journal_entry_lines jel
         JOIN journal_entries je ON je.id = jel.entry_id
        WHERE je.contract_id = $1 OR jel.account_id = ANY($2::int[])
        GROUP BY jel.account_id, jel.side`,
      [id, accountIds]
    );

    // 2. Сторно оборотов на счетах, которые сохраняются (системные 1010/7327).
    //    Счета самого договора удаляются ниже, их обороты сторноить не нужно.
    const surviving = linesRes.rows.filter((row) => !accountIds.includes(Number(row.account_id)));
    for (const line of surviving) {
      const column = line.side === 'D' ? 'debit_turnover' : 'credit_turnover';
      await db.query(
        `UPDATE bank_accounts
            SET ${column} = GREATEST(${column} - $1, 0)
          WHERE id = $2`,
        [line.amount, line.account_id]
      );
    }

    // 3. Строки проводок: и по счетам договора, и по его проводкам
    const deletedLines = await db.query(
      `DELETE FROM journal_entry_lines
        WHERE entry_id IN (SELECT id FROM journal_entries WHERE contract_id = $1)
           OR account_id = ANY($2::int[])`,
      [id, accountIds]
    );

    // 4. Проводки договора
    const entriesRes = await db.query(
      'DELETE FROM journal_entries WHERE contract_id = $1',
      [id]
    );

    // 5. Отвязываем договор от счетов, чтобы счета можно было удалить
    await db.query(
      'UPDATE deposit_contracts SET deposit_account_id = NULL, interest_account_id = NULL WHERE id = $1',
      [id]
    );

    // 6. Счета договора
    //    Параметры разведены: $1 — массив id счетов, $2 — id договора
    //    (один параметр нельзя использовать и как int[], и как integer).
    let accountsRemoved = 0;
    if (accountIds.length > 0) {
      const accRes = await db.query(
        'DELETE FROM bank_accounts WHERE id = ANY($1::int[]) OR contract_id = $2',
        [accountIds, id]
      );
      accountsRemoved = accRes.rowCount;
    } else {
      const accRes = await db.query('DELETE FROM bank_accounts WHERE contract_id = $1', [id]);
      accountsRemoved = accRes.rowCount;
    }

    // 7. Договор
    await db.query('DELETE FROM deposit_contracts WHERE id = $1', [id]);

    await db.query('COMMIT');

    return res.json({
      message: 'Договор удалён',
      contract_number: contract.contract_number,
      deleted_accounts: accountsRemoved,
      deleted_entries: entriesRes.rowCount,
      deleted_entry_lines: deletedLines.rowCount,
      reversed_lines: surviving.length,
    });
  } catch (err) {
    await db.query('ROLLBACK');
    if (err.code === '23503') {
      return res.status(409).json({
        message: 'Нельзя удалить договор: на него ссылаются другие записи банка',
      });
    }
    return handleDbError(err, res, next);
  } finally {
    db.release();
  }
}

module.exports = {
  listContracts,
  createContract,
  deleteContract,
};