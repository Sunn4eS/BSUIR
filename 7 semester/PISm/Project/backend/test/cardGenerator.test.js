'use strict';

const { test } = require('node:test');
const assert = require('node:assert');

const {
  generateCardNumber,
  luhnCheckDigit,
  isCardNumberLuhnValid,
} = require('../src/utils/cardGenerator');

test('контрольная цифра Луна: 411111111111111 -> 1 (Visa test number)', () => {
  assert.strictEqual(luhnCheckDigit('411111111111111'), 1);
  assert.strictEqual(isCardNumberLuhnValid('4111111111111111'), true);
});

test('известный валидный номер карты проходит Луна', () => {
  const known = [
    '4111111111111111', // Visa test
    '4012888888881881', // Visa test 2
    '5555555555554444', // Mastercard test
    '4222222222222',    // 13 знаков — не 16, должен быть false
  ];
  assert.strictEqual(isCardNumberLuhnValid(known[0]), true);
  assert.strictEqual(isCardNumberLuhnValid(known[1]), true);
  assert.strictEqual(isCardNumberLuhnValid(known[2]), true);
  assert.strictEqual(isCardNumberLuhnValid(known[3]), false); // длина != 16
});

test('generateCardNumber: 16 цифр, префикс 4916, валиден по Луна', () => {
  for (let i = 0; i < 200; i += 1) {
    const number = generateCardNumber('4916');
    assert.match(number, /^4916\d{12}$/, 'формат номера');
    assert.strictEqual(number.length, 16, 'длина');
    assert.strictEqual(isCardNumberLuhnValid(number), true, 'Luhn валиден');
  }
});

test('generateCardNumber без префикса тоже даёт 16 цифр', () => {
  const number = generateCardNumber();
  assert.strictEqual(number.length, 16);
  assert.strictEqual(isCardNumberLuhnValid(number), true);
});