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
 *
 * Мультивалютность: клиентские счета ведутся в валюте договора, системные счета
 * (1010 Касса, 7327 СФРБ) — в BYN. В строке проводки хранятся обе величины:
 *   amount     — сумма в валюте счёта (currency);
 *   amount_byn — эквивалент в BYN по фиксированному курсу, нужен для сведения
 *                баланса и отображения конвертации в журнале проводок.
 * Обороты счёта (debit_turnover / credit_turnover) всегда увеличиваются в
 * родной валюте счёта, поэтому двойной учёт не смешивает разные валюты.
 */

const currency = require('../config/currency');

const SYSTEM_ACCOUNT_SQL = `
  SELECT ba.id, ba.account_number, ba.currency, ba.debit_turnover, ba.credit_turnover, coa.code
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
 * Валюты счетов-получателей сторон проводки (для конвертации в BYN).
 * @returns {Promise<Object<number, string>>} Map accountId -> currency
 */
async function loadAccountCurrencies(db, accountIds) {
  const currencies = {};
  if (accountIds.length === 0) return currencies;

  const { rows } = await db.query(
    'SELECT id, currency FROM bank_accounts WHERE id = ANY($1::int[])',
    [accountIds]
  );
  rows.forEach((row) => {
    currencies[Number(row.id)] = row.currency || currency.BASE_CURRENCY;
  });
  return currencies;
}

/**
 * Создание проводки и обновление оборотов счетов.
 *
 * Суммы строк (`amount`) передаются в валюте договора. Каждая строка приводится
 * к родной валюте своего счёта: если валюта счёта совпадает с валютой договора,
 * сумма не меняется, иначе выполняется конвертация по фиксированному курсу.
 * Эквивалент в BYN считается всегда и сохраняется в amount_byn.
 *
 * @param {object} db — клиент транзакции
 * @param {object} params
 * @param {string} params.entryDate — дата проводки (YYYY-MM-DD)
 * @param {number|null} params.contractId — депозитный договор (может отсутствовать)
 * @param {number|null} params.creditContractId — кредитный договор (может отсутствовать)
 * @param {string} params.kind — тип проводки
 * @param {string} params.comment — комментарий
 * @param {string} params.currency — валюта сумм в строках (по умолчанию BYN)
 * @param {Array<{accountId:number, side:'D'|'C', amount:number}>} params.lines — строки проводки
 */
async function postEntry(db, {
  entryDate, contractId, kind, comment, lines, creditContractId, currency: entryCurrency,
}) {
  const sourceCurrency = entryCurrency || currency.BASE_CURRENCY;

  const { rows } = await db.query(
    `INSERT INTO journal_entries (entry_date, contract_id, credit_contract_id, kind, comment)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING id`,
    [entryDate, contractId || null, creditContractId || null, kind, comment]
  );
  const entryId = Number(rows[0].id);
  const entry = { entryId, entryDate, kind, comment, currency: sourceCurrency, lines: [] };

  const accountCurrencies = await loadAccountCurrencies(
    db,
    [...new Set(lines.map((line) => Number(line.accountId)))]
  );

  for (const line of lines) {
    const accountCurrency = accountCurrencies[Number(line.accountId)] || currency.BASE_CURRENCY;
    // Сумма строки приводится к родной валюте счёта (для системных счетов — конвертация в BYN)
    const amount = currency.convert(Number(line.amount), sourceCurrency, accountCurrency);
    const amountByn = currency.toByn(amount, accountCurrency);

    await db.query(
      `INSERT INTO journal_entry_lines (entry_id, account_id, side, currency, amount, amount_byn)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [entryId, line.accountId, line.side, accountCurrency, amount, amountByn]
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

    entry.lines.push({
      accountId: line.accountId,
      side: line.side,
      amount,
      currency: accountCurrency,
      amountByn,
    });
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
      'SELECT id, account_number, name, currency FROM bank_accounts WHERE id = ANY($1::int[])',
      [[...ids]]
    );
    rows.forEach((row) => {
      accounts[row.id] = {
        accountNumber: row.account_number,
        name: row.name,
        currency: row.currency || currency.BASE_CURRENCY,
      };
    });
  }

  return entries.map((entry) => ({
    kind: entry.kind,
    entryDate: entry.entryDate,
    comment: entry.comment,
    currency: entry.currency || currency.BASE_CURRENCY,
    lines: entry.lines.map((line) => {
      const account = accounts[line.accountId] || {};
      const lineCurrency = line.currency
        || account.currency
        || currency.BASE_CURRENCY;
      const lineAmount = line.amount !== undefined ? line.amount : 0;
      return {
        accountId: line.accountId,
        accountNumber: account.accountNumber || null,
        accountName: account.name || null,
        side: line.side,
        amount: lineAmount,
        currency: lineCurrency,
        amountByn: line.amountByn !== undefined
          ? line.amountByn
          : currency.toByn(lineAmount, lineCurrency),
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
  currency,
};