'use strict';

const pool = require('../config/db');
const ledger = require('../services/ledgerService');
const { computeSchedule, monthsBetween } = require('../services/creditSchedule');

/** GET /api/bank — текущее состояние банка (банковская дата) */
async function getBankState(req, res, next) {
  try {
    const { rows } = await pool.query(
      "SELECT value FROM bank_settings WHERE key = 'bank_date'"
    );
    res.json({ bank_date: rows[0] ? rows[0].value : null });
  } catch (err) {
    next(err);
  }
}

/**
 * POST /api/bank/close-month — «Закрыть Банковский Месяц».
 *
 * 1. По каждому активному договору (start_date <= закрываемая банковская дата):
 *    - начисляются проценты за месяц: Дт 7327 (СФРБ), Кт Процентный счёт клиента;
 *    - если вклад отзывный — проценты выплачиваются ежемесячно через кассу;
 *    - если наступил срок окончания — безотзывному вкладу выплачиваются все
 *      накопленные проценты, возвращается основной депозит, договор -> COMPLETED,
 *      счета -> CLOSED.
 * 2. Банковская дата переходит на 1 месяц вперёд.
 * Все операции выполняются в одной транзакции PostgreSQL.
 */
async function closeMonth(req, res, next) {
  const db = await pool.connect();
  const log = [];

  try {
    await db.query('BEGIN');

    const bankDateRes = await db.query("SELECT value FROM bank_settings WHERE key = 'bank_date'");
    const bankDate = bankDateRes.rows[0].value;

    const cash = await ledger.getSystemAccount(db, '1010');
    const sfrb = await ledger.getSystemAccount(db, '7327');

    const contractsRes = await db.query(
      `SELECT
         dc.id,
         dc.contract_number,
         dc.amount,
         dc.annual_rate,
         dc.accrued_interest,
         dc.deposit_account_id,
         dc.interest_account_id,
         dc.maturity_date::text AS maturity_date,
         c.last_name, c.first_name, c.middle_name,
         dp.name AS program_name, dp.interest_payment
       FROM deposit_contracts dc
       JOIN clients c           ON c.id = dc.client_id
       JOIN deposit_programs dp ON dp.id = dc.program_id
      WHERE dc.status = 'ACTIVE' AND dc.start_date <= $1
      ORDER BY dc.id`,
      [bankDate]
    );

    for (const contract of contractsRes.rows) {
      const contractId = Number(contract.id);
      const amount = Number(contract.amount);
      const monthly = ledger.monthlyInterest(amount, contract.annual_rate);
      const clientName = `${contract.last_name} ${contract.first_name} ${contract.middle_name}`;

      const contractLog = {
        contractId,
        contract_number: contract.contract_number,
        client_name: clientName,
        program_name: contract.program_name,
        amount,
        monthly_interest: monthly,
        status: 'ACTIVE',
        entries: [],
      };

      // --- Наступило ли окончание срока договора на закрываемую дату ---
      const matures = String(contract.maturity_date) <= String(bankDate);

      // --- 2. Начисление процентов за месяц (для всех программ) ---
      // Начисление выполняется за полные месяцы действия договора;
      // в месяце окончания срока договор завершается без дополнительного начисления.
      let accrued = Number(contract.accrued_interest);

      if (monthly > 0 && !matures) {
        const accrualEntry = await ledger.postEntry(db, {
          entryDate: bankDate,
          contractId,
          kind: 'INTEREST_ACCRUAL',
          comment: `Начисление процентов за месяц ${bankDate} по договору ${contract.contract_number}`,
          lines: [
            { accountId: sfrb.id, side: 'D', amount: monthly },
            { accountId: contract.interest_account_id, side: 'C', amount: monthly },
          ],
        });
        contractLog.entries.push(accrualEntry);
        accrued += monthly;

        // --- 3. Отзывный вклад: выплата процентов каждый месяц через кассу ---
        if (contract.interest_payment === 'MONTHLY') {
          // Перевод процентов в кассу: Дт Процентный счёт, Кт 1010 (Касса)
          const payEntry = await ledger.postEntry(db, {
            entryDate: bankDate,
            contractId,
            kind: 'INTEREST_PAYMENT',
            comment: `Выплата процентов по отзывному вкладу ${contract.contract_number} (перевод в кассу)`,
            lines: [
              { accountId: contract.interest_account_id, side: 'D', amount: monthly },
              { accountId: cash.id, side: 'C', amount: monthly },
            ],
          });
          // Поступление процентов в кассу для выдачи клиенту (транзит: Дебет 1010)
          const cashInEntry = await ledger.postEntry(db, {
            entryDate: bankDate,
            contractId,
            kind: 'INTEREST_CASH_IN',
            comment: `Поступление процентов в кассу для выдачи клиенту (договор ${contract.contract_number})`,
            lines: [
              { accountId: cash.id, side: 'D', amount: monthly },
            ],
          });
          contractLog.entries.push(payEntry, cashInEntry);
          accrued = 0;
        }
      }

      // --- 4. Окончание срока договора ---
      if (matures) {
        // 4.1 Безотзывный вклад: выплата всех накопленных процентов сейчас
        if (contract.interest_payment === 'AT_MATURITY' && accrued > 0) {
          const finalPayEntry = await ledger.postEntry(db, {
            entryDate: bankDate,
            contractId,
            kind: 'INTEREST_FINAL_PAYMENT',
            comment: `Выплата процентов за весь срок по безотзывному вкладу ${contract.contract_number} (перевод в кассу)`,
            lines: [
              { accountId: contract.interest_account_id, side: 'D', amount: accrued },
              { accountId: cash.id, side: 'C', amount: accrued },
            ],
          });
          const finalCashInEntry = await ledger.postEntry(db, {
            entryDate: bankDate,
            contractId,
            kind: 'INTEREST_FINAL_CASH_IN',
            comment: `Поступление процентов в кассу для выдачи клиенту (договор ${contract.contract_number})`,
            lines: [
              { accountId: cash.id, side: 'D', amount: accrued },
            ],
          });
          contractLog.entries.push(finalPayEntry, finalCashInEntry);
          accrued = 0;
        }

        // 4.2 Возврат основного депозита
        // Окончание депозита: Дт 7327 (СФРБ), Кт Текущий счёт клиента
        const returnEntry = await ledger.postEntry(db, {
          entryDate: bankDate,
          contractId,
          kind: 'DEPOSIT_RETURN_SFRB',
          comment: `Окончание депозита ${contract.contract_number}: возврат основного вклада из СФРБ на текущий счёт`,
          lines: [
            { accountId: sfrb.id, side: 'D', amount },
            { accountId: contract.deposit_account_id, side: 'C', amount },
          ],
        });
        // Перевод депозита в кассу: Дт Текущий счёт (закрытие), Кт 1010 (Касса)
        const closeEntry = await ledger.postEntry(db, {
          entryDate: bankDate,
          contractId,
          kind: 'DEPOSIT_RETURN_CASH',
          comment: `Перевод депозита ${contract.contract_number} на выплату (закрытие текущего счёта)`,
          lines: [
            { accountId: contract.deposit_account_id, side: 'D', amount },
            { accountId: cash.id, side: 'C', amount },
          ],
        });
        // Поступление депозита в кассу для выдачи клиенту: Дебет 1010
        const cashInDepositEntry = await ledger.postEntry(db, {
          entryDate: bankDate,
          contractId,
          kind: 'DEPOSIT_CASH_IN',
          comment: `Поступление депозита ${contract.contract_number} в кассу для выдачи клиенту`,
          lines: [
            { accountId: cash.id, side: 'D', amount },
          ],
        });
        contractLog.entries.push(returnEntry, closeEntry, cashInDepositEntry);

        // Договор COMPLETED, счета CLOSED
        await db.query(
          `UPDATE deposit_contracts
              SET status = 'COMPLETED', accrued_interest = $1
            WHERE id = $2`,
          [accrued, contractId]
        );
        await db.query(
          `UPDATE bank_accounts SET status = 'CLOSED'
            WHERE id = ANY($1::int[])`,
          [[contract.deposit_account_id, contract.interest_account_id]]
        );
        contractLog.status = 'COMPLETED';
      } else {
        await db.query(
          'UPDATE deposit_contracts SET accrued_interest = $1 WHERE id = $2',
          [accrued, contractId]
        );
      }

      // Раскрываем номера счетов в строках проводок для отображения в UI
      contractLog.entries = await ledger.decorateEntriesWithAccounts(db, contractLog.entries);
      log.push(contractLog);
    }

    // =========================================================================
    // КРЕДИТНЫЕ ДОГОВОРЫ (Модуль 3)
    // =========================================================================
    const creditsLog = [];

    const creditsRes = await db.query(
      `SELECT
         cc.id,
         cc.contract_number,
         cc.amount,
         cc.annual_rate,
         cc.term_months,
         cc.credit_account_id,
         cc.interest_account_id,
         cc.start_date::text AS start_date,
         c.last_name, c.first_name, c.middle_name,
         cp.name AS program_name, cp.repayment_type
       FROM credit_contracts cc
       JOIN clients c           ON c.id = cc.client_id
       JOIN credit_programs cp  ON cp.id = cc.program_id
      WHERE cc.status = 'ACTIVE' AND cc.start_date <= $1
      ORDER BY cc.id`,
      [bankDate]
    );

    for (const credit of creditsRes.rows) {
      const contractId = Number(credit.id);
      const amount = Number(credit.amount);
      const clientName = `${credit.last_name} ${credit.first_name} ${credit.middle_name}`;

      // Номер месяца по графику погашения: 1 = месяц начала договора
      const monthIndex = monthsBetween(credit.start_date, bankDate) + 1;
      if (monthIndex < 1) continue;

      const schedule = computeSchedule({
        amount,
        annual_rate: credit.annual_rate,
        term_months: credit.term_months,
        repayment_type: credit.repayment_type,
        start_date: credit.start_date,
      });
      const row = schedule[monthIndex - 1];
      const interest = row.interest;
      const principal = row.principal;
      const lastMonth = monthIndex >= Number(credit.term_months);

      const contractLog = {
        contractId,
        contract_number: credit.contract_number,
        client_name: clientName,
        program_name: credit.program_name,
        amount,
        monthly_interest: interest,
        monthly_principal: principal,
        month_index: monthIndex,
        status: 'ACTIVE',
        entries: [],
      };

      // --- 1. Начисление процентов:
      //     Кт 7327 (СФРБ) + проценты; Кт 2470 (процентный счёт клиента) + проценты
      contractLog.entries.push(await ledger.postEntry(db, {
        entryDate: bankDate,
        creditContractId: contractId,
        kind: 'CREDIT_INTEREST_ACCRUAL',
        comment: `Начисление процентов за месяц ${bankDate} по кредитному договору ${credit.contract_number}`,
        lines: [
          { accountId: sfrb.id, side: 'C', amount: interest },
          { accountId: credit.interest_account_id, side: 'C', amount: interest },
        ],
      }));

      // --- 2. Погашение процентов клиентом:
      //     внесение в кассу: Дт 1010 + проценты;
      //     перевод % из кассы: Кт 1010 + проценты; Дт 2470 + проценты
      contractLog.entries.push(await ledger.postEntry(db, {
        entryDate: bankDate,
        creditContractId: contractId,
        kind: 'CREDIT_INTEREST_CASH_IN',
        comment: `Внесение процентов в кассу (кредитный договор ${credit.contract_number})`,
        lines: [
          { accountId: cash.id, side: 'D', amount: interest },
        ],
      }));
      contractLog.entries.push(await ledger.postEntry(db, {
        entryDate: bankDate,
        creditContractId: contractId,
        kind: 'CREDIT_INTEREST_PAYMENT',
        comment: `Погашение процентов из кассы: Кт 1010, Дт 2470 (кредитный договор ${credit.contract_number})`,
        lines: [
          { accountId: cash.id, side: 'C', amount: interest },
          { accountId: credit.interest_account_id, side: 'D', amount: interest },
        ],
      }));

      // --- 3. Погашение части/всего основного долга (по графику месяца):
      //     внесение в кассу: Дт 1010 + сумма погашения;
      //     погашение долга из кассы: Кт 1010 + сумма; Дт 2400 + сумма
      if (principal > 0) {
        contractLog.entries.push(await ledger.postEntry(db, {
          entryDate: bankDate,
          creditContractId: contractId,
          kind: 'CREDIT_PRINCIPAL_CASH_IN',
          comment: `Внесение денег в кассу в счёт погашения основного долга (кредитный договор ${credit.contract_number})`,
          lines: [
            { accountId: cash.id, side: 'D', amount: principal },
          ],
        }));
        contractLog.entries.push(await ledger.postEntry(db, {
          entryDate: bankDate,
          creditContractId: contractId,
          kind: 'CREDIT_PRINCIPAL_PAYMENT',
          comment: `Погашение основного долга из кассы: Кт 1010, Дт 2400 (кредитный договор ${credit.contract_number})`,
          lines: [
            { accountId: cash.id, side: 'C', amount: principal },
            { accountId: credit.credit_account_id, side: 'D', amount: principal },
          ],
        }));
      }

      // --- 4. Окончание срока договора (последний месяц по графику):
      //     Кт 7327 (СФРБ) + сумма кредита; Кт 2400 + сумма кредита.
      //     Договор -> CLOSED, счета закрываются.
      if (lastMonth) {
        contractLog.entries.push(await ledger.postEntry(db, {
          entryDate: bankDate,
          creditContractId: contractId,
          kind: 'CREDIT_COMPLETION',
          comment: `Окончание кредита ${credit.contract_number}: Кт 7327 СФРБ, Кт 2400`,
          lines: [
            { accountId: sfrb.id, side: 'C', amount },
            { accountId: credit.credit_account_id, side: 'C', amount },
          ],
        }));

        await db.query(
          `UPDATE credit_contracts SET status = 'CLOSED' WHERE id = $1`,
          [contractId]
        );
        await db.query(
          `UPDATE bank_accounts SET status = 'CLOSED'
            WHERE id = ANY($1::int[])`,
          [[credit.credit_account_id, credit.interest_account_id]]
        );
        contractLog.status = 'CLOSED';
      }

      contractLog.entries = await ledger.decorateEntriesWithAccounts(db, contractLog.entries);
      creditsLog.push(contractLog);
    }

    // --- Банковская дата: +1 месяц ---
    const newDateRes = await db.query(
      `UPDATE bank_settings
          SET value = (TO_DATE($1, 'YYYY-MM-DD') + INTERVAL '1 month')::date::text
        WHERE key = 'bank_date'
        RETURNING value`,
      [bankDate]
    );
    const newBankDate = newDateRes.rows[0].value;

    await db.query('COMMIT');

    res.json({
      bank_date: newBankDate,
      closed_month: bankDate,
      deposits_processed: log.length,
      credits_processed: creditsLog.length,
      contracts_processed: log.length + creditsLog.length,
      log,
      credits_log: creditsLog,
    });
  } catch (err) {
    await db.query('ROLLBACK');
    next(err);
  } finally {
    db.release();
  }
}

