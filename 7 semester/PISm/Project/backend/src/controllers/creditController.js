'use strict';

const pool = require('../config/db');
const { generateAccountNumber } = require('../utils/accountGenerator');
const ledger = require('../services/ledgerService');
const { computeSchedule } = require('../services/creditSchedule');
const { issueCard } = require('../services/cardService');

const LIST_CREDIT_CONTRACTS_SQL = `
  SELECT
    cc.id,
    cc.contract_number,
    cc.term_months,
    cc.annual_rate,
    cc.currency,
    cc.start_date::text AS start_date,
    cc.maturity_date::text AS maturity_date,
    cc.amount,
    cc.status,
    cc.client_id,
    c.last_name,
    c.first_name,
    c.middle_name,
    cc.program_id,
    cp.name AS program_name,
    cp.repayment_type,
    ca.account_number AS credit_account_number,
    ca.status AS credit_account_status,
    ca.currency AS credit_account_currency,
    ia.account_number AS interest_account_number,
    ia.status AS interest_account_status,
    ia.currency AS interest_account_currency
  FROM credit_contracts cc
  JOIN clients c           ON c.id = cc.client_id
  JOIN credit_programs cp  ON cp.id = cc.program_id
  LEFT JOIN bank_accounts ca ON ca.id = cc.credit_account_id
  LEFT JOIN bank_accounts ia ON ia.id = cc.interest_account_id
`;

function mapContract(row) {
  const contract = {
    id: row.id,
    contract_number: row.contract_number,
    client_id: row.client_id,
    client_name: `${row.last_name} ${row.first_name} ${row.middle_name}`,
    program_id: row.program_id,
    program_name: row.program_name,
    repayment_type: row.repayment_type,
    term_months: row.term_months,
    annual_rate: Number(row.annual_rate),
    currency: row.currency,
    start_date: row.start_date,
    maturity_date: row.maturity_date,
    amount: Number(row.amount),
    status: row.status,
    credit_account_number: row.credit_account_number,
    credit_account_status: row.credit_account_status,
    // Счета договора открываются в валюте договора; если по счёту валюта
    // почему-то не проставлена, показываем валюту самого договора.
    credit_account_currency: (row.credit_account_currency || row.currency || '').trim(),
    interest_account_number: row.interest_account_number,
    interest_account_status: row.interest_account_status,
    interest_account_currency: (row.interest_account_currency || row.currency || '').trim(),
  };
  contract.schedule = computeSchedule({
    amount: contract.amount,
    annual_rate: contract.annual_rate,
    term_months: contract.term_months,
    repayment_type: contract.repayment_type,
    start_date: contract.start_date,
  });
  return contract;
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
    currency: (row.currency || '').trim(),
  };
}

async function loadContract(db, contractId) {
  const { rows } = await db.query(
    `${LIST_CREDIT_CONTRACTS_SQL} WHERE cc.id = $1`,
    [contractId]
  );
  return rows.length > 0 ? mapContract(rows[0]) : null;
}

