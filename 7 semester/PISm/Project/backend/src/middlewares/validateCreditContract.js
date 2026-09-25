'use strict';

/**
 * Middleware валидации кредитного договора (Модуль 3).
 * Нормализует тело запроса, проверяет обязательность и форматы, сверяет срок/ставку
 * с кредитными программами и дату с банковской датой.
 */

const pool = require('../config/db');

const DATE_REGEX = /^\d{4}-\d{2}-\d{2}$/;
const AMOUNT_REGEX = /^\d+(\.\d{1,2})?$/;

function isEmpty(value) {
  return value === undefined || value === null || String(value).trim() === '';
}

function isRealCalendarDate(year, month, day) {
  if (month < 1 || month > 12 || day < 1 || day > 31) return false;
  const date = new Date(Date.UTC(year, month - 1, day));
  return (
    date.getUTCFullYear() === year &&
    date.getUTCMonth() === month - 1 &&
    date.getUTCDate() === day
  );
}

function normalize(body) {
  return {
    client_id: isEmpty(body.client_id) ? null : Number(body.client_id),
    program_id: isEmpty(body.program_id) ? null : Number(body.program_id),
    term_months: isEmpty(body.term_months) ? null : Number(body.term_months),
    contract_number: isEmpty(body.contract_number) ? '' : String(body.contract_number).trim(),
    start_date: isEmpty(body.start_date) ? '' : String(body.start_date).trim(),
    amount: isEmpty(body.amount) ? null : String(body.amount).trim(),
    currency: isEmpty(body.currency) ? 'BYN' : String(body.currency).trim().toUpperCase(),
  };
}

module.exports = async function validateCreditContract(req, res, next) {
  const data = normalize(req.body);
  const errors = {};

  if (!Number.isInteger(data.client_id) || data.client_id <= 0) {
    errors.client_id = 'Выберите клиента';
  }

  if (!Number.isInteger(data.program_id) || data.program_id <= 0) {
    errors.program_id = 'Выберите кредитную программу';
  }

  if (!Number.isInteger(data.term_months) || data.term_months <= 0) {
    errors.term_months = 'Укажите срок кредита (в месяцах)';
  }

  if (data.contract_number === '') {
    errors.contract_number = 'Поле «Номер договора» обязательно';
  } else if (data.contract_number.length > 50) {
    errors.contract_number = 'Номер договора: не более 50 символов';
  }

  const amountValue = Number(data.amount);
  if (data.amount === null) {
    errors.amount = 'Поле «Сумма кредита» обязательно';
  } else if (!AMOUNT_REGEX.test(data.amount)) {
    errors.amount = 'Сумма кредита: неотрицательное число с не более чем 2 знаками после запятой';
  } else if (amountValue <= 0) {
    errors.amount = 'Сумма кредита должна быть больше нуля';
  } else if (amountValue > 999999999999.99) {
    errors.amount = 'Сумма кредита превышает допустимый лимит';
  }

  if (!DATE_REGEX.test(data.start_date)) {
    errors.start_date = 'Неверный формат даты заключения договора';
  } else {
    const [year, month, day] = data.start_date.split('-').map(Number);
    if (!isRealCalendarDate(year, month, day)) {
      errors.start_date = 'Указанная дата заключения не существует';
    }
  }

  if (data.currency !== 'BYN') {
    errors.currency = 'Валюта договора должна быть BYN';
  }

  if (Object.keys(errors).length > 0) {
    return res.status(400).json({ message: 'Ошибка валидации данных', errors });
  }

  // --- Проверки, требующие обращения к БД ---
  try {
    const bankDateRes = await pool.query(
      "SELECT value FROM bank_settings WHERE key = 'bank_date'"
    );
    const bankDate = bankDateRes.rows[0] ? bankDateRes.rows[0].value : null;
    if (bankDate && data.start_date > bankDate) {
      errors.start_date = 'Дата заключения не может быть позже текущей банковской даты';
    }

    const termRes = await pool.query(
      `SELECT ct.annual_rate, ct.term_months, cp.repayment_type, cp.name AS program_name
         FROM credit_program_terms ct
         JOIN credit_programs cp ON cp.id = ct.program_id
        WHERE ct.program_id = $1 AND ct.term_months = $2`,
      [data.program_id, data.term_months]
    );
    if (termRes.rows.length === 0) {
      errors.term_months = 'Для выбранной программы недоступен указанный срок';
    } else {
      const term = termRes.rows[0];
      data.annual_rate = Number(term.annual_rate);
      data.repayment_type = term.repayment_type;
      data.program_name = term.program_name;
    }

    const clientRes = await pool.query(
      'SELECT last_name, first_name, middle_name FROM clients WHERE id = $1',
      [data.client_id]
    );
    if (clientRes.rows.length === 0) {
      errors.client_id = 'Выбранный клиент не найден';
    } else {
      const clientRow = clientRes.rows[0];
      data.client_last_name = clientRow.last_name;
      data.client_first_name = clientRow.first_name;
      data.client_middle_name = clientRow.middle_name;
    }

    if (Object.keys(errors).length > 0) {
      return res.status(400).json({ message: 'Ошибка валидации данных', errors });
    }

    req.body = data;
    return next();
  } catch (err) {
    return next(err);
  }
};