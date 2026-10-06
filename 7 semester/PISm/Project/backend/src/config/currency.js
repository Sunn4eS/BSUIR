'use strict';

/**
 * Справочник валют и фиксированных курсов пересчёта в базовую валюту банка.
 *
 * Клиентские счета ведутся в валюте договора (BYN, USD, EUR, RUB), а системные
 * счета (1010 «Касса банка» и 7327 «СФРБ») — строго в BYN. Поэтому любая проводка
 * по валютному договору содержит две валюты: сумма в валюте договора и её
 * эквивалент в BYN, рассчитанный по курсу ниже.
 */

/** Базовая (отчётная) валюта банка. */
const BASE_CURRENCY = 'BYN';

/** Валюты, доступные для депозитных договоров. */
const ALLOWED_CURRENCIES = ['BYN', 'USD', 'EUR', 'RUB'];

/**
 * Фиксированные курсы: сколько BYN стоит 1 единица валюты.
 * BYR заменён на RUB (деноминация 2016 г.).
 */
const CURRENCY_RATES = {
  BYN: 1.0,
  USD: 3.2,
  EUR: 3.5,
  RUB: 0.035,
};

/** Округление денежной суммы до 2 знаков (половинное округление вверх) */
function round2(value) {
  return Math.round((Number(value) + Number.EPSILON) * 100) / 100;
}

function isSupportedCurrency(currency) {
  return Object.prototype.hasOwnProperty.call(CURRENCY_RATES, currency);
}

/**
 * Курс валюты к BYN.
 * @param {string} currency — код валюты
 * @returns {number} сколько BYN стоит 1 единица валюты
 */
function getRate(currency) {
  if (!isSupportedCurrency(currency)) {
    throw new Error(`Неизвестная валюта: «${currency}»`);
  }
  return CURRENCY_RATES[currency];
}

/**
 * Эквивалент суммы в базовой валюте банка.
 * @param {number} amount — сумма в исходной валюте
 * @param {string} currency — код исходной валюты
 * @returns {number} сумма в BYN (округление до 2 знаков)
 */
function toByn(amount, currency) {
  return round2(Number(amount) * getRate(currency));
}

/**
 * Перевод суммы из одной валюты в другую.
 * @param {number} amount — сумма в исходной валюте
 * @param {string} from — код исходной валюты
 * @param {string} to — код целевой валюты
 * @returns {number} сумма в целевой валюте (округление до 2 знаков)
 */
function convert(amount, from, to) {
  if (from === to) return round2(Number(amount));
  return round2((Number(amount) * getRate(from)) / getRate(to));
}

/** Человекочитаемое название валюты для UI */
const CURRENCY_LABELS = {
  BYN: 'BYN (белорусский рубль)',
  USD: 'USD (доллар США)',
  EUR: 'EUR (евро)',
  RUB: 'RUB (российский рубль)',
};

module.exports = {
  BASE_CURRENCY,
  ALLOWED_CURRENCIES,
  CURRENCY_RATES,
  CURRENCY_LABELS,
  isSupportedCurrency,
  getRate,
  toByn,
  convert,
  round2,
};