/**
 * POST /api/bank/set-date — установить банковскую дату (всегда первое число месяца).
 * Тело: { year, month } — год (2000–2100), месяц (1–12).
 * Ограничение: нельзя установить дату раньше текущей банковской даты, если
 * уже существуют договоры, — это нарушит уже выполненные расчёты процентов.
 */
async function setBankDate(req, res, next) {
  const { year, month } = req.body || {};
  const y = Number(year);
  const m = Number(month);

  if (!Number.isInteger(y) || y < 2000 || y > 2100) {
    return res.status(400).json({ message: 'Укажите корректный год (2000–2100)' });
  }
  if (!Number.isInteger(m) || m < 1 || m > 12) {
    return res.status(400).json({ message: 'Укажите корректный месяц (1–12)' });
  }

  const newDate = `${y}-${String(m).padStart(2, '0')}-01`;

  const db = await pool.connect();
  try {
    await db.query('BEGIN');

    const currentRes = await db.query("SELECT value FROM bank_settings WHERE key = 'bank_date'");
    const currentDate = currentRes.rows[0].value;

    if (newDate < currentDate) {
      // Откат назад разрешён, пока по договорам не выполнены расчёты:
      // нет начисленных процентов, нет завершённых/закрытых договоров,
      // нет ни одной кредитной проводки.
      const { rows } = await db.query(
        `SELECT 1 FROM (
           SELECT 1 FROM deposit_contracts
             WHERE status IN ('COMPLETED', 'CLOSED') OR accrued_interest > 0
           UNION ALL
           SELECT 1 FROM credit_contracts WHERE status = 'CLOSED'
           UNION ALL
           SELECT 1 FROM journal_entries WHERE credit_contract_id IS NOT NULL
         ) t
         LIMIT 1`
      );
      if (rows.length > 0) {
        await db.query('ROLLBACK');
        return res.status(400).json({
          message: `Нельзя установить дату раньше текущей банковской даты (${currentDate}): по договорам уже выполнены расчёты (начислены проценты, закрыты счета или проведены кредитные операции).`,
        });
      }
    }

    const updated = await db.query(
      "UPDATE bank_settings SET value = $1 WHERE key = 'bank_date' RETURNING value",
      [newDate]
    );

    await db.query('COMMIT');
    res.json({ bank_date: updated.rows[0].value });
  } catch (err) {
    await db.query('ROLLBACK');
    next(err);
  } finally {
    db.release();
  }
}

module.exports = {
  getBankState,
  setBankDate,
  closeMonth,
};