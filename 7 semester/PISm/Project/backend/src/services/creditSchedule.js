'use strict';

/**
 * Сервис расчёта графика погашения кредита (Модуль 3 «Кредитные операции»).
 *
 * Два метода погашения:
 *   ANNUITY                — «На ЛИЧНОЕ»: аннуитетный ежемесячный платёж
 *                            A = S * (i * (1 + i)^n) / ((1 + i)^n - 1),
 *                            где i = (Ставка / 100) / 12.
 *                            Каждый месяц: проценты (остаток * i) +
 *                            часть основного долга (A - проценты);
 *                            в последний месяц остаток гасится полностью.
 *   PRINCIPAL_AT_MATURITY  — «ПОД КЛЮЧ»: в месяцах 1..(n-1) гасится только
 *                            процент S * i; в месяц n — весь основной долг S
 *                            и проценты за этот месяц.
 */

const { round2 } = require('./ledgerService');

/** Сдвиг даты YYYY-MM-DD на months месяцев (всегда первое число месяца) */
function addMonths(dateStr, months) {
  const [y, m] = String(dateStr).split('-').map(Number);
  const d = new Date(Date.UTC(y, m - 1 + months, 1));
  return d.toISOString().slice(0, 10);
}

/** Количество полных месяцев между датами (по году/месяцу) */
function monthsBetween(fromDate, toDate) {
  const [y1, m1] = String(fromDate).slice(0, 7).split('-').map(Number);
  const [y2, m2] = String(toDate).slice(0, 7).split('-').map(Number);
  return (y2 - y1) * 12 + (m2 - m1);
}

/**
 * График погашения кредита.
 * @param {object} params
 * @param {number} params.amount — сумма кредита
 * @param {number} params.annual_rate — ставка, % годовых
 * @param {number} params.term_months — срок, месяцев
 * @param {'ANNUITY'|'PRINCIPAL_AT_MATURITY'} params.repayment_type — метод погашения
 * @param {string} params.start_date — дата начала договора (YYYY-MM-DD)
 * @returns {Array<{month:number, date:string, interest:number, principal:number,
 *                  payment:number, remaining:number}>}
 */
function computeSchedule({ amount, annual_rate, term_months, repayment_type, start_date }) {
  const S = Number(amount);
  const n = Number(term_months);
  const i = Number(annual_rate) / 100 / 12;
  const schedule = [];
  let balance = S;

  if (repayment_type === 'ANNUITY') {
    const factor = Math.pow(1 + i, n);
    const annuity = round2(S * (i * factor) / (factor - 1));

    for (let m = 1; m <= n; m += 1) {
      const interest = round2(balance * i);
      let principal;
      if (m === n) {
        // Последний месяц: остаток тела гасится полностью (копеечная разница
        // от округления аннуитета уходит в последний платёж).
        principal = balance;
      } else {
        principal = round2(annuity - interest);
        if (principal < 0) principal = 0;
        if (principal > balance) principal = balance;
      }
      const payment = round2(principal + interest);
      balance = round2(balance - principal);
      schedule.push({ month: m, date: addMonths(start_date, m - 1), interest, principal, payment, remaining: balance });
    }
  } else {
    // PRINCIPAL_AT_MATURITY: до последнего месяца платится только процент
    const interest = round2(S * i);
    for (let m = 1; m <= n; m += 1) {
      const principal = m === n ? S : 0;
      const payment = round2(principal + interest);
      balance = round2(balance - principal);
      schedule.push({ month: m, date: addMonths(start_date, m - 1), interest, principal, payment, remaining: balance });
    }
  }

  return schedule;
}

module.exports = {
  computeSchedule,
  addMonths,
  monthsBetween,
};