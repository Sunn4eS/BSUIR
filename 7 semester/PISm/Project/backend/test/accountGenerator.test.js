'use strict';

/**
 * Модульные тесты генератора 13-значных счетов (EAN-13).
 * Запуск: npm test  (node --test test/)
 */

const test = require('node:test');
const assert = require('node:assert');

const { generateAccountNumber, computeCheckDigit } = require('../src/utils/accountGenerator');

test('EAN-13 эталонный вектор 400638133393 -> контрольный ключ 1', () => {
  assert.strictEqual(computeCheckDigit('400638133393'), 1);
});

test('Системный счёт кассы 101000000001 -> 1010000000015', () => {
  assert.strictEqual(computeCheckDigit('101000000001'), 5);
  assert.strictEqual(generateAccountNumber('1010', 1), '1010000000015');
});

test('Системный счёт СФРБ 732700000001 -> 7327000000018', () => {
  assert.strictEqual(computeCheckDigit('732700000001'), 8);
  assert.strictEqual(generateAccountNumber('7327', 1), '7327000000018');
});

test('Клиентский счёт 3014 с номером 42 -> 13 цифр и корректный ключ', () => {
  const number = generateAccountNumber('3014', 42);
  assert.strictEqual(number.length, 13);
  assert.match(number, /^\d{13}$/);
  assert.strictEqual(number.slice(0, 12), '301400000042');
  assert.strictEqual(number[12], String(computeCheckDigit('301400000042')));
});

test('Номера уникальны для разных порядковых номеров', () => {
  const a = generateAccountNumber('3474', 1);
  const b = generateAccountNumber('3474', 2);
  const c = generateAccountNumber('3474', 100000000);
  assert.notStrictEqual(a, b);
  assert.notStrictEqual(b, c);
});

test('generateAccountNumber(код) без номера формирует 13 цифр (внутренний счётчик)', () => {
  const number = generateAccountNumber('3404');
  assert.strictEqual(number.length, 13);
  assert.match(number, /^\d{13}$/);
  const check = computeCheckDigit(number.slice(0, 12));
  assert.strictEqual(Number(number[12]), check);
});

test('Некорректный код балансового счёта отклоняется', () => {
  assert.throws(() => generateAccountNumber('123'), /4-значным/);
  assert.throws(() => generateAccountNumber('12A4'), /4-значным/);
});

test('Некорректная база для контрольного ключа отклоняется', () => {
  assert.throws(() => computeCheckDigit('12345'), /12 цифр/);
});