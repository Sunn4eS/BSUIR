'use strict';

/**
 * Генерация 13-значных банковских счетов (алгоритм на основе EAN-13).
 *
 * Структура номера: [4 цифры — код балансового счёта] + [8 цифр — уникальный
 * порядковый номер] + [1 цифра — контрольный ключ C].
 *
 * Контрольный ключ (EAN-13):
 *   1. 12 сгенерированных цифр нумеруются СПРАВА НАЛЕВО (от 1 до 12).
 *   2. S_odd  = сумма цифр на нечётных позициях (1, 3, 5, ... от правого края)
 *   3. S_even = сумма цифр на чётных позициях (2, 4, 6, ... от правого края)
 *   4. Total = S_odd * 3 + S_even
 *   5. C = 0, если Total % 10 == 0, иначе C = 10 - (Total % 10).
 */

// Внутренний счётчик: используется только тогда, когда последовательность
// (8-значный уникальный номер) не передаётся явно — для тестов и логов.
let internalSequence = 0;

function nextInternalSequence() {
  internalSequence += 1;
  return internalSequence;
}

/** Нормализация 8-значной части: число -> строка из 8 цифр */
function normalizeSequence(sequence) {
  const n = Math.max(0, Math.floor(Number(sequence) || 0));
  return String(n % 100000000).padStart(8, '0');
}

/**
 * Вычисление контрольного ключа EAN-13 для 12 цифр.
 * @param {string|number} base12 — 12 цифр
 * @returns {number} контрольная цифра C (0..9)
 */
function computeCheckDigit(base12) {
  const digits = String(base12).split('').map(Number);
  if (digits.length !== 12) {
    throw new Error('computeCheckDigit: требуется ровно 12 цифр');
  }

  let sOdd = 0;
  let sEven = 0;

  // Нумерация позиций СПРАВА НАЛЕВО: правая цифра — позиция 1 (нечётная).
  for (let i = 0; i < 12; i += 1) {
    const positionFromRight = 12 - i;
    if (positionFromRight % 2 === 1) {
      sOdd += digits[i];
    } else {
      sEven += digits[i];
    }
  }

  const total = sOdd * 3 + sEven;
  const remainder = total % 10;
  return remainder === 0 ? 0 : 10 - remainder;
}

/**
 * Генерация 13-значного номера счёта.
 * @param {string|number} accountPlanCode — 4-значный код из Плана счетов (1010, 7327, 3014, ...)
 * @param {number} [uniqueSequence] — уникальный порядковый номер (8 цифр).
 *        Если не передан, используется внутренний счётчик (тесты/логи).
 *        В боевом сценарии номер берётся из последовательности БД bank_account_seq.
 * @returns {string} 13-значный номер счёта
 */
function generateAccountNumber(accountPlanCode, uniqueSequence) {
  const code = String(accountPlanCode);
  if (!/^\d{4}$/.test(code)) {
    throw new Error(`generateAccountNumber: код балансового счёта должен быть 4-значным, получено "${code}"`);
  }

  const sequence = uniqueSequence === undefined ? nextInternalSequence() : uniqueSequence;
  const base12 = code + normalizeSequence(sequence);
  const checkDigit = computeCheckDigit(base12);

  return base12 + String(checkDigit);
}

module.exports = {
  generateAccountNumber,
  computeCheckDigit,
};