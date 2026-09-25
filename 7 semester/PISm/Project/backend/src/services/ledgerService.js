'use strict';

/**
 * Сервис журнала проводок банка «Дабрабыт».
 * Все операции выполняются внутри переданной транзакции (client из pool.connect()).
 *
 * Проводка (по методике ЛР) — это запись в journal_entries с одной или
 * несколькими строками journal_entry_lines (сторона D/C и сумма). Каждая строка
 * атомарно увеличивает соответствующий оборот (дебит/кредит) банковского счёта.
 * Сальдо счёта вычисляется по типу из Плана счетов:
 *   A: Сальдо = Дебет - Кредит;  P: Сальдо = Кредит - Дебет.
 */

const SYSTEM_ACCOUNT_SQL = `
  SELECT ba.id, ba.account_number, ba.debit_turnover, ba.credit_turnover, coa.code
  FROM bank_accounts ba
  JOIN chart_of_accounts coa ON coa.id = ba.chart_account_id
  WHERE coa.code = $1 AND ba.status = 'OPEN'
  LIMIT 1
`;

async function getSystemAccount(db, chartCode) {
  const { rows } = await db.query(SYSTEM_ACCOUNT_SQL, [chartCode]);
  if (rows.length === 0) {
    throw new Error(`Системный счёт с кодом «${chartCode}» не найден`);
  }
  return rows[0];
}

/**
 * Создание проводки и обновление оборотов счетов.
 * @param {object} db — клиент транзакции
 * @param {object} params
 * @param {string} params.entryDate — дата проводки (YYYY-MM-DD)
 * @param {number|null} params.contractId — депозитный договор (может отсутствовать)
 * @param {number|null} params.creditContractId — кредитный договор (может отсутствовать)
 * @param {string} params.kind — тип проводки
 * @param {string} params.comment — комментарий
 * @param {Array<{accountId:number, side:'D'|'C', amount:number}>} params.lines — строки проводки
 */
async function postEntry(db, { entryDate, contractId, kind, comment, lines, creditContractId }) {
  const { rows } = await db.query(
    `INSERT INTO journal_entries (entry_date, contract_id, credit_contract_id, kind, comment)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING id`,
    [entryDate, contractId || null, creditContractId || null, kind, comment]
  );
  const entryId = Number(rows[0].id);
  const entry = { entryId, entryDate, kind, comment, lines: [] };

  for (const line of lines) {
    const amount = Number(line.amount);
    await db.query(
      `INSERT INTO journal_entry_lines (entry_id, account_id, side, amount)
       VALUES ($1, $2, $3, $4)`,
      [entryId, line.accountId, line.side, amount]
    );

    if (line.side === 'D') {
      await db.query(
        'UPDATE bank_accounts SET debit_turnover = debit_turnover + $1 WHERE id = $2',
        [amount, line.accountId]
      );
    } else {
      await db.query(
        'UPDATE bank_accounts SET credit_turnover = credit_turnover + $1 WHERE id = $2',
        [amount, line.accountId]
      );
    }

    entry.lines.push({ accountId: line.accountId, side: line.side, amount });
  }

  return entry;
}

/** Округление денежной суммы до 2 знаков (половинное округление вверх) */
function round2(value) {
  return Math.round((Number(value) + Number.EPSILON) * 100) / 100;
}

/**
 * Сумма процентов за месяц:
 * Сумма_процентов = Сумма_вклада * (Ставка / 100) / 12 (округление до 2 знаков)
 */
function monthlyInterest(amount, annualRate) {
  return round2(Number(amount) * (Number(annualRate) / 100) / 12);
}

/** Добавление номеров/названий счетов в строки проводок (для логов UI) */
async function decorateEntriesWithAccounts(db, entries) {
  const ids = new Set();
  entries.forEach((entry) => entry.lines.forEach((line) => ids.add(line.accountId)));

  const accounts = {};
  if (ids.size > 0) {
    const { rows } = await db.query(
      'SELECT id, account_number, name FROM bank_accounts WHERE id = ANY($1::int[])',
      [[...ids]]
    );
    rows.forEach((row) => {
      accounts[row.id] = { accountNumber: row.account_number, name: row.name };
    });
  }

  return entries.map((entry) => ({
    kind: entry.kind,
    entryDate: entry.entryDate,
    comment: entry.comment,
    lines: entry.lines.map((line) => {
      const account = accounts[line.accountId] || {};
      return {
        accountId: line.accountId,
        accountNumber: account.accountNumber || null,
        accountName: account.name || null,
        side: line.side,
        amount: line.amount,
      };
    }),
  }));
}

module.exports = {
  getSystemAccount,
  postEntry,
  round2,
  monthlyInterest,
  decorateEntriesWithAccounts,
};