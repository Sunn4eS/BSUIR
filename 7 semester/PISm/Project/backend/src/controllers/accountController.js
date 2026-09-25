'use strict';

const pool = require('../config/db');

const LIST_ACCOUNTS_SQL = `
  SELECT
    a.id,
    a.account_number,
    a.name AS account_name,
    a.status,
    a.holder_type,
    a.client_id,
    a.contract_id,
    coa.code AS chart_code,
    coa.name AS chart_name,
    coa.type AS chart_type,
    a.debit_turnover,
    a.credit_turnover,
    CASE WHEN coa.type = 'A'
         THEN a.debit_turnover - a.credit_turnover
         ELSE a.credit_turnover - a.debit_turnover
    END AS balance,
    CASE WHEN a.client_id IS NOT NULL
         THEN c.last_name || ' ' || c.first_name || ' ' || c.middle_name
    END AS client_name
  FROM bank_accounts a
  JOIN chart_of_accounts coa ON coa.id = a.chart_account_id
  LEFT JOIN clients c        ON c.id = a.client_id
`;

function mapAccount(row) {
  return {
    id: row.id,
    account_number: row.account_number,
    name: row.account_name,
    status: row.status,
    holder_type: row.holder_type,
    client_id: row.client_id,
    contract_id: row.contract_id,
    chart_code: row.chart_code,
    chart_name: row.chart_name,
    chart_type: row.chart_type,
    debit_turnover: Number(row.debit_turnover),
    credit_turnover: Number(row.credit_turnover),
    balance: Number(row.balance),
    client_name: row.client_name,
  };
}

/** GET /api/accounts — оборотная ведомость (баланс счетов) */
async function listAccounts(req, res, next) {
  try {
    const { rows } = await pool.query(
      `${LIST_ACCOUNTS_SQL} ORDER BY coa.code ASC, a.account_number ASC`
    );
    res.json(rows.map(mapAccount));
  } catch (err) {
    next(err);
  }
}

module.exports = {
  listAccounts,
};