'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const { computeSchedule, addMonths, monthsBetween } = require('../src/services/creditSchedule');

const sum = (rows, key) => Math.round(rows.reduce((acc, r) => acc + r[key], 0) * 100) / 100;

test('ПОД КЛЮЧ 1000 @ 5%/12 мес: каждый месяц только процент S*i = 4.17', () => {
  const rows = computeSchedule({ amount: 1000, annual_rate: 5, term_months: 12, repayment_type: 'PRINCIPAL_AT_MATURITY', start_date: '2026-09-01' });
  assert.equal(rows.length, 12);
  for (const row of rows) {
    assert.equal(row.interest, 4.17);
  }
  // Месяцы 1..11 — только проценты, тело не гасится
  for (let i = 0; i < 11; i += 1) {
    assert.equal(rows[i].principal, 0);
    assert.equal(rows[i].payment, 4.17);
    assert.equal(rows[i].remaining, 1000);
  }
  // Последний месяц — весь долг + проценты
  assert.equal(rows[11].principal, 1000);
  assert.equal(rows[11].payment, 1004.17);
  assert.equal(rows[11].remaining, 0);
  assert.equal(sum(rows, 'interest'), 50.04);
  assert.equal(sum(rows, 'principal'), 1000);
});

test('На ЛИЧНОЕ 1000 @ 17.65%/13 мес: аннуитет 85.07, погашение строго по формуле', () => {
  const rows = computeSchedule({ amount: 1000, annual_rate: 17.65, term_months: 13, repayment_type: 'ANNUITY', start_date: '2026-09-01' });
  assert.equal(rows.length, 13);
  assert.equal(rows[0].date, '2026-09-01');
  // A = 1000 * (i*(1+i)^13)/((1+i)^13-1), i = 0.1765/12
  assert.equal(rows[0].payment, 85.07);
  assert.equal(rows[0].interest, 14.71);
  assert.equal(rows[0].principal, 70.36);
  assert.equal(rows[0].remaining, 929.64);
  // Внутри аннуитета: % убывают, тело растёт
  for (let i = 1; i < rows.length; i += 1) {
    assert.ok(rows[i].interest < rows[i - 1].interest, `% убывают в месяце ${i + 1}`);
    assert.ok(rows[i].principal > rows[i - 1].principal, `тело растёт в месяце ${i + 1}`);
  }
  // Последний месяц: остаток гасится полностью
  assert.equal(rows[12].remaining, 0);
  assert.equal(rows[12].principal, 83.91);
  assert.equal(sum(rows, 'principal'), 1000);
  assert.equal(sum(rows, 'interest'), 105.98);
});

test('На ЛИЧНОЕ: аннуитетный платёж примерно одинаков (85.07..85.14)', () => {
  const rows = computeSchedule({ amount: 1000, annual_rate: 17.65, term_months: 13, repayment_type: 'ANNUITY', start_date: '2026-09-01' });
  const payments = rows.map((r) => r.payment);
  assert.ok(Math.max(...payments) - Math.min(...payments) < 0.5, JSON.stringify(payments));
});

test('ПОД КЛЮЧ 1000 @ 5%/240 мес: длинный срок работает', () => {
  const rows = computeSchedule({ amount: 1000, annual_rate: 5, term_months: 240, repayment_type: 'PRINCIPAL_AT_MATURITY', start_date: '2026-09-01' });
  assert.equal(rows.length, 240);
  assert.equal(rows[239].principal, 1000);
  assert.equal(rows[239].remaining, 0);
  assert.equal(rows[0].interest, 4.17);
});

test('addMonths: перенос через границу года', () => {
  assert.equal(addMonths('2026-11-01', 2), '2027-01-01');
  assert.equal(addMonths('2026-01-01', 12), '2027-01-01');
  assert.equal(addMonths('2026-09-01', 0), '2026-09-01');
});

test('monthsBetween: количество полных месяцев между датами', () => {
  assert.equal(monthsBetween('2026-09-01', '2026-09-01'), 0);
  assert.equal(monthsBetween('2026-09-01', '2026-10-01'), 1);
  assert.equal(monthsBetween('2026-09-01', '2027-09-01'), 12);
});