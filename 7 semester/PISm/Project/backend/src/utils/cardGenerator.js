'use strict';

/**
 * Генерация номеров банковских карт (Модуль 4 «Эмулятор банкомата»).
 * Номер карты: 16 цифр. Префикс банка «4916» + 11 случайных цифр +
 * контрольная цифра по алгоритму Луна (Luhn).
 */

function digitsOf(value) {
  return String(value).split('').map(Number);
}

/**
 * Сумма по алгоритму Луна для набора цифр (без контрольной цифры).
 * Каждая вторая цифра справа налево удваивается; при результате > 9
 * вычитается 9.
 */
function luhnSum(digits) {
  let sum = 0;
  for (let i = digits.length - 1; i >= 0; i -= 1) {
    let d = digits[i];
    const fromRight = digits.length - 1 - i;
    if (fromRight % 2 === 0) {
      d *= 2;
      if (d > 9) d -= 9;
    }
    sum += d;
  }
  return sum;
}

/**
 * Контрольная цифра Луна для неполного номера (без последней цифры).
 * @param {number[]|string} partialDigits — первые 15 цифр номера
 * @returns {number}
 */
function luhnCheckDigit(partialDigits) {
  const digits = Array.isArray(partialDigits) ? partialDigits : digitsOf(partialDigits);
  const sum = luhnSum(digits);
  return (10 - (sum % 10)) % 10;
}

/** Проверка 16-значного номера карты по алгоритму Луна */
function isCardNumberLuhnValid(cardNumber) {
  const digits = digitsOf(cardNumber);
  if (digits.length !== 16) return false;
  const check = luhnCheckDigit(digits.slice(0, 15));
  return check === digits[15];
}

/**
 * Сгенерировать 16-значный номер банковской карты.
 * @param {string} [prefix='4916'] — префикс банка (IIN)
 * @returns {string} 16 цифр, прошёл проверку Луна
 */
function generateCardNumber(prefix = '4916') {
  const randomCount = 15 - prefix.length;
  let partial = prefix;
  for (let i = 0; i < randomCount; i += 1) {
    partial += String(Math.floor(Math.random() * 10));
  }
  return partial + String(luhnCheckDigit(digitsOf(partial)));
}

module.exports = {
  generateCardNumber,
  luhnCheckDigit,
  isCardNumberLuhnValid,
};