function handleDbError(err, res, next) {
  if (err.code === '23505') {
    const messages = {
      credit_contracts_contract_number_key: 'Договор с таким номером уже существует',
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

/** GET /api/credit-contracts — список кредитных договоров с графиками погашения */
async function listCreditContracts(req, res, next) {
  try {
    const { rows } = await pool.query(`${LIST_CREDIT_CONTRACTS_SQL} ORDER BY cc.id DESC`);
    res.json(rows.map(mapContract));
  } catch (err) {
    next(err);
  }
}

/**
 * POST /api/credit-contracts — выдача кредита (заключение кредитного договора).
 * В одной транзакции: создание двух активных 13-значных счетов (2400 — основной
 * кредитный, 2470 — процентный), заполнение журнала проводками выдачи и
 * обновление оборотов счетов.
 */
async function createCreditContract(req, res, next) {
  const db = await pool.connect();
  try {
    await db.query('BEGIN');

    const b = req.body;
    const amount = Number(b.amount);

    // 1. Системные счета
    const cash = await ledger.getSystemAccount(db, '1010');
    const sfrb = await ledger.getSystemAccount(db, '7327');

    // 2. Уникальные 8-значные номера из последовательности БД
    const seqRes = await db.query("SELECT nextval('bank_account_seq') AS v");
    const seqStart = Number(seqRes.rows[0].v);

    // Кредитные счета: 2400 — основной, 2470 — процентный (EAN-13 mod 10)
    const creditAccountNumber = generateAccountNumber('2400', seqStart);
    const interestAccountNumber = generateAccountNumber('2470', seqStart + 1);

    // 3. Дата окончания срока: start_date + term_months
    const maturityRes = await db.query(
      `SELECT (TO_DATE($1, 'YYYY-MM-DD') + (($2) || ' months')::interval)::date::text AS maturity_date`,
      [b.start_date, b.term_months]
    );
    const maturityDate = maturityRes.rows[0].maturity_date;

    // 4. Кредитный договор
    const contractRes = await db.query(
      `INSERT INTO credit_contracts
         (contract_number, client_id, program_id, term_months, annual_rate, currency,
          start_date, maturity_date, amount, status)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, 'ACTIVE')
       RETURNING id`,
      [
        b.contract_number, b.client_id, b.program_id, b.term_months,
        b.annual_rate, b.currency, b.start_date, maturityDate, amount,
      ]
    );
    const contractId = Number(contractRes.rows[0].id);

    // 5. Счета клиента
    const clientName = `${b.client_last_name} ${b.client_first_name} ${b.client_middle_name}`;

    const creditAccRes = await db.query(
      `INSERT INTO bank_accounts
         (account_number, chart_account_id, holder_type, client_id, credit_contract_id, name, currency, status)
       VALUES ($1, (SELECT id FROM chart_of_accounts WHERE code = '2400'), 'CLIENT', $2, $3, $4, $5, 'OPEN')
       RETURNING id`,
      [
        creditAccountNumber, b.client_id, contractId,
        `Кредитный (основной) счёт: ${clientName}, договор ${b.contract_number}`,
        b.currency,
      ]
    );
    const creditAccountId = Number(creditAccRes.rows[0].id);

    const interestAccRes = await db.query(
      `INSERT INTO bank_accounts
         (account_number, chart_account_id, holder_type, client_id, credit_contract_id, name, currency, status)
       VALUES ($1, (SELECT id FROM chart_of_accounts WHERE code = '2470'), 'CLIENT', $2, $3, $4, $5, 'OPEN')
       RETURNING id`,
      [
        interestAccountNumber, b.client_id, contractId,
        `Процентный счёт по кредитному договору ${b.contract_number}`,
        b.currency,
      ]
    );
    const interestAccountId = Number(interestAccRes.rows[0].id);

    await db.query(
      'UPDATE credit_contracts SET credit_account_id = $1, interest_account_id = $2 WHERE id = $3',
      [creditAccountId, interestAccountId, contractId]
    );

    // 5.1 Эмиссия банковской карты (Модуль 4 «Эмулятор банкомата»):
    //     16 цифр (префикс 4916 + Луна), ПИН по умолчанию '1234'.
    //     Ссылка на активный кредитный счёт 2400 (account_id).
    const card = await issueCard(db, contractId, creditAccountId);

    // 6. Проводки выдачи кредита (классическая двойная запись)
    // 6.1 Выдача кредита клиенту из кассы:
    //     Дт 2400 (долг клиента вырос) / Кт 1010 (деньги ушли из кассы)
    const issueEntry = await ledger.postEntry(db, {
      entryDate: b.start_date,
      creditContractId: contractId,
      currency: b.currency,
      kind: 'CREDIT_ISSUE',
      comment: `Выдача кредита клиенту через кассу по договору ${b.contract_number}`,
      lines: [
        { accountId: creditAccountId, side: 'D', amount },
        { accountId: cash.id, side: 'C', amount },
      ],
    });

    // 6.2 Компенсация кассы из СФРБ (фонд финансирует выдачу):
    //     Дт 1010 (касса пополнилась) / Кт 7327 (ресурс фонда сформирован)
    const fundEntry = await ledger.postEntry(db, {
      entryDate: b.start_date,
      creditContractId: contractId,
      currency: b.currency,
      kind: 'CREDIT_FUNDING',
      comment: `Финансирование кредита из фонда развития банка (СФРБ), договор ${b.contract_number}`,
      lines: [
        { accountId: cash.id, side: 'D', amount },
        { accountId: sfrb.id, side: 'C', amount },
      ],
    });

    const log = await ledger.decorateEntriesWithAccounts(
      db,
      [issueEntry, fundEntry]
    );

    await db.query('COMMIT');

    const contract = await loadContract(db, contractId);
    const accountsRes = await db.query(
      'SELECT id, account_number, name, status, holder_type, client_id, contract_id, currency FROM bank_accounts WHERE id = ANY($1::int[])',
      [[creditAccountId, interestAccountId]]
    );

    res.status(201).json({
      contract,
      credit_account: mapAccount(accountsRes.rows.find((r) => r.id === creditAccountId)),
      interest_account: mapAccount(accountsRes.rows.find((r) => r.id === interestAccountId)),
      card: {
        id: card.id,
        card_number: card.card_number,
        pin_code: card.pin_code,
        is_blocked: card.is_blocked,
      },
      log,
    });
  } catch (err) {
    await db.query('ROLLBACK');
    handleDbError(err, res, next);
  } finally {
    db.release();
  }
}

// ============================================================================
// Удаление кредитного договора (роль администратора)
// ============================================================================
// Кредитный договор тянет за собой больше сущностей, чем депозитный:
//   * две карты банка (credit_cards) и операции по ним (atm_transactions);
//   * собственные проводки в journal_entries по credit_contract_id;
//   * два счёта договора, к которым в том числе привязаны карты.
//
// Порядок удаления подобран так, чтобы не упереться во внешние ключи:
// сначала atm_transactions (ссылается на journal_entries), затем карты
// (ссылаются на bank_accounts), потом строки и сами проводки, затем счета.
// Как и в deleteContract, обороты сохраняемых системных счетов сторноятся —
// иначе оборотная ведомость разошлась бы с журналом проводок.

/**
 * DELETE /api/credit-contracts/:id
 * Удаляет кредитный договор вместе с картами, операциями банкомата,
 * счетами и проводками.
 */
async function deleteCreditContract(req, res, next) {
  const db = await pool.connect();
  try {
    await db.query('BEGIN');

    const id = Number(req.params.id);
    if (!Number.isInteger(id) || id <= 0) {
      await db.query('ROLLBACK');
      return res.status(400).json({ message: 'Некорректный идентификатор договора' });
    }

    const contractRes = await db.query(
      `SELECT id, contract_number, credit_account_id, interest_account_id
         FROM credit_contracts WHERE id = $1`,
      [id]
    );
    if (contractRes.rows.length === 0) {
      await db.query('ROLLBACK');
      return res.status(404).json({ message: 'Кредитный договор не найден' });
    }

    const contract = contractRes.rows[0];
    const accountIds = [contract.credit_account_id, contract.interest_account_id]
      .filter((value) => value !== null && value !== undefined)
      .map(Number);

    // 1. Обороты к сторно: строки по проводкам договора и по его счетам
    const linesRes = await db.query(
      `SELECT jel.account_id, jel.side, SUM(jel.amount) AS amount
         FROM journal_entry_lines jel
         JOIN journal_entries je ON je.id = jel.entry_id
        WHERE je.credit_contract_id = $1 OR jel.account_id = ANY($2::int[])
        GROUP BY jel.account_id, jel.side`,
      [id, accountIds]
    );

    // 2. Сторно оборотов на счетах, которые сохраняются (системные 1010/7327).
    //    Счета самого договора удаляются ниже — их обороты не сторноим.
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

    // 3. Операции банкомата: они ссылаются на journal_entries, поэтому идут первыми
    const atmRes = await db.query(
      'DELETE FROM atm_transactions WHERE contract_id = $1 OR card_id IN (SELECT id FROM credit_cards WHERE contract_id = $1)',
      [id]
    );

    // 4. Карты договора (ссылаются на счета)
    const cardsRes = await db.query(
      'DELETE FROM credit_cards WHERE contract_id = $1 OR account_id = ANY($2::int[])',
      [id, accountIds]
    );

    // 5. Строки проводок: и по проводкам договора, и по его счетам
    const deletedLines = await db.query(
      `DELETE FROM journal_entry_lines
        WHERE entry_id IN (SELECT id FROM journal_entries WHERE credit_contract_id = $1)
           OR account_id = ANY($2::int[])`,
      [id, accountIds]
    );

    // 6. Проводки договора
    const entriesRes = await db.query(
      'DELETE FROM journal_entries WHERE credit_contract_id = $1',
      [id]
    );

    // 7. Отвязываем договор от счетов, чтобы счета можно было удалить
    await db.query(
      'UPDATE credit_contracts SET credit_account_id = NULL, interest_account_id = NULL WHERE id = $1',
      [id]
    );

    // 8. Счета договора. Параметры разведены: $1 — массив id, $2 — id договора
    //    (один параметр нельзя использовать и как int[], и как integer).
    let accountsRemoved = 0;
    if (accountIds.length > 0) {
      const accRes = await db.query(
        `DELETE FROM bank_accounts
          WHERE credit_contract_id = $2 OR id = ANY($1::int[])`,
        [accountIds, id]
      );
      accountsRemoved = accRes.rowCount;
    } else {
      const accRes = await db.query(
        'DELETE FROM bank_accounts WHERE credit_contract_id = $1',
        [id]
      );
      accountsRemoved = accRes.rowCount;
    }

    // 9. Договор
    await db.query('DELETE FROM credit_contracts WHERE id = $1', [id]);

    await db.query('COMMIT');

    return res.json({
      message: 'Кредитный договор удалён',
      contract_number: contract.contract_number,
      deleted_accounts: accountsRemoved,
      deleted_entries: entriesRes.rowCount,
      deleted_entry_lines: deletedLines.rowCount,
      deleted_cards: cardsRes.rowCount,
      deleted_atm_transactions: atmRes.rowCount,
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
  listCreditContracts,
  createCreditContract,
  deleteCreditContract,